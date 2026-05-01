import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:smartq/ai_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  
  @override
  State<ChatPage> createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;

  late stt.SpeechToText speech;

  bool isListening = false;
  
  @override
  void initState() { 
    super.initState();
    speech = stt.SpeechToText();
  }
  
  Future<void> startListening() async {
    bool available = await speech.initialize();
    if (available) {
      setState(() => isListening = true);
      speech.listen(onResult: (result) {
        setState(() {
          controller.text = result.recognizedWords;
        }); 
      }); 
    } 
  }
  
  void stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }
  
  void scrollToBottom() {
    if (scrollController.hasClients){
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  Future<void> sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String text = controller.text.trim();
    if (text.isEmpty) return;
    controller.clear();
    setState(() => isLoading = true);
    
    try {
      String aiReply = await AIService.getReply(text);
      if (aiReply.contains("Error") || aiReply.isEmpty) {
        aiReply = AIService.localReply(text);
      }
      String specialty = await AIService.getSpecialty(text);
      specialty = specialty.replaceAll(RegExp(r'[^a-zA-Z]'), '');
      specialty = specialty .replaceAll('\n', '') .replaceAll('.', '') .trim() .toLowerCase();
      specialty = specialty[0].toUpperCase() + specialty.substring(1);
      
      var snapshot = await FirebaseFirestore.instance 
              .collection("doctors") 
              .where("department", isEqualTo: specialty) 
              .get();

      String finalReply = "$aiReply\n\n";

      if (snapshot.docs.isNotEmpty) {
        var doctors = snapshot.docs; 
        doctors.sort((a, b) => (a['queue'] ?? 999).compareTo(b['queue']));
        var topDoctors = doctors.take(3).toList(); 
        finalReply += "You may consult a $specialty . \n\n"; 
        for (int i = 0; i < topDoctors.length; i++) { 
          var doc = topDoctors[i].data();
          finalReply += 
            "${i + 1}. ${doc['name']} (Queue: ${doc['queue'] ?? 'N/A'})\n";
        } 
      } else { 
        finalReply += "No doctors available for $specialty"; 
      } 
      
      await FirebaseFirestore.instance
            .collection("chats")
            .add({ 
              "userId": user.uid, 
              "message": text, 
              "response": finalReply, 
              "timestamp": FieldValue.serverTimestamp(), 
              "localTime": DateTime.now().millisecondsSinceEpoch, 
            }); 
      } catch (e) {
        await FirebaseFirestore.instance
            .collection("chats")
            .add({ 
              "userId": user.uid, 
              "message": text, 
              "response": "System error. Try again later.", 
              "timestamp": FieldValue.serverTimestamp(), 
              "localTime":DateTime.now().millisecondsSinceEpoch, 
            }); 
            
        }
        
    setState(() => isLoading = false);

    Future.delayed(
      const Duration(milliseconds: 300), 
      scrollToBottom); } 
      
    @override 
    Widget build(BuildContext context) { 
      final user = FirebaseAuth.instance.currentUser; 
      return Scaffold( 
        appBar: AppBar( 
          backgroundColor: const Color.fromARGB(255, 2, 45, 119), 
          title: const Text("AI Assistant"), 
        ),
        backgroundColor: const Color.fromARGB(255, 102, 127, 131),
        body: Column( 
          children: [ 
            Expanded( 
              child: 
              user == null ? const Center(
                child: Text("Please login")
              )
              : StreamBuilder<QuerySnapshot>( 
                stream: FirebaseFirestore.instance 
                   .collection("chats") 
                   .where("userId", isEqualTo: user.uid) 
                   .orderBy("timestamp") 
                   .snapshots(), 
                builder: (context, snapshot) {
                  if (
                    snapshot.connectionState == ConnectionState.waiting) { 

                      return const Center(
                        child: Text("Connecting...")
                      );
                    }
                  if (!snapshot.hasData) { 
                    return const Center(
                      child: CircularProgressIndicator()
                    ); 
                  }
                  
                  final chats = snapshot.data!.docs;
                  
                  if (chats.isEmpty) {
                    return const Center(
                      child: Text(
                        "Start chatting"
                      )
                    );
                  } 
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollToBottom(); 
                  }); 
                  
                  return ListView.builder( 
                    controller: scrollController,
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index].data() as Map<String, dynamic>;
                      String message = chat['message'] ?? "";
                      String response = chat['response'] ?? "";
                      String time = "";
                      if (chat['timestamp'] != null) {
                        DateTime date = (chat['timestamp'] as Timestamp).toDate().toLocal();
                        time = DateFormat('hh:mm a').format(date);
                      } else if (
                        chat['localTime'] != null) {
                          DateTime date = DateTime.fromMillisecondsSinceEpoch( chat['localTime']);
                          time = DateFormat('hh:mm a').format(date.toLocal());
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align( 
                              alignment: Alignment.centerRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(6),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(12), 
                                    ),
                                    child: Text(
                                      message,
                                      style: const TextStyle(
                                        color: Colors.white
                                        ),
                                    ), 
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      time,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [ 
                                  Container( 
                                    margin: const EdgeInsets.all(6),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration( 
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      response.isNotEmpty ? response : "No response",
                                      style: const TextStyle(
                                        color: Colors.black
                                      ),
                                    ), 
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      time,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              
              if (isLoading)
              const Padding( 
                padding: EdgeInsets.all(10),
                child: Text(
                  "AI is typing...",
                  style: TextStyle(
                    color: Colors.grey
                  )
                ),
              ),
            
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "Ask medical question...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      isListening ? Icons.mic : Icons.mic_none
                    ),
                    onPressed: () {
                      isListening ? stopListening() : startListening();
                    }, 
                  ),
                  
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } 
  }
  
  
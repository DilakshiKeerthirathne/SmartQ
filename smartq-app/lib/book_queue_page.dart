import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:smartq/viewmodels/queue_viewmodel.dart';
import 'package:smartq/views/user/queue_status_page.dart';

class BookQueuePage extends StatefulWidget {
  const BookQueuePage({super.key});

  @override
  State<BookQueuePage> createState() => _BookQueuePageState();
}

class _BookQueuePageState extends State<BookQueuePage> {
  bool isEmergency = false;

  String? selectedDoctorId;
  Map<String, dynamic>? selectedDoctorData;

  Future<void> bookQueue() async {
    final vm = Provider.of<QueueViewModel>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || selectedDoctorData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a doctor")),
      );
      return;
    }

    await vm.bookQueue(
      userId: user.uid,
      doctorId: selectedDoctorId!,
      doctorData: selectedDoctorData!,
      isEmergency: isEmergency,
    );

    if (vm.error != null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error!)),
      );
      return;
    }

    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (_) => const QueueStatusPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QueueViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text(
          "Book Appointment",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E2A47),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Doctor",
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("doctors")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Text("No doctors available");
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: docs.any((d) => d.id == selectedDoctorId)
                        ? selectedDoctorId
                        : null,
                    hint: const Text("Select Doctor"),
                    isExpanded: true,

                    items: docs.map((doc) {
                      final data =
                          doc.data() as Map<String, dynamic>;

                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(
                          "${data['name']} (${data['department']})",
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedDoctorId = value;

                        final selectedDoc = docs.firstWhere(
                            (doc) => doc.id == value);

                        selectedDoctorData =
                            selectedDoc.data()
                                as Map<String, dynamic>;
                      });
                    },

                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              if (selectedDoctorData != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(selectedDoctorData!['name']),
                    subtitle: Text(
                      "${selectedDoctorData!['department']} • ${selectedDoctorData!['status']}",
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              if (selectedDoctorData != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text("Time Slot"),
                    subtitle: Text(
                        selectedDoctorData!['timeSlot'] ?? "N/A"),
                  ),
                ),

              const SizedBox(height: 10),

              if (selectedDoctorData != null)
                StreamBuilder<int>(
                  stream: vm.getQueueLength(selectedDoctorId!),
                  builder: (context, snapshot) {
                    int count = snapshot.data ?? 0;

                    num waitTime =
                        count * (selectedDoctorData!['avgTime'] ?? 5);

                    return Column(
                      children: [
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.people),
                            title: const Text("Queue Length"),
                            subtitle:
                                Text("$count people waiting"),
                          ),
                        ),

                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.timer),
                            title: const Text("Estimated Time"),
                            subtitle:
                                Text("$waitTime minutes"),
                          ),
                        ),

                        Card(
                          child: SwitchListTile(
                            title: const Text(
                              "Emergency Case",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            subtitle: const Text(
                                "Priority will be given"),
                            value: isEmergency,
                            activeThumbColor: Colors.white,
                            activeTrackColor: Colors.red,

    
                            inactiveThumbColor: Colors.grey,
                            inactiveTrackColor: Colors.grey.shade300,

                            onChanged: (value) {
                              setState(() {
                                isEmergency = value;
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF1E2A47),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      vm.isLoading || selectedDoctorData == null
                          ? null
                          : bookQueue,
                  child: vm.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text(
                          "Confirm Booking",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
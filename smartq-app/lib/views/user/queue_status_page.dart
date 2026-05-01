import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartq/viewmodels/queue_status_viewmodel.dart';

class QueueStatusPage extends StatelessWidget {
  const QueueStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QueueStatusViewModel>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      appBar: AppBar(
        title: const Text(
          "Queue Status",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E2A47),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: vm.getTickets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = snapshot.data!.docs;

          final waitingTickets = tickets.where((t) {
            final data = t.data() as Map<String, dynamic>;
            return data['status'] == "Waiting";
            }).toList();

            if (waitingTickets.isEmpty) {
              return const Center(child: Text("No active queue"));
            }

            final userTicketIndex = waitingTickets.indexWhere((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['userId'] == user!.uid;
            });

            if (userTicketIndex == -1) {
              return const Center(child: Text("No active ticket"));
            }

            final userTicket = waitingTickets[userTicketIndex];

            int peopleAhead = userTicketIndex;
            int total = waitingTickets.length;

            int estimatedTime = peopleAhead * 5;
          double progress = total == 0 ? 0 : (userTicketIndex + 1) / total;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Queue Status",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                  ),

                  const SizedBox(height: 10),

                  Text("Position ${userTicketIndex + 1} of $total"),

                  const SizedBox(height: 20),

                  _buildCard("Your Ticket",
                      userTicket['ticketNumber'] ?? "N/A"),

                  _buildCard("Doctor",
                      userTicket['doctor'] ?? "N/A"),

                  _buildCard("Department",
                      userTicket['department'] ?? "N/A"),

                  _buildCard(
                      "People Ahead", "$peopleAhead"),

                  _buildCard(
                      "Estimated Time", "$estimatedTime min"),

                  if (userTicket['isEmergency'] == true)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Emergency Priority",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  if (peopleAhead == 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "You are NEXT!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        await vm.cancelTicket(userTicket.id);

                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Ticket Cancelled"),
                          ),
                        );

                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel Ticket"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
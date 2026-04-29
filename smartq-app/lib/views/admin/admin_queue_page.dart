import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';

class AdminQueuePage extends StatelessWidget {
  const AdminQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AdminViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF101C33),

      appBar: AppBar(
        title: const Text("Queue Control"),
        backgroundColor: const Color(0xFF0F1B33),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("tickets")
                  .where("status", isEqualTo: "Called")
                  .orderBy("createdAt", descending: true)
                  .limit(1)
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(15),
                    child: const Text(
                      "No patient called yet",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final data =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Now Serving",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        data['ticketNumber'] ?? "--",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final error = await vm.callNext();

                        if (error != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Next patient called"),
                            ),
                          );
                        }
                      },

                icon: vm.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.skip_next),

                label: const Text(
                  "Call Next Patient",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
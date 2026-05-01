import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyTicketsPage extends StatelessWidget {
  const MyTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
               Color(0xFF0F2027),
               Color(0xFF203A43),
              ],
            ),
          ),
        ),
        title: const Text(
          "My Tickets",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/tickets.jpg",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.7),
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "My Tickets",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("tickets")
                        .where("userId", isEqualTo: user!.uid)
                        .snapshots(),

                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      var tickets = snapshot.data!.docs;

                      if (tickets.isEmpty) {
                        return _emptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {

                          var t = tickets[index];
                          String status = t['status'] ?? "Waiting";

                          Color statusColor;
                          IconData statusIcon;

                          switch (status) {
                            case "Completed":
                              statusColor = Colors.green;
                              statusIcon = Icons.check_circle;
                              break;
                            case "Cancelled":
                              statusColor = Colors.red;
                              statusIcon = Icons.cancel;
                              break;
                            default:
                              statusColor = Colors.orange;
                              statusIcon = Icons.access_time;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 18),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.12),

                              border: Border.all(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.2),
                              ),

                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(18),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      Text(
                                        t['ticketNumber'] ?? "N/A",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          // ignore: deprecated_member_use
                                          color: statusColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(
                                            color: statusColor,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(statusIcon,
                                                size: 14,
                                                color: statusColor),
                                            const SizedBox(width: 5),
                                            Text(
                                              status,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      const Icon(Icons.local_hospital,
                                          size: 18, color: Colors.white70),
                                      const SizedBox(width: 10),
                                      Text(
                                        t['department'] ?? "General Queue",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(Icons.person,
                                          size: 18, color: Colors.white70),
                                      const SizedBox(width: 10),
                                      Text(
                                        t['doctor'] ?? "Doctor Not Assigned",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 15),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Booked: ${_formatDate(t['createdAt'])}",
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                      
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "";

    DateTime date = timestamp.toDate();

    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }
  
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [

          Icon(Icons.confirmation_number,
              size: 90, color: Colors.white54),

          SizedBox(height: 20),

          Text(
            "No Tickets Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "Book your first queue ticket",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
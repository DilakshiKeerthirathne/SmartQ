import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/notification_viewmodel.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final vm = Provider.of<NotificationViewModel>(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E2A47),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Stack(
        children: [
          /// BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              "assets/images/notifications.jpg",
              fit: BoxFit.cover,
            ),
          ),

          /// DARK OVERLAY
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          /// NOTIFICATIONS LIST
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: vm.getNotifications(user.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final notifications = snapshot.data!;

              if (notifications.isEmpty) {
                return const Center(
                  child: Text(
                    "No notifications",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];

                  final isRead = n["read"] ?? false;

                  return Dismissible(
                    key: Key(n["id"]),
                    direction: DismissDirection.endToStart,

                    onDismissed: (_) {
                      vm.markAsRead(n["id"]);
                    },

                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.green,
                      child: const Icon(Icons.check, color: Colors.white),
                    ),

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),

                      decoration: BoxDecoration(
                        color: isRead
                            ? Colors.white.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white24),
                      ),

                      child: ListTile(
                        leading: Icon(
                          Icons.notifications,
                          color: isRead ? Colors.white70 : Colors.orange,
                        ),

                        title: Text(
                          n["message"] ?? "",
                          style: const TextStyle(color: Colors.white),
                        ),

                        subtitle: Text(
                          n["createdAt"] != null
                              ? n["createdAt"].toDate().toString()
                              : "",
                          style: const TextStyle(color: Colors.white70),
                        ),

                        trailing: isRead
                            ? const Icon(Icons.done, color: Colors.green)
                            : const Icon(Icons.circle,
                                size: 10, color: Colors.red),

                        onTap: () => vm.markAsRead(n["id"]),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
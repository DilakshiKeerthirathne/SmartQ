import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? error;

  
  Stream<List<Map<String, dynamic>>> getNotifications(String userId) {
    return _firestore
        .collection("notifications")
        .where("userId", isEqualTo: userId)
        
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {
              "id": doc.id,
              ...doc.data(),
            }).toList());
  }

  
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection("notifications")
        .where("userId", isEqualTo: userId)
        .where("read", isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection("notifications")
          .doc(notificationId)
          .update({"read": true});
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  
  Future<void> sendNotification({
    required String userId,
    required String message,
  }) async {
    try {
      await _firestore.collection("notifications").add({
        "userId": userId,
        "message": message,
        "read": false,
        "createdAt": Timestamp.now(),
      });
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
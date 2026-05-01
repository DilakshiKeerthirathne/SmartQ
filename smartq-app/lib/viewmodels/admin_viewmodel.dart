import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartq/repositories/admin_repository.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository _repo = AdminRepository();

  bool isLoading = false;
  String? error;

  Stream<List<Map<String, dynamic>>> get queueStream {
    return FirebaseFirestore.instance
        .collection("tickets")
        .orderBy("createdAt")
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<String?> callNext() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _repo.callNextTicket();
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return error.toString();
    }
  }

  Future<void> togglePause() async {
    try {
      await _repo.togglePause();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
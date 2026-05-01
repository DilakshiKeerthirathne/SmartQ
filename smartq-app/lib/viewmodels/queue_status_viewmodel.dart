import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QueueStatusViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getTickets() {
    return _db
        .collection("tickets")
        .orderBy("isEmergency", descending: true)
        
        .snapshots();
  }

  Stream<QuerySnapshot> getNowServing() {
    return _db
        .collection("tickets")
        .where("status", isEqualTo: "Called")
        .orderBy("createdAt", descending: true)
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot> getNextPatient() {
    return _db
        .collection("tickets")
        .where("status", isEqualTo: "Waiting")
        .orderBy("isEmergency", descending: true)
        .orderBy("createdAt")
        .limit(1)
        .snapshots();
  }

  Future<void> cancelTicket(String id) async {
    await _db.collection("tickets").doc(id).update({
      "status": "Cancelled"
    });
  }
}
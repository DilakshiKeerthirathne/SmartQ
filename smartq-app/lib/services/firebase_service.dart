import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _db
        .collection("users")
        .doc(userCredential.user!.uid)
        .get();

    return doc.data();
  }

  Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection("users").doc(userCredential.user!.uid).set({
      "name": name,
      "email": email,
      "role": "user",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Stream<QuerySnapshot> getDoctors() {
    return _db.collection("doctors").snapshots();
  }

  Future<void> addDoctor(
    String name,
    String dept,
    String queue,
  ) async {
    await _db.collection("doctors").add({
      "name": name,
      "department": dept,
      "queue": queue,
      "status": "Available",
      "createdAt": Timestamp.now(),
    });
  }

  Future<void> updateDoctor(
    String id,
    String name,
    String dept,
  ) async {
    await _db.collection("doctors").doc(id).update({
      "name": name,
      "department": dept,
    });
  }

  Future<void> deleteDoctor(String id) async {
    await _db.collection("doctors").doc(id).delete();
  }

 //queue
  Future<void> callNextTicket() async {
    final systemRef = _db.collection("system").doc("queueControl");
    final systemSnap = await systemRef.get();

    bool isPaused = systemSnap.exists ? systemSnap['isPaused'] : false;

    if (isPaused) {
      throw Exception("Queue is paused");
    }

    // complete current called
    final current = await _db
        .collection("tickets")
        .where("status", isEqualTo: "Called")
        .get();

    for (var doc in current.docs) {
      await doc.reference.update({"status": "Completed"});
    }

    // get next
    final next = await _db
        .collection("tickets")
        .where("status", isEqualTo: "Waiting")
        .orderBy("isEmergency", descending: true)
        .orderBy("createdAt")
        .limit(1)
        .get();

    if (next.docs.isEmpty) return;

    final doc = next.docs.first;

    await doc.reference.update({"status": "Called"});

    // notification
    await _db.collection("notifications").add({
      "userId": doc['userId'],
      "message": "Your turn! Please go to doctor.",
      "createdAt": Timestamp.now(),
      "read": false,
    });
  }

  Future<void> togglePause() async {
    final doc = _db.collection("system").doc("queueControl");
    final snap = await doc.get();

    bool current = snap.exists ? snap['isPaused'] : false;

    await doc.set({"isPaused": !current});
  }

  //profile

  Future<void> updateName(String uid, String name) async {
    await _db.collection("users").doc(uid).update({
      "name": name,
    });
  }

  //book queue
  Future<void> bookQueue({
    required String userId,
    required String doctorId,
    required Map<String, dynamic> doctorData,
    required bool isEmergency,
  }) async {
    final prefix = doctorData['prefix'];
    final doctorName = doctorData['name'];
    final department = doctorData['department'];

    final counterRef =
        _db.collection('counters').doc(prefix);

    final existing = await _db
        .collection("tickets")
        .where("userId", isEqualTo: userId)
        .where("status", isEqualTo: "Waiting")
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception("You already have a ticket");
    }

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int currentNumber =
          snapshot.exists ? snapshot['currentNumber'] : 1;

      int nextNumber = currentNumber + 1;

      transaction.set(counterRef, {
        "currentNumber": nextNumber,
      });

      String ticketNumber =
          "$prefix${currentNumber.toString().padLeft(3, '0')}";

      final ticketRef = _db.collection("tickets").doc();

      transaction.set(ticketRef, {
        "userId": userId,
        "ticketNumber": ticketNumber,
        "doctorId": doctorId,
        "doctor": doctorName,
        "department": department,
        "status": "Waiting",
        "isEmergency": isEmergency,
        "createdAt": Timestamp.now(),
      });
    });
  }


  Stream<int> getQueueLength(String doctorId) {
    return _db
        .collection("tickets")
        .where("doctorId", isEqualTo: doctorId)
        .where("status", isEqualTo: "Waiting")
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Stream<List<TicketModel>> getAllTickets() {
    return _db
        .collection("tickets")
        .orderBy("isEmergency", descending: true)
        .orderBy("createdAt")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TicketModel.fromFirestore(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  Stream<List<TicketModel>> getUserTickets(String userId) {
    return _db
        .collection("tickets")
        .where("userId", isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TicketModel.fromFirestore(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  //ticket
  Future<void> cancelTicket(String id) async {
    await _db.collection("tickets").doc(id).update({
      "status": "Cancelled",
    });
  }
}
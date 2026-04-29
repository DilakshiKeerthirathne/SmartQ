import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartq/services/firebase_service.dart';



class QueueRepository {
  final FirebaseService _service = FirebaseService();

  Future<void> bookQueue({
    required String userId,
    required String doctorId,
    required Map<String, dynamic> doctorData,
    required bool isEmergency,
  }) {
    return _service.bookQueue(
      userId: userId,
      doctorId: doctorId,
      doctorData: doctorData,
      isEmergency: isEmergency,
    );
  }

  Stream<int> getQueueLength(String doctorId) {
    return _service.getQueueLength(doctorId);
  }

  Future<void> cancelTicket(String id) async {
    await FirebaseFirestore.instance
        .collection("tickets")
        .doc(id)
        .update({"status": "Cancelled"});
  }
}
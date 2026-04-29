import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartq/services/firebase_service.dart';


class DoctorRepository {
  final FirebaseService _service = FirebaseService();

  Future<void> addDoctor(String name, String dept, String queue) async {
    await _service.addDoctor(name, dept, queue);
  }

  Future<void> updateDoctor(String id, String name, String dept) async {
    await _service.updateDoctor(id, name, dept);
  }

  Future<void> deleteDoctor(String id) async {
    await _service.deleteDoctor(id);
  }

  Stream<QuerySnapshot> getDoctors() {
    return _service.getDoctors();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../repositories/doctor_repository.dart';

class DoctorViewModel extends ChangeNotifier {
  final DoctorRepository _repo = DoctorRepository();

  bool isLoading = false;
  String? error;

  Future<void> addDoctor(String name, String dept, String queue) async {
    if (name.isEmpty || dept.isEmpty || queue.isEmpty) {
      error = "Fill all fields";
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _repo.addDoctor(name, dept, queue);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateDoctor(String id, String name, String dept) async {
  await _repo.updateDoctor(id, name, dept);
}

  Future<void> deleteDoctor(String id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _repo.deleteDoctor(id);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Stream<QuerySnapshot> getDoctors() => _repo.getDoctors();
}
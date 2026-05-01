import 'package:flutter/material.dart';
import '../repositories/queue_repository.dart';

class QueueViewModel extends ChangeNotifier {
  final QueueRepository _repo = QueueRepository();

  bool isLoading = false;
  String? error;

  Stream<Object?>? get ticketsStream => null;

  Future<void> bookQueue({
    required String userId,
    required String doctorId,
    required Map<String, dynamic> doctorData,
    required bool isEmergency,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _repo.bookQueue(
        userId: userId,
        doctorId: doctorId,
        doctorData: doctorData,
        isEmergency: isEmergency,
      );
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Stream<int> getQueueLength(String doctorId) {
    return _repo.getQueueLength(doctorId);
  }

  Future<void> cancelTicket(String id) async {
    await _repo.cancelTicket(id);
  }
}
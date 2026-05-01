import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../services/firebase_service.dart';

class TicketViewModel extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  bool isLoading = false;
  String? error;

 
  Stream<List<TicketModel>> getAllTickets() {
    return _service.getAllTickets();
  }

  Stream<List<TicketModel>> getUserTickets(String userId) {
    return _service.getUserTickets(userId);
  }

  Future<void> cancelTicket(String id) async {
    try {
      isLoading = true;
      notifyListeners();

      await _service.cancelTicket(id);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }
}
import 'package:smartq/services/firebase_service.dart';

class AdminRepository {
  final FirebaseService _service = FirebaseService();

  Future<void> callNextTicket() async {
    await _service.callNextTicket();
  }

  Future<void> togglePause() async {
    await _service.togglePause();
  }
}
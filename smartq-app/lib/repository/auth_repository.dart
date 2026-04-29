import 'package:smartq/services/firebase_service.dart';

class AuthRepository {
  final FirebaseService _service = FirebaseService();

  Future<Map<String, dynamic>?> login(String email, String password) async {
    return await _service.login(email, password);
  }

  Future<void> register(String name, String email, String password) async {
    await _service.register(name, email, password);
  }

  Future<void> resetPassword(String email) async {
    await _service.resetPassword(email);
  }
}
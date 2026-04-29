import 'package:smartq/services/firebase_service.dart';

class ProfileRepository {
  final FirebaseService _service = FirebaseService();

  Future<void> updateName(String uid, String name) {
    return _service.updateName(uid, name);
  }
}
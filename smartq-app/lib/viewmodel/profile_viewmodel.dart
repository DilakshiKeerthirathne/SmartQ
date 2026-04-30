import 'package:flutter/material.dart';
import '../repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repo = ProfileRepository();

  bool isLoading = false;
  String? error;

  Future<void> updateName(String uid, String name) async {
    if (name.isEmpty) {
      error = "Name cannot be empty";
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _repo.updateName(uid, name);
      error = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
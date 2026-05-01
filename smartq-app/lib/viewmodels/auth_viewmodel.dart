import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  bool isLoading = false;
  String? errorMessage;

  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage = "Please fill all fields";
      notifyListeners();
      return null;
    }

    isLoading = true;
    notifyListeners();

    try {
      final userData = await _repo.login(email, password);

      if (userData == null) {
        errorMessage = "Login failed";
        return null;
      }

      return userData['role']; 

    } catch (e) {
      errorMessage = "Login error";
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  
  Future<bool> register(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage = "Please fill all fields";
      notifyListeners();
      return false;
    }

    if (!email.contains("@")) {
      errorMessage = "Invalid email";
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      errorMessage = "Password must be at least 6 characters";
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _repo.register(name, email, password);
      return true;
    } catch (e) {
      errorMessage = "Registration failed";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      errorMessage = "Enter your email";
      notifyListeners();
      return;
    }

    await _repo.resetPassword(email);
  }
}
import 'package:flutter/foundation.dart';
import 'package:printmax_app/core/token_storage.dart';
import 'package:printmax_app/features/auth/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();

  bool initializing = true;
  bool isAuthenticated = false;
  bool isLoading = false;
  String? token;
  String? error;

  Future<void> initialize() async {
    try {
      token = await TokenStorage.instance.getToken();
      isAuthenticated = token != null && token!.isNotEmpty;
    } finally {
      initializing = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String username, required String password}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final t = await _repo.login(username: username, password: password);
      token = t;
      await TokenStorage.instance.saveToken(t);
      isAuthenticated = true;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await TokenStorage.instance.clear();
    token = null;
    isAuthenticated = false;
    notifyListeners();
  }
}


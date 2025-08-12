import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login() async {
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    notifyListeners();
  }
}
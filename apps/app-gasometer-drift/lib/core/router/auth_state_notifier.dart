import 'package:flutter/foundation.dart';

/// Notificador para mudanças no estado de autenticação
/// Usado pelo GoRouter para reagir a mudanças de autenticação
class AuthStateNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void updateAuthState(bool isAuthenticated) {
    if (_isAuthenticated != isAuthenticated) {
      _isAuthenticated = isAuthenticated;
      notifyListeners();
    }
  }
}

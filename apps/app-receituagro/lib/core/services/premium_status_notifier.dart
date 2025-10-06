import 'dart:async';
import 'package:flutter/foundation.dart';

/// Stub for PremiumStatusNotifier - removed service
/// This stub provides the same interface for compatibility
class PremiumStatusNotifier extends ChangeNotifier {
  static final PremiumStatusNotifier _instance = PremiumStatusNotifier._();
  static PremiumStatusNotifier get instance => _instance;
  
  PremiumStatusNotifier._();
  
  bool _isPremium = false;
  final StreamController<bool> _streamController = StreamController<bool>.broadcast();
  
  bool get isPremium => _isPremium;
  Stream<bool> get premiumStatusStream => _streamController.stream;
  
  void updatePremiumStatus(bool isPremium) {
    if (_isPremium != isPremium) {
      _isPremium = isPremium;
      notifyListeners();
      _streamController.add(isPremium);
    }
  }
  
  Future<void> checkPremiumStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

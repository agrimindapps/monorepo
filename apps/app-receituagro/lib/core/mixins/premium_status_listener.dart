import 'dart:async';
import 'package:flutter/material.dart';
import '../services/premium_status_notifier.dart';

/// Stub mixin for PremiumStatusListener - removed service
/// This stub provides the same interface for compatibility
mixin PremiumStatusListener<T extends StatefulWidget> on State<T> {
  StreamSubscription<bool>? _premiumStatusSubscription;
  bool _isPremium = false;
  
  bool get isPremium => _isPremium;
  
  @override
  void initState() {
    super.initState();
    _initializePremiumListener();
  }
  
  void _initializePremiumListener() {
    _isPremium = PremiumStatusNotifier.instance.isPremium;
    _premiumStatusSubscription = PremiumStatusNotifier.instance.premiumStatusStream
        .listen((isPremium) {
      if (mounted) {
        setState(() {
          _isPremium = isPremium;
        });
        onPremiumStatusChanged(isPremium);
      }
    });
  }
  
  /// Override this method to handle premium status changes
  void onPremiumStatusChanged(bool isPremium) {
  }
  
  @override
  void dispose() {
    _premiumStatusSubscription?.cancel();
    super.dispose();
  }
}

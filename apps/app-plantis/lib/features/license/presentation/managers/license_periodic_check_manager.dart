import 'dart:async';

import 'package:flutter/material.dart';

/// Gerencia checagem periódica de expiração de licença
/// SRP: Isolates periodic license check logic
class LicensePeriodicCheckManager {
  Timer? _periodicTimer;
  final Duration checkInterval;
  VoidCallback? _onCheckCallback;

  LicensePeriodicCheckManager({this.checkInterval = const Duration(hours: 1)});

  /// Inicia verificações periódicas
  void startPeriodicCheck(VoidCallback onCheck) {
    _onCheckCallback = onCheck;
    _periodicTimer = Timer.periodic(checkInterval, (_) {
      onCheck();
    });
  }

  /// Faz verificação imediata
  void checkNow() {
    _onCheckCallback?.call();
  }

  /// Para verificações periódicas
  void stop() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Retorna se está ativo
  bool get isActive => _periodicTimer != null;

  /// Dispose
  void dispose() {
    stop();
  }
}

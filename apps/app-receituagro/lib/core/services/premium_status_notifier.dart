import 'dart:async';

import 'package:flutter/material.dart';

/// Sistema de notificação global para mudanças no status premium
/// Permite que todas as telas recebam atualizações em tempo real
/// quando o status premium muda (ativação/desativação de licença teste)
class PremiumStatusNotifier {
  static final PremiumStatusNotifier _instance = PremiumStatusNotifier._internal();
  
  static PremiumStatusNotifier get instance => _instance;
  
  PremiumStatusNotifier._internal();

  final StreamController<bool> _premiumStatusController = 
      StreamController<bool>.broadcast();

  /// Stream de mudanças no status premium
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  /// Notifica todas as telas que o status premium mudou
  void notifyStatusChanged(bool isPremium) {
    debugPrint('🔔 PremiumStatusNotifier: Broadcasting premium status = $isPremium');
    _premiumStatusController.add(isPremium);
  }

  /// Libera recursos quando não precisar mais
  void dispose() {
    _premiumStatusController.close();
  }
}

/// Mixin para widgets que precisam escutar mudanças no status premium
mixin PremiumStatusListener<T extends StatefulWidget> on State<T> {
  StreamSubscription<bool>? _premiumStatusSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToPremiumChanges();
  }

  @override
  void dispose() {
    _premiumStatusSubscription?.cancel();
    super.dispose();
  }

  /// Método que será chamado quando o status premium mudar
  void onPremiumStatusChanged(bool isPremium);

  /// Subscreve às mudanças de status premium
  void _subscribeToPremiumChanges() {
    _premiumStatusSubscription = PremiumStatusNotifier.instance
        .premiumStatusStream
        .listen((isPremium) {
      if (mounted) {
        debugPrint('📱 Widget ${widget.runtimeType} received premium status: $isPremium');
        onPremiumStatusChanged(isPremium);
      }
    });
  }
}
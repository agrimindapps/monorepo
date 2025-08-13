// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

/// Mock service para substituir o AdService no módulo receituagro
/// Remove completamente a funcionalidade de anúncios
class MockAdService extends GetxService {
  static MockAdService get to => Get.find();

  /// Inicialização vazia (anúncios desabilitados)
  void initializeAd() {
    _logDebug('Publicidade desabilitada - initializeAd() ignorado');
  }

  /// Sempre retorna false (não há anúncios para mostrar)
  bool canShowAd() {
    _logDebug('canShowAd() retornando false - anúncios desabilitados');
    return false;
  }

  /// Sempre retorna false (usuário não tem horas premium por anúncios)
  bool hasUserPremiumHours() {
    _logDebug('hasUserPremiumHours() retornando false - anúncios desabilitados');
    return false;
  }

  /// Não mostra anúncios - chama onAdFailed se fornecido
  void showAd({
    required void Function() onRewardEarned,
    void Function()? onAdFailed,
  }) {
    _logDebug('showAd() chamado mas anúncios estão desabilitados');
    onAdFailed?.call();
  }

  /// Retorna status indicando que anúncios estão desabilitados
  Map<String, dynamic> getAdStatus() {
    return {
      'enabled': false,
      'reason': 'Ads disabled for this app module',
      'isLoaded': false,
      'hasAd': false,
      'premiumHours': 0,
    };
  }

  /// Sempre retorna notAvailable (anúncios não disponíveis)
  AdWatchResult getWatchStrategy() {
    _logDebug('getWatchStrategy() retornando notAvailable - anúncios desabilitados');
    return AdWatchResult.notAvailable;
  }

  /// Sistema de logging condicional
  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('🚫 [MOCK_AD_SERVICE] $message');
    }
  }
}

/// Enum mantido para compatibilidade
enum AdWatchResult {
  canWatch,
  tryLater,
  notAvailable,
}

/// Extension mantida para compatibilidade
extension AdWatchResultExtension on AdWatchResult {
  bool get canWatch => this == AdWatchResult.canWatch;
  bool get shouldTryLater => this == AdWatchResult.tryLater;
  bool get isNotAvailable => this == AdWatchResult.notAvailable;
}

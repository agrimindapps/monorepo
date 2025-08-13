// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../services/mock_admob_service.dart';

class AdService extends GetxService {
  static AdService get to => Get.find();

  // Inicia o processo de publicidade (desabilitado)
  void initializeAd() {
    _logDebug('Publicidade desabilitada - initializeAd() ignorado');
    // MockAdmobService não faz nada
  }

  // Verifica se o anúncio pode ser exibido (sempre false)
  bool canShowAd() {
    final isLoaded = MockAdmobService.to.rewardedAdIsLoaded.value;
    final hasAd = MockAdmobService.to.rewardedAd != null;
    
    _logDebug('Verificando disponibilidade do anúncio (anúncios desabilitados):');
    _logDebug('   - rewardedAdIsLoaded: $isLoaded');
    _logDebug('   - rewardedAd é null: ${!hasAd}');
    _logDebug('   - premiumAdHours: ${MockAdmobService.to.premiumAdHours.value}');
    
    return false; // Sempre false - anúncios desabilitados
  }

  // Verifica se o usuário tem horas premium (sempre false)
  bool hasUserPremiumHours() {
    return false; // Sempre false - anúncios desabilitados
  }

  // Mostra o anúncio (desabilitado)
  void showAd({
    required VoidCallback onRewardEarned,
    VoidCallback? onAdFailed,
  }) {
    _logDebug('showAd() chamado mas anúncios estão desabilitados');
    onAdFailed?.call();
  }

  
  // Sistema de logging condicional
  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('🎬 [AD_SERVICE] $message');
    }
  }

  // Retorna o estado atual dos anúncios para debugging (anúncios desabilitados)
  Map<String, dynamic> getAdStatus() {
    return {
      'enabled': false,
      'reason': 'Ads disabled for this app module',
      'isLoaded': false,
      'hasAd': false,
      'premiumHours': 0,
    };
  }

  // Estratégia principal para assistir publicidade (anúncios desabilitados)
  AdWatchResult getWatchStrategy() {
    _logDebug('getWatchStrategy() retornando notAvailable - anúncios desabilitados');
    return AdWatchResult.notAvailable;
  }
}

enum AdWatchResult {
  canWatch,
  tryLater,
  notAvailable,
}

// Extension para facilitar o uso
extension AdWatchResultExtension on AdWatchResult {
  bool get canWatch => this == AdWatchResult.canWatch;
  bool get shouldTryLater => this == AdWatchResult.tryLater;
  bool get isNotAvailable => this == AdWatchResult.notAvailable;
}

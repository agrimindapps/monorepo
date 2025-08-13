// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

/// Mock service para substituir o AdmobService no módulo receituagro
/// Remove completamente a dependência de anúncios mantendo a interface
class MockAdmobService extends GetxService {
  static MockAdmobService get to => Get.find();

  // Propriedades reativas que simulam o comportamento sem funcionalidade real
  final RxBool isPremiumAd = false.obs;
  final RxInt premiumAdHours = 0.obs;
  final RxBool rewardedAdIsLoaded = false.obs;

  // Propriedade que sempre retorna null (sem anúncios)
  dynamic get rewardedAd => null;

  /// Inicializa o serviço mock (não faz nada)
  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      debugPrint('🚫 [MOCK_ADMOB] Serviço de anúncios desabilitado para este app');
    }
  }

  /// Método de inicialização vazio
  void init() {
    // Não faz nada - anúncios desabilitados
  }

  /// Sempre retorna false (usuário não tem premium por anúncios)
  Future<bool> checkIsPremiumAd() async {
    return false;
  }

  /// Não define premium por anúncios (método vazio)
  void setPremiumAd(int hours) {
    // Não faz nada - anúncios desabilitados
  }

  /// Não carrega anúncios (método vazio)
  Future<void> getPremiumAd() async {
    // Não faz nada - anúncios desabilitados
  }

  /// Retorna informações de debug indicando que anúncios estão desabilitados
  Map<String, dynamic> getAdStatus() {
    return {
      'enabled': false,
      'reason': 'AdMob disabled for this app module',
      'isPremiumAd': false,
      'premiumAdHours': 0,
      'rewardedAdIsLoaded': false,
    };
  }
}

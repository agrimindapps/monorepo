import 'package:flutter/foundation.dart';

import '../../../domain/entities/ads/ad_config_entity.dart';
import '../../../domain/entities/ads/ad_sense_config_entity.dart';
import '../../../domain/entities/ads/ad_unit_entity.dart';

/// Configuração unificada de anúncios para apps multiplataforma
/// 
/// Combina configurações de AdMob (mobile) e AdSense (web) em uma única
/// entidade para facilitar a configuração em apps Flutter multiplataforma.
/// 
/// Exemplo de uso:
/// ```dart
/// final adsConfig = UnifiedAdsConfig(
///   // Mobile (Android/iOS)
///   mobileConfig: AdConfigEntity.production(
///     appId: 'ca-app-pub-xxx',
///     productionAdUnitIds: {
///       AdType.banner: 'ca-app-pub-xxx/banner',
///       AdType.interstitial: 'ca-app-pub-xxx/interstitial',
///     },
///   ),
///   // Web
///   webConfig: AdSenseConfigEntity.production(
///     clientId: 'ca-pub-xxx',
///     adSlots: {
///       'banner_top': '1234567890',
///       'banner_bottom': '0987654321',
///     },
///   ),
/// );
/// 
/// // Em seguida, inicialize:
/// await adsConfig.initialize(ref);
/// ```
class UnifiedAdsConfig {
  /// Configuração para Mobile (Google Mobile Ads / AdMob)
  final AdConfigEntity? mobileConfig;

  /// Configuração para Web (Google AdSense)
  final AdSenseConfigEntity? webConfig;

  /// Se está em modo de teste
  final bool testMode;

  const UnifiedAdsConfig({
    this.mobileConfig,
    this.webConfig,
    this.testMode = false,
  });

  /// Cria configuração de desenvolvimento com ads de teste
  factory UnifiedAdsConfig.development({
    String? mobileAppId,
    String? webClientId,
  }) {
    return UnifiedAdsConfig(
      mobileConfig: mobileAppId != null
          ? AdConfigEntity.development(
              appId: mobileAppId,
              testAdUnitIds: _getTestMobileAdUnits(),
            )
          : null,
      webConfig: webClientId != null
          ? AdSenseConfigEntity.development(
              clientId: webClientId,
            )
          : null,
      testMode: true,
    );
  }

  /// Cria configuração de produção
  factory UnifiedAdsConfig.production({
    AdConfigEntity? mobileConfig,
    AdSenseConfigEntity? webConfig,
  }) {
    return UnifiedAdsConfig(
      mobileConfig: mobileConfig,
      webConfig: webConfig,
      testMode: false,
    );
  }

  /// Obtém a configuração apropriada para a plataforma atual
  bool get hasMobileConfig => mobileConfig != null;
  bool get hasWebConfig => webConfig != null;

  /// Verifica se há configuração para a plataforma atual
  bool get hasCurrentPlatformConfig {
    if (kIsWeb) {
      return hasWebConfig;
    }
    return hasMobileConfig;
  }

  /// Obtém configuração mobile se disponível
  AdConfigEntity? get currentMobileConfig => mobileConfig;

  /// Obtém configuração web se disponível
  AdSenseConfigEntity? get currentWebConfig => webConfig;

  @override
  String toString() => 'UnifiedAdsConfig('
      'mobile: ${mobileConfig != null}, '
      'web: ${webConfig != null}, '
      'testMode: $testMode)';
}

/// Retorna IDs de teste padrão do Google para desenvolvimento
Map<AdType, String> _getTestMobileAdUnits() {
  // IDs de teste oficiais do Google Mobile Ads
  return const {
    AdType.banner: 'ca-app-pub-3940256099942544/6300978111',
    AdType.interstitial: 'ca-app-pub-3940256099942544/1033173712',
    AdType.rewarded: 'ca-app-pub-3940256099942544/5224354917',
    AdType.rewardedInterstitial: 'ca-app-pub-3940256099942544/5354046379',
    AdType.appOpen: 'ca-app-pub-3940256099942544/9257395921',
  };
}

/// Slots de teste para AdSense (desenvolvimento)
class TestAdSenseSlots {
  TestAdSenseSlots._();

  /// Slot de teste para banner horizontal
  static const String bannerTop = 'test-banner-top';
  
  /// Slot de teste para banner inferior
  static const String bannerBottom = 'test-banner-bottom';
  
  /// Slot de teste para in-article
  static const String inArticle = 'test-in-article';
  
  /// Slot de teste para in-feed
  static const String inFeed = 'test-in-feed';
}

/// Helper para obter IDs de anúncio corretos baseado na plataforma
class AdUnitHelper {
  AdUnitHelper._();

  /// Obtém o ID do banner para a plataforma atual
  /// 
  /// [mobileAdUnitId] - ID do AdMob para mobile
  /// [webAdSlot] - Slot do AdSense para web
  static String getBannerId({
    required String mobileAdUnitId,
    required String webAdSlot,
  }) {
    if (kIsWeb) {
      return webAdSlot;
    }
    return mobileAdUnitId;
  }

  /// Verifica se está rodando em ambiente de teste
  static bool get isTestEnvironment {
    return kDebugMode;
  }

  /// Obtém um ID de teste baseado no tipo de anúncio
  static String getTestAdUnitId(AdType type) {
    switch (type) {
      case AdType.banner:
        return 'ca-app-pub-3940256099942544/6300978111';
      case AdType.interstitial:
        return 'ca-app-pub-3940256099942544/1033173712';
      case AdType.rewarded:
        return 'ca-app-pub-3940256099942544/5224354917';
      case AdType.rewardedInterstitial:
        return 'ca-app-pub-3940256099942544/5354046379';
      case AdType.appOpen:
        return 'ca-app-pub-3940256099942544/9257395921';
      case AdType.native:
        return 'ca-app-pub-3940256099942544/2247696110';
    }
  }
}

// ============================================================================
// ADS - Sistema de Anúncios Multiplataforma
// ============================================================================
// 
// Este módulo fornece suporte unificado para anúncios em Flutter:
// - Mobile (Android/iOS): Google Mobile Ads (AdMob)
// - Web: Google AdSense
//
// Estrutura:
// - Domain: Entidades e interfaces
// - Infrastructure: Serviços de implementação
// - Presentation: Widgets prontos para uso
// - Riverpod: Providers para gerenciamento de estado
//
// Uso básico:
// ```dart
// // No main.dart
// await AdsInitializer.initialize(
//   mobileAppId: 'ca-app-pub-xxx',
//   webClientId: 'ca-pub-xxx',
// );
//
// // Em qualquer widget
// UnifiedAdBannerWidget(
//   webConfig: WebAdConfig(slotName: 'banner', adSlot: '123'),
//   mobileConfig: MobileAdConfig.banner(adUnitId: 'ca-app-pub-xxx/banner'),
// )
// ```
// ============================================================================

// Domain - Entidades
export '../../../domain/entities/ads/ad_config_entity.dart';
export '../../../domain/entities/ads/ad_event_entity.dart';
export '../../../domain/entities/ads/ad_frequency_config.dart';
export '../../../domain/entities/ads/ad_sense_config_entity.dart';
export '../../../domain/entities/ads/ad_unit_entity.dart';
// Domain - Interfaces
export '../../../domain/repositories/i_ads_repository.dart';
export '../../../domain/repositories/i_web_ads_repository.dart';
// Presentation - Widgets
export '../../../presentation/widgets/ads/ad_banner_widget.dart';
export '../../../presentation/widgets/ads/unified_ad_banner_widget.dart';
// Web widgets devem ser importados separadamente em projetos web
// export '../../../presentation/widgets/ads/web/adsense_banner_widget.dart';

// Riverpod - Providers
export '../../../riverpod/domain/ads/ads_providers.dart';
export '../../../riverpod/domain/ads/web_ads_providers.dart';
// Infrastructure - Services Mobile (AdMob)
export 'google_mobile_ads_service.dart';
export 'specialized_services/ad_lifecycle_manager.dart';
export 'specialized_services/app_open_ad_service.dart';
export 'specialized_services/banner_ad_service.dart';
export 'specialized_services/interstitial_ad_service.dart';
export 'specialized_services/rewarded_ad_service.dart';
export 'specialized_services/rewarded_interstitial_ad_service.dart';
// Infrastructure - Configuração Unificada
export 'unified_ads_config.dart';
// Infrastructure - Services Web (AdSense)
// Usa importação condicional para selecionar implementação correta
export 'web/adsense_service.dart';

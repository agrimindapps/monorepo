import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/ads/ad_config_entity.dart';
import '../../../domain/entities/ads/ad_unit_entity.dart';
import '../../../domain/repositories/i_ads_repository.dart';
import '../../../infrastructure/services/ads/google_mobile_ads_service.dart';
import '../../../infrastructure/services/ads/specialized_services/ad_config_service.dart';
import '../../../infrastructure/services/ads/specialized_services/ad_frequency_manager.dart';
import '../../../infrastructure/services/ads/specialized_services/ad_lifecycle_manager.dart';
import '../../../infrastructure/services/ads/specialized_services/banner_ad_service.dart';
import '../../../infrastructure/services/ads/specialized_services/interstitial_ad_service.dart';
import '../../../infrastructure/services/ads/specialized_services/rewarded_ad_service.dart';
import '../../../infrastructure/services/ads/specialized_services/rewarded_interstitial_ad_service.dart';
import '../../../infrastructure/services/ads/specialized_services/app_open_ad_service.dart';
import '../../../infrastructure/services/ads/specialized_services/ad_preloader_service.dart';

part 'ads_providers.g.dart';

// ===== Specialized Services Providers =====

/// Ad Config Service provider
@riverpod
AdConfigService adConfigService(AdConfigServiceRef ref) {
  final service = AdConfigService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Ad Frequency Manager provider
@riverpod
AdFrequencyManager adFrequencyManager(AdFrequencyManagerRef ref) {
  final manager = AdFrequencyManager();
  ref.onDispose(() => manager.dispose());
  return manager;
}

/// Ad Lifecycle Manager provider
@riverpod
AdLifecycleManager adLifecycleManager(AdLifecycleManagerRef ref) {
  return AdLifecycleManager();
}

/// Banner Ad Service provider
@riverpod
BannerAdService bannerAdService(BannerAdServiceRef ref) {
  return BannerAdService();
}

/// Interstitial Ad Service provider
@riverpod
InterstitialAdService interstitialAdService(InterstitialAdServiceRef ref) {
  final service = InterstitialAdService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Rewarded Ad Service provider
@riverpod
RewardedAdService rewardedAdService(RewardedAdServiceRef ref) {
  final service = RewardedAdService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Rewarded Interstitial Ad Service provider
@riverpod
RewardedInterstitialAdService rewardedInterstitialAdService(
  RewardedInterstitialAdServiceRef ref,
) {
  final service = RewardedInterstitialAdService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// App Open Ad Service provider
@riverpod
AppOpenAdService appOpenAdService(AppOpenAdServiceRef ref) {
  final service = AppOpenAdService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Ad Preloader Service provider
@riverpod
AdPreloaderService adPreloaderService(AdPreloaderServiceRef ref) {
  return AdPreloaderService(
    configService: ref.watch(adConfigServiceProvider),
    interstitialService: ref.watch(interstitialAdServiceProvider),
    rewardedService: ref.watch(rewardedAdServiceProvider),
    rewardedInterstitialService: ref.watch(rewardedInterstitialAdServiceProvider),
    appOpenService: ref.watch(appOpenAdServiceProvider),
  );
}

// ===== Main Repository Provider =====

/// Main Ads Repository provider
/// This is the primary provider that apps should use
@riverpod
IAdsRepository adsRepository(AdsRepositoryRef ref) {
  final service = GoogleMobileAdsService(
    configService: ref.watch(adConfigServiceProvider),
    frequencyManager: ref.watch(adFrequencyManagerProvider),
    lifecycleManager: ref.watch(adLifecycleManagerProvider),
    bannerService: ref.watch(bannerAdServiceProvider),
    interstitialService: ref.watch(interstitialAdServiceProvider),
    rewardedService: ref.watch(rewardedAdServiceProvider),
    rewardedInterstitialService: ref.watch(rewardedInterstitialAdServiceProvider),
    appOpenService: ref.watch(appOpenAdServiceProvider),
    preloaderService: ref.watch(adPreloaderServiceProvider),
    // Premium status checker can be injected here
    // premiumStatusChecker: () async {
    //   final revenueCat = ref.read(revenueCatServiceProvider);
    //   return revenueCat.isPremium;
    // },
  );

  ref.onDispose(() => service.dispose());

  return service;
}

// ===== State Providers =====

/// Provider to check if ads should be shown based on premium status
/// Integrates with RevenueCat (to be connected by app)
@riverpod
Future<bool> shouldShowAds(ShouldShowAdsRef ref, String placement) async {
  final repository = ref.watch(adsRepositoryProvider);

  final result = await repository.shouldShowAd(placement: placement);

  return result.fold(
    (failure) => false, // Don't show ads on error
    (canShow) => canShow,
  );
}

/// Provider for ad show count
@riverpod
Future<int> adShowCount(AdShowCountRef ref, String placement) async {
  final repository = ref.watch(adsRepositoryProvider);

  final result = await repository.getAdShowCount(placement: placement);

  return result.fold(
    (failure) => 0,
    (count) => count,
  );
}

/// Provider for ad preload status
@riverpod
Map<AdType, bool> adPreloadStatus(AdPreloadStatusRef ref) {
  final preloader = ref.watch(adPreloaderServiceProvider);
  return preloader.getPreloadStatus();
}

/// Provider for checking if specific ad type is ready
@riverpod
bool isAdReady(IsAdReadyRef ref, AdType adType) {
  final repository = ref.watch(adsRepositoryProvider);

  switch (adType) {
    case AdType.interstitial:
      return repository.isInterstitialReady;
    case AdType.rewarded:
      return repository.isRewardedReady;
    case AdType.rewardedInterstitial:
      return repository.isRewardedInterstitialReady;
    case AdType.appOpen:
      return repository.isAppOpenReady;
    case AdType.banner:
    case AdType.native:
      return false; // Banners are loaded on-demand
  }
}

/// Provider for ad statistics
@riverpod
Map<String, dynamic> adStatistics(AdStatisticsRef ref) {
  final repository = ref.watch(adsRepositoryProvider) as GoogleMobileAdsService;
  return repository.getStatistics();
}

/// Provider for current ad configuration
@riverpod
AdConfigEntity? currentAdConfig(CurrentAdConfigRef ref) {
  final configService = ref.watch(adConfigServiceProvider);
  return configService.currentConfig;
}

/// Provider for test mode status
@riverpod
bool isTestMode(IsTestModeRef ref) {
  final configService = ref.watch(adConfigServiceProvider);
  return configService.isTestMode;
}

// ===== Notifier for Ad Events (Optional - for analytics integration) =====

/// State class for ad events
class AdEventsState {
  final List<String> recentEvents;
  final int totalEvents;

  const AdEventsState({
    this.recentEvents = const [],
    this.totalEvents = 0,
  });

  AdEventsState copyWith({
    List<String>? recentEvents,
    int? totalEvents,
  }) {
    return AdEventsState(
      recentEvents: recentEvents ?? this.recentEvents,
      totalEvents: totalEvents ?? this.totalEvents,
    );
  }
}

/// Notifier for tracking ad events
@riverpod
class AdEventsNotifier extends _$AdEventsNotifier {
  @override
  AdEventsState build() {
    return const AdEventsState();
  }

  void recordEvent(String event) {
    final newEvents = [...state.recentEvents, event];
    // Keep only last 50 events
    final recentEvents = newEvents.length > 50
        ? newEvents.sublist(newEvents.length - 50)
        : newEvents;

    state = state.copyWith(
      recentEvents: recentEvents,
      totalEvents: state.totalEvents + 1,
    );
  }

  void clearEvents() {
    state = const AdEventsState();
  }
}

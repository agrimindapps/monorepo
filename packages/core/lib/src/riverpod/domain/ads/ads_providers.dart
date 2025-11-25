import 'package:riverpod/riverpod.dart';

import '../../../domain/repositories/i_ads_repository.dart';
import '../../../infrastructure/services/ads/google_mobile_ads_service.dart';
import '../../../infrastructure/services/ads/specialized_services/ad_lifecycle_manager.dart';
import '../../../infrastructure/services/ads/specialized_services/app_open_ad_service.dart';
import '../../../infrastructure/services/ads/specialized_services/banner_ad_service.dart';
import '../../../infrastructure/services/ads/specialized_services/interstitial_ad_service.dart';
import '../../../infrastructure/services/ads/specialized_services/rewarded_ad_service.dart';
import '../../../infrastructure/services/ads/specialized_services/rewarded_interstitial_ad_service.dart';

// ===== Specialized Services Providers =====

final _adLifecycleManagerProvider = Provider<AdLifecycleManager>((ref) {
  return AdLifecycleManager();
});

final _bannerAdServiceProvider = Provider<BannerAdService>((ref) {
  return BannerAdService();
});

final _interstitialAdServiceProvider = Provider<InterstitialAdService>((ref) {
  final service = InterstitialAdService();
  ref.onDispose(() => service.dispose());
  return service;
});

final _rewardedAdServiceProvider = Provider<RewardedAdService>((ref) {
  final service = RewardedAdService();
  ref.onDispose(() => service.dispose());
  return service;
});

final _rewardedInterstitialAdServiceProvider =
    Provider<RewardedInterstitialAdService>((ref) {
      final service = RewardedInterstitialAdService();
      ref.onDispose(() => service.dispose());
      return service;
    });

final _appOpenAdServiceProvider = Provider<AppOpenAdService>((ref) {
  final service = AppOpenAdService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ===== Main Repository Provider =====

/// Main Ads Repository provider
/// This is the primary provider that apps should use
/// 
/// Compatible with google_mobile_ads ^6.0.0
final adsRepositoryProvider = Provider<IAdsRepository>((ref) {
  final service = GoogleMobileAdsService(
    lifecycleManager: ref.watch(_adLifecycleManagerProvider),
    bannerService: ref.watch(_bannerAdServiceProvider),
    interstitialService: ref.watch(_interstitialAdServiceProvider),
    rewardedService: ref.watch(_rewardedAdServiceProvider),
    rewardedInterstitialService: ref.watch(
      _rewardedInterstitialAdServiceProvider,
    ),
    appOpenService: ref.watch(_appOpenAdServiceProvider),
  );
  ref.onDispose(() => service.dispose());
  return service;
});

// ===== State Providers =====

/// Provider to check if ads should be shown based on premium status
/// Integrates with RevenueCat (to be connected by app)
final shouldShowAdsProvider = FutureProvider.family<bool, String>((
  ref,
  placement,
) async {
  final repository = ref.watch(adsRepositoryProvider);
  final result = await repository.shouldShowAd(placement: placement);
  return result.fold(
    (failure) => false, // Don't show ads on error
    (canShow) => canShow,
  );
});

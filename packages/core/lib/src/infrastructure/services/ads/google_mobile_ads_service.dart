import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../domain/repositories/i_ads_repository.dart';
import '../../../shared/utils/ads_failures.dart';
import '../../../shared/utils/failure.dart';
import 'specialized_services/ad_lifecycle_manager.dart';
import 'specialized_services/app_open_ad_service.dart';
import 'specialized_services/banner_ad_service.dart';
import 'specialized_services/interstitial_ad_service.dart';
import 'specialized_services/rewarded_ad_service.dart';
import 'specialized_services/rewarded_interstitial_ad_service.dart';

/// Main Google Mobile Ads Service implementing the repository interface
/// Follows Facade Pattern - coordinates all specialized services
/// This is the single entry point for all ad operations
///
/// Compatible with google_mobile_ads ^6.0.0
class GoogleMobileAdsService implements IAdsRepository {
  final AdLifecycleManager _lifecycleManager;
  final BannerAdService _bannerService;
  final InterstitialAdService _interstitialService;
  final RewardedAdService _rewardedService;
  final RewardedInterstitialAdService _rewardedInterstitialService;
  final AppOpenAdService _appOpenService;

  bool _isInitialized = false;
  
  /// Tracks ad show counts per placement for frequency capping
  final Map<String, int> _adShowCounts = {};
  
  /// Tracks last ad show time per placement
  final Map<String, DateTime> _lastAdShowTime = {};

  /// Optional: Premium status checker (integrate with RevenueCat)
  Future<bool> Function()? premiumStatusChecker;
  
  /// Minimum interval between ads (default: 60 seconds)
  Duration minAdInterval;

  GoogleMobileAdsService({
    required AdLifecycleManager lifecycleManager,
    required BannerAdService bannerService,
    required InterstitialAdService interstitialService,
    required RewardedAdService rewardedService,
    required RewardedInterstitialAdService rewardedInterstitialService,
    required AppOpenAdService appOpenService,
    this.premiumStatusChecker,
    this.minAdInterval = const Duration(seconds: 60),
  }) : _lifecycleManager = lifecycleManager,
       _bannerService = bannerService,
       _interstitialService = interstitialService,
       _rewardedService = rewardedService,
       _rewardedInterstitialService = rewardedInterstitialService,
       _appOpenService = appOpenService;

  // ===== Initialization =====

  @override
  Future<Either<Failure, void>> initialize({required String appId}) async {
    if (_isInitialized) {
      return Left(AdInitializationFailure.alreadyInitialized());
    }

    try {
      // Initialize Google Mobile Ads SDK (v6.0.0: returns Future<void>)
      await MobileAds.instance.initialize();

      _isInitialized = true;

      return const Right(null);
    } catch (e) {
      return Left(
        AdInitializationFailure(
          'Failed to initialize Google Mobile Ads: ${e.toString()}',
          code: 'INIT_FAILED',
          details: e,
        ),
      );
    }
  }

  // ===== Banner Ads =====

  @override
  Future<Either<Failure, BannerAd>> loadBannerAd({
    required String adUnitId,
    required AdSize size,
  }) async {
    if (!_isInitialized) {
      return const Left(AdInitializationFailure('Ads not initialized'));
    }

    // Check premium status
    if (await _shouldBlockForPremium()) {
      return const Left(AdPremiumBlockFailure());
    }

    return _bannerService.loadBanner(
      adUnitId: adUnitId,
      size: size,
      onAdLoaded: () {
        // Track in lifecycle manager if needed
      },
    );
  }

  // ===== Interstitial Ads =====

  @override
  Future<Either<Failure, void>> loadInterstitialAd({
    required String adUnitId,
  }) async {
    if (!_isInitialized) {
      return const Left(AdInitializationFailure('Ads not initialized'));
    }

    return _interstitialService.load(adUnitId: adUnitId);
  }

  @override
  Future<Either<Failure, void>> showInterstitialAd() async {
    if (!_isInitialized) {
      return const Left(AdInitializationFailure('Ads not initialized'));
    }

    // Check premium status
    if (await _shouldBlockForPremium()) {
      return const Left(AdPremiumBlockFailure());
    }

    // Check frequency
    final canShowResult = await shouldShowAd(placement: 'interstitial');
    if (canShowResult.isLeft()) {
      return canShowResult;
    }

    final canShow = canShowResult.getOrElse(() => false);
    if (!canShow) {
      return Left(AdFrequencyCapFailure.tooSoon());
    }

    // Show ad
    final result = await _interstitialService.show(
      onAdDismissedFullScreenContent: () {
        recordAdShown(placement: 'interstitial');
      },
    );

    return result;
  }

  @override
  bool get isInterstitialReady => _interstitialService.isReady;

  // ===== Rewarded Ads =====

  @override
  Future<Either<Failure, void>> loadRewardedAd({
    required String adUnitId,
  }) async {
    if (!_isInitialized) {
      return const Left(AdInitializationFailure('Ads not initialized'));
    }

    return _rewardedService.load(adUnitId: adUnitId);
  }

  @override
  Future<Either<Failure, RewardedAd?>> showRewardedAd() async {
    if (!_isInitialized) {
      return const Left(AdInitializationFailure('Ads not initialized'));
    }

    // Rewarded ads can be shown to premium users (user-initiated)
    // But still check frequency
    final canShowResult = await shouldShowAd(placement: 'rewarded');
    if (canShowResult.isLeft()) {
      return canShowResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    }

    final canShow = canShowResult.getOrElse(() => false);
    if (!canShow) {
      return Left(AdFrequencyCapFailure.tooSoon());
    }

    // Show ad
    final result = await _rewardedService.show(
      onUserEarnedReward: (ad, reward) {
        // Reward will be handled by caller
      },
      onAdDismissedFullScreenContent: () {
        recordAdShown(placement: 'rewarded');
      },
    );

    return result;
  }

  @override
  bool get isRewardedReady => _rewardedService.isReady;

  // ===== Rewarded Interstitial Ads =====

  @override
  Future<Either<Failure, void>> loadRewardedInterstitialAd({
    required String adUnitId,
  }) async {
    if (!_isInitialized) {
      return const Left(AdInitializationFailure('Ads not initialized'));
    }

    return _rewardedInterstitialService.load(adUnitId: adUnitId);
  }

  @override
  Future<Either<Failure, RewardedInterstitialAd?>>
  showRewardedInterstitialAd() async {
    if (!_isInitialized) {
      return const Left(AdInitializationFailure('Ads not initialized'));
    }

    // Check frequency
    final canShowResult = await shouldShowAd(
      placement: 'rewarded_interstitial',
    );
    if (canShowResult.isLeft()) {
      return canShowResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    }

    final canShow = canShowResult.getOrElse(() => false);
    if (!canShow) {
      return Left(AdFrequencyCapFailure.tooSoon());
    }

    // Show ad
    final result = await _rewardedInterstitialService.show(
      onUserEarnedReward: (ad, reward) {
        // Reward will be handled by caller
      },
      onAdDismissedFullScreenContent: () {
        recordAdShown(placement: 'rewarded_interstitial');
      },
    );

    return result;
  }

  @override
  bool get isRewardedInterstitialReady => _rewardedInterstitialService.isReady;

  // ===== App Open Ads =====

  @override
  Future<Either<Failure, void>> loadAppOpenAd({
    required String adUnitId,
  }) async {
    if (!_isInitialized) {
      return const Left(AdInitializationFailure('Ads not initialized'));
    }

    return _appOpenService.load(adUnitId: adUnitId);
  }

  @override
  Future<Either<Failure, void>> showAppOpenAd() async {
    if (!_isInitialized) {
      return const Left(AdInitializationFailure('Ads not initialized'));
    }

    // Check premium status
    if (await _shouldBlockForPremium()) {
      return const Left(AdPremiumBlockFailure());
    }

    // Check frequency
    final canShowResult = await shouldShowAd(placement: 'app_open');
    if (canShowResult.isLeft()) {
      return canShowResult;
    }

    final canShow = canShowResult.getOrElse(() => false);
    if (!canShow) {
      return Left(AdFrequencyCapFailure.tooSoon());
    }

    // Show ad
    final result = await _appOpenService.show(
      onAdDismissedFullScreenContent: () {
        recordAdShown(placement: 'app_open');
      },
    );

    return result;
  }

  @override
  bool get isAppOpenReady => _appOpenService.isReady;

  // ===== Configuration =====

  @override
  Future<Either<Failure, void>> setTestDevices({
    required List<String> deviceIds,
  }) async {
    try {
      final requestConfig = RequestConfiguration(testDeviceIds: deviceIds);
      await MobileAds.instance.updateRequestConfiguration(requestConfig);
      return const Right(null);
    } catch (e) {
      return Left(
        AdConfigFailure(
          'Failed to set test devices: ${e.toString()}',
          code: 'TEST_DEVICES_FAILED',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> shouldShowAd({
    required String placement,
  }) async {
    // Check premium status
    if (await _shouldBlockForPremium()) {
      return const Left(AdPremiumBlockFailure());
    }

    // Check minimum interval between ads
    final lastShow = _lastAdShowTime[placement];
    if (lastShow != null) {
      final elapsed = DateTime.now().difference(lastShow);
      if (elapsed < minAdInterval) {
        return const Right(false);
      }
    }

    return const Right(true);
  }

  // ===== Frequency Management =====

  @override
  Future<Either<Failure, void>> recordAdShown({
    required String placement,
  }) async {
    _adShowCounts[placement] = (_adShowCounts[placement] ?? 0) + 1;
    _lastAdShowTime[placement] = DateTime.now();
    return const Right(null);
  }

  @override
  Future<Either<Failure, int>> getAdShowCount({
    required String placement,
  }) async {
    return Right(_adShowCounts[placement] ?? 0);
  }

  @override
  Future<Either<Failure, void>> resetFrequency({
    required String placement,
  }) async {
    _adShowCounts.remove(placement);
    _lastAdShowTime.remove(placement);
    return const Right(null);
  }

  // ===== Lifecycle =====

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      await _lifecycleManager.disposeAll();
      await _interstitialService.dispose();
      await _rewardedService.dispose();
      await _rewardedInterstitialService.dispose();
      await _appOpenService.dispose();
      
      _adShowCounts.clear();
      _lastAdShowTime.clear();
      _isInitialized = false;
      
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to dispose ads service: ${e.toString()}',
          code: 'DISPOSE_FAILED',
          details: e,
        ),
      );
    }
  }

  // ===== Helper Methods =====

  /// Check if should block ads for premium users
  Future<bool> _shouldBlockForPremium() async {
    if (premiumStatusChecker == null) return false;

    try {
      return await premiumStatusChecker!();
    } catch (e) {
      // If error checking premium status, allow ads
      return false;
    }
  }

  /// Get service statistics
  Map<String, dynamic> getStatistics() {
    return {
      'initialized': _isInitialized,
      'lifecycle': _lifecycleManager.getStatistics(),
      'adShowCounts': Map<String, int>.from(_adShowCounts),
      'lastAdShowTime': _lastAdShowTime.map(
        (k, v) => MapEntry(k, v.toIso8601String()),
      ),
    };
  }
}

import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../domain/entities/ads/ad_unit_entity.dart';
import '../../../domain/repositories/i_ads_repository.dart';
import '../../../shared/utils/ads_failures.dart';
import '../../../shared/utils/failure.dart';
import 'specialized_services/ad_config_service.dart';
import 'specialized_services/ad_frequency_manager.dart';
import 'specialized_services/ad_lifecycle_manager.dart';
import 'specialized_services/banner_ad_service.dart';
import 'specialized_services/interstitial_ad_service.dart';
import 'specialized_services/rewarded_ad_service.dart';
import 'specialized_services/rewarded_interstitial_ad_service.dart';
import 'specialized_services/app_open_ad_service.dart';
import 'specialized_services/ad_preloader_service.dart';

/// Main Google Mobile Ads Service implementing the repository interface
/// Follows Facade Pattern - coordinates all specialized services
/// This is the single entry point for all ad operations
class GoogleMobileAdsService implements IAdsRepository {
  final AdConfigService _configService;
  final AdFrequencyManager _frequencyManager;
  final AdLifecycleManager _lifecycleManager;
  final BannerAdService _bannerService;
  final InterstitialAdService _interstitialService;
  final RewardedAdService _rewardedService;
  final RewardedInterstitialAdService _rewardedInterstitialService;
  final AppOpenAdService _appOpenService;
  final AdPreloaderService _preloaderService;

  bool _isInitialized = false;

  /// Optional: Premium status checker (integrate with RevenueCat)
  Future<bool> Function()? premiumStatusChecker;

  GoogleMobileAdsService({
    required AdConfigService configService,
    required AdFrequencyManager frequencyManager,
    required AdLifecycleManager lifecycleManager,
    required BannerAdService bannerService,
    required InterstitialAdService interstitialService,
    required RewardedAdService rewardedService,
    required RewardedInterstitialAdService rewardedInterstitialService,
    required AppOpenAdService appOpenService,
    required AdPreloaderService preloaderService,
    this.premiumStatusChecker,
  })  : _configService = configService,
        _frequencyManager = frequencyManager,
        _lifecycleManager = lifecycleManager,
        _bannerService = bannerService,
        _interstitialService = interstitialService,
        _rewardedService = rewardedService,
        _rewardedInterstitialService = rewardedInterstitialService,
        _appOpenService = appOpenService,
        _preloaderService = preloaderService;

  // ===== Initialization =====

  @override
  Future<Either<Failure, void>> initialize({required String appId}) async {
    if (_isInitialized) {
      return Left(AdInitializationFailure.alreadyInitialized());
    }

    try {
      // Initialize config service
      final configResult = await _configService.initialize();
      if (configResult.isLeft()) {
        return configResult;
      }

      // Initialize frequency manager
      final frequencyResult = await _frequencyManager.initialize();
      if (frequencyResult.isLeft()) {
        return frequencyResult;
      }

      // Initialize Google Mobile Ads SDK
      await MobileAds.instance.initialize();

      // Set test devices if configured
      final testDeviceIds = _configService.testDeviceIds;
      if (testDeviceIds.isNotEmpty) {
        await setTestDevices(deviceIds: testDeviceIds);
      }

      _isInitialized = true;

      // Preload ads in background
      _preloadAdsInBackground();

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

  /// Preload ads in background (non-blocking)
  void _preloadAdsInBackground() {
    Future.delayed(const Duration(seconds: 2), () {
      _preloaderService.preloadAll();
    });
  }

  // ===== Banner Ads =====

  @override
  Future<Either<Failure, BannerAd>> loadBannerAd({
    required String adUnitId,
    required AdSize size,
  }) async {
    if (!_isInitialized) {
      return Left(
        AdInitializationFailure('Ads not initialized'),
      );
    }

    // Check premium status
    if (await _shouldBlockForPremium()) {
      return Left(AdPremiumBlockFailure());
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
      return Left(
        AdInitializationFailure('Ads not initialized'),
      );
    }

    return _interstitialService.load(adUnitId: adUnitId);
  }

  @override
  Future<Either<Failure, void>> showInterstitialAd() async {
    if (!_isInitialized) {
      return Left(
        AdInitializationFailure('Ads not initialized'),
      );
    }

    // Check premium status
    if (await _shouldBlockForPremium()) {
      return Left(AdPremiumBlockFailure());
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
        // Record ad shown
        _frequencyManager.recordAdShown('interstitial');

        // Preload next ad
        final adUnitIdResult = _configService.getAdUnitId(AdType.interstitial);
        adUnitIdResult.fold(
          (_) {},
          (adUnitId) => _interstitialService.load(adUnitId: adUnitId),
        );
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
      return Left(
        AdInitializationFailure('Ads not initialized'),
      );
    }

    return _rewardedService.load(adUnitId: adUnitId);
  }

  @override
  Future<Either<Failure, RewardedAd?>> showRewardedAd() async {
    if (!_isInitialized) {
      return Left(
        AdInitializationFailure('Ads not initialized'),
      );
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
        // Record ad shown
        _frequencyManager.recordAdShown('rewarded');

        // Preload next ad
        final adUnitIdResult = _configService.getAdUnitId(AdType.rewarded);
        adUnitIdResult.fold(
          (_) {},
          (adUnitId) => _rewardedService.load(adUnitId: adUnitId),
        );
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
      return Left(
        AdInitializationFailure('Ads not initialized'),
      );
    }

    return _rewardedInterstitialService.load(adUnitId: adUnitId);
  }

  @override
  Future<Either<Failure, RewardedInterstitialAd?>> showRewardedInterstitialAd() async {
    if (!_isInitialized) {
      return Left(
        AdInitializationFailure('Ads not initialized'),
      );
    }

    // Check frequency
    final canShowResult = await shouldShowAd(placement: 'rewarded_interstitial');
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
        // Record ad shown
        _frequencyManager.recordAdShown('rewarded_interstitial');

        // Preload next ad
        final adUnitIdResult =
            _configService.getAdUnitId(AdType.rewardedInterstitial);
        adUnitIdResult.fold(
          (_) {},
          (adUnitId) => _rewardedInterstitialService.load(adUnitId: adUnitId),
        );
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
      return Left(
        AdInitializationFailure('Ads not initialized'),
      );
    }

    return _appOpenService.load(adUnitId: adUnitId);
  }

  @override
  Future<Either<Failure, void>> showAppOpenAd() async {
    if (!_isInitialized) {
      return Left(
        AdInitializationFailure('Ads not initialized'),
      );
    }

    // Check premium status
    if (await _shouldBlockForPremium()) {
      return Left(AdPremiumBlockFailure());
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
        // Record ad shown
        _frequencyManager.recordAdShown('app_open');

        // Preload next ad
        final adUnitIdResult = _configService.getAdUnitId(AdType.appOpen);
        adUnitIdResult.fold(
          (_) {},
          (adUnitId) => _appOpenService.load(adUnitId: adUnitId),
        );
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
      final requestConfig = RequestConfiguration(
        testDeviceIds: deviceIds,
      );
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
      return Left(AdPremiumBlockFailure());
    }

    // Get frequency config for placement
    final adType = _getAdTypeFromPlacement(placement);
    final configResult = _configService.getFrequencyConfig(adType);
    if (configResult.isLeft()) {
      return const Right(false);
    }

    final config = configResult.getOrElse(
      () => throw Exception('Config should be present'),
    );

    // Check frequency
    return _frequencyManager.canShowAd(
      placement: placement,
      config: config,
    );
  }

  // ===== Frequency Management =====

  @override
  Future<Either<Failure, void>> recordAdShown({
    required String placement,
  }) {
    return _frequencyManager.recordAdShown(placement);
  }

  @override
  Future<Either<Failure, int>> getAdShowCount({
    required String placement,
  }) {
    return _frequencyManager.getAdShowCount(placement);
  }

  @override
  Future<Either<Failure, void>> resetFrequency({
    required String placement,
  }) {
    return _frequencyManager.resetFrequency(placement);
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
      await _frequencyManager.dispose();
      await _configService.dispose();

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
    if (_configService.showAdsForPremium) return false;

    try {
      return await premiumStatusChecker!();
    } catch (e) {
      // If error checking premium status, allow ads
      return false;
    }
  }

  /// Get ad type from placement name
  AdType _getAdTypeFromPlacement(String placement) {
    if (placement.contains('interstitial')) return AdType.interstitial;
    if (placement.contains('rewarded')) return AdType.rewarded;
    if (placement.contains('banner')) return AdType.banner;
    if (placement.contains('app_open')) return AdType.appOpen;
    return AdType.interstitial; // Default
  }

  /// Get service statistics
  Map<String, dynamic> getStatistics() {
    return {
      'initialized': _isInitialized,
      'lifecycle': _lifecycleManager.getStatistics(),
      'frequency': _frequencyManager.getStatistics(),
      'preload_status': _preloaderService.getPreloadStatus(),
    };
  }
}

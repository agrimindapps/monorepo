import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../shared/utils/ads_failures.dart';
import '../../../../domain/entities/ads/ad_unit_entity.dart';
import '../../../../shared/utils/failure.dart';
import 'ad_config_service.dart';
import 'interstitial_ad_service.dart';
import 'rewarded_ad_service.dart';
import 'rewarded_interstitial_ad_service.dart';
import 'app_open_ad_service.dart';

/// Specialized service for preloading ads
/// Responsible for background ad loading and cache management
/// Follows SRP - Single Responsibility: Ad Preloading
class AdPreloaderService {
  final AdConfigService _configService;
  final InterstitialAdService _interstitialService;
  final RewardedAdService _rewardedService;
  final RewardedInterstitialAdService _rewardedInterstitialService;
  final AppOpenAdService _appOpenService;

  /// Timeout for preloading operations
  static const Duration preloadTimeout = Duration(seconds: 30);

  AdPreloaderService({
    required AdConfigService configService,
    required InterstitialAdService interstitialService,
    required RewardedAdService rewardedService,
    required RewardedInterstitialAdService rewardedInterstitialService,
    required AppOpenAdService appOpenService,
  })  : _configService = configService,
        _interstitialService = interstitialService,
        _rewardedService = rewardedService,
        _rewardedInterstitialService = rewardedInterstitialService,
        _appOpenService = appOpenService;

  /// Preload all configured ads
  Future<Map<AdType, Either<Failure, void>>> preloadAll() async {
    final results = <AdType, Either<Failure, void>>{};

    // Preload interstitial
    final interstitialResult = await preloadInterstitial();
    if (interstitialResult != null) {
      results[AdType.interstitial] = interstitialResult;
    }

    // Preload rewarded
    final rewardedResult = await preloadRewarded();
    if (rewardedResult != null) {
      results[AdType.rewarded] = rewardedResult;
    }

    // Preload rewarded interstitial
    final rewardedInterstitialResult = await preloadRewardedInterstitial();
    if (rewardedInterstitialResult != null) {
      results[AdType.rewardedInterstitial] = rewardedInterstitialResult;
    }

    // Preload app open
    final appOpenResult = await preloadAppOpen();
    if (appOpenResult != null) {
      results[AdType.appOpen] = appOpenResult;
    }

    return results;
  }

  /// Preload interstitial ad
  Future<Either<Failure, void>?> preloadInterstitial() async {
    if (_interstitialService.isReady || _interstitialService.isLoading) {
      return null; // Already loaded or loading
    }

    final adUnitIdResult = _configService.getAdUnitId(AdType.interstitial);
    if (adUnitIdResult.isLeft()) {
      return adUnitIdResult;
    }

    final adUnitId = adUnitIdResult.getOrElse(() => '');

    try {
      return await _interstitialService
          .load(adUnitId: adUnitId)
          .timeout(preloadTimeout);
    } on TimeoutException {
      return Left(AdLoadFailure.timeout());
    }
  }

  /// Preload rewarded ad
  Future<Either<Failure, void>?> preloadRewarded() async {
    if (_rewardedService.isReady || _rewardedService.isLoading) {
      return null; // Already loaded or loading
    }

    final adUnitIdResult = _configService.getAdUnitId(AdType.rewarded);
    if (adUnitIdResult.isLeft()) {
      return adUnitIdResult;
    }

    final adUnitId = adUnitIdResult.getOrElse(() => '');

    try {
      return await _rewardedService
          .load(adUnitId: adUnitId)
          .timeout(preloadTimeout);
    } on TimeoutException {
      return Left(AdLoadFailure.timeout());
    }
  }

  /// Preload rewarded interstitial ad
  Future<Either<Failure, void>?> preloadRewardedInterstitial() async {
    if (_rewardedInterstitialService.isReady ||
        _rewardedInterstitialService.isLoading) {
      return null; // Already loaded or loading
    }

    final adUnitIdResult = _configService.getAdUnitId(AdType.rewardedInterstitial);
    if (adUnitIdResult.isLeft()) {
      return adUnitIdResult;
    }

    final adUnitId = adUnitIdResult.getOrElse(() => '');

    try {
      return await _rewardedInterstitialService
          .load(adUnitId: adUnitId)
          .timeout(preloadTimeout);
    } on TimeoutException {
      return Left(AdLoadFailure.timeout());
    }
  }

  /// Preload app open ad
  Future<Either<Failure, void>?> preloadAppOpen() async {
    if (_appOpenService.isReady || _appOpenService.isLoading) {
      return null; // Already loaded or loading
    }

    final adUnitIdResult = _configService.getAdUnitId(AdType.appOpen);
    if (adUnitIdResult.isLeft()) {
      return adUnitIdResult;
    }

    final adUnitId = adUnitIdResult.getOrElse(() => '');

    try {
      return await _appOpenService
          .load(adUnitId: adUnitId)
          .timeout(preloadTimeout);
    } on TimeoutException {
      return Left(AdLoadFailure.timeout());
    }
  }

  /// Preload specific ad types
  Future<Map<AdType, Either<Failure, void>>> preloadSpecific(
    List<AdType> adTypes,
  ) async {
    final results = <AdType, Either<Failure, void>>{};

    for (final adType in adTypes) {
      Either<Failure, void>? result;

      switch (adType) {
        case AdType.interstitial:
          result = await preloadInterstitial();
          break;
        case AdType.rewarded:
          result = await preloadRewarded();
          break;
        case AdType.rewardedInterstitial:
          result = await preloadRewardedInterstitial();
          break;
        case AdType.appOpen:
          result = await preloadAppOpen();
          break;
        case AdType.banner:
        case AdType.native:
          // Banners and native ads are loaded on-demand, not preloaded
          continue;
      }

      if (result != null) {
        results[adType] = result;
      }
    }

    return results;
  }

  /// Get preload status for all ad types
  Map<AdType, bool> getPreloadStatus() {
    return {
      AdType.interstitial: _interstitialService.isReady,
      AdType.rewarded: _rewardedService.isReady,
      AdType.rewardedInterstitial: _rewardedInterstitialService.isReady,
      AdType.appOpen: _appOpenService.isReady,
    };
  }

  /// Check if any ads are ready
  bool get hasAnyAdsReady {
    return _interstitialService.isReady ||
        _rewardedService.isReady ||
        _rewardedInterstitialService.isReady ||
        _appOpenService.isReady;
  }

  /// Get count of ready ads
  int get readyAdsCount {
    int count = 0;
    if (_interstitialService.isReady) count++;
    if (_rewardedService.isReady) count++;
    if (_rewardedInterstitialService.isReady) count++;
    if (_appOpenService.isReady) count++;
    return count;
  }
}

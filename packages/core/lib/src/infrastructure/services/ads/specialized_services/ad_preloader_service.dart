import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../domain/entities/ads/ad_unit_entity.dart';
import '../../../../shared/utils/ads_failures.dart';
import '../../../../shared/utils/failure.dart';
import 'app_open_ad_service.dart';
import 'interstitial_ad_service.dart';
import 'rewarded_ad_service.dart';
import 'rewarded_interstitial_ad_service.dart';

/// Specialized service for preloading ads
/// Responsible for background ad loading and cache management
/// Follows SRP - Single Responsibility: Ad Preloading
///
/// NOTE: AdConfigService was removed. Ad unit IDs must be provided externally.
class AdPreloaderService {
  final InterstitialAdService _interstitialService;
  final RewardedAdService _rewardedService;
  final RewardedInterstitialAdService _rewardedInterstitialService;
  final AppOpenAdService _appOpenService;

  /// Timeout for preloading operations
  static const Duration preloadTimeout = Duration(seconds: 30);

  AdPreloaderService({
    required InterstitialAdService interstitialService,
    required RewardedAdService rewardedService,
    required RewardedInterstitialAdService rewardedInterstitialService,
    required AppOpenAdService appOpenService,
  })  : _interstitialService = interstitialService,
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
  /// NOTE: AdConfigService removed - ad unit IDs must be set in services separately
  Future<Either<Failure, void>?> preloadInterstitial() async {
    if (_interstitialService.isReady || _interstitialService.isLoading) {
      return null; // Already loaded or loading
    }

    try {
      // Attempt to load with default/configured ad unit ID
      return await _interstitialService
          .load(adUnitId: '')
          .timeout(preloadTimeout);
    } on TimeoutException {
      return Left(AdLoadFailure.timeout());
    } catch (e) {
      return Left(AdLoadFailure('Failed to preload interstitial: $e'));
    }
  }

  /// Preload rewarded ad
  /// NOTE: AdConfigService removed - ad unit IDs must be set in services separately
  Future<Either<Failure, void>?> preloadRewarded() async {
    if (_rewardedService.isReady || _rewardedService.isLoading) {
      return null; // Already loaded or loading
    }

    try {
      return await _rewardedService
          .load(adUnitId: '')
          .timeout(preloadTimeout);
    } on TimeoutException {
      return Left(AdLoadFailure.timeout());
    } catch (e) {
      return Left(AdLoadFailure('Failed to preload rewarded: $e'));
    }
  }

  /// Preload rewarded interstitial ad
  /// NOTE: AdConfigService removed - ad unit IDs must be set in services separately
  Future<Either<Failure, void>?> preloadRewardedInterstitial() async {
    if (_rewardedInterstitialService.isReady ||
        _rewardedInterstitialService.isLoading) {
      return null; // Already loaded or loading
    }

    try {
      return await _rewardedInterstitialService
          .load(adUnitId: '')
          .timeout(preloadTimeout);
    } on TimeoutException {
      return Left(AdLoadFailure.timeout());
    } catch (e) {
      return Left(AdLoadFailure('Failed to preload rewarded interstitial: $e'));
    }
  }

  /// Preload app open ad
  /// NOTE: AdConfigService removed - ad unit IDs must be set in services separately
  Future<Either<Failure, void>?> preloadAppOpen() async {
    if (_appOpenService.isReady || _appOpenService.isLoading) {
      return null; // Already loaded or loading
    }

    try {
      return await _appOpenService
          .load(adUnitId: '')
          .timeout(preloadTimeout);
    } on TimeoutException {
      return Left(AdLoadFailure.timeout());
    } catch (e) {
      return Left(AdLoadFailure('Failed to preload app open: $e'));
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

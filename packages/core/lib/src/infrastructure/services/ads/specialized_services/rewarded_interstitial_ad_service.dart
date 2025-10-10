import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../shared/utils/ads_failures.dart';
import '../../../../shared/utils/failure.dart';

/// Specialized service for rewarded interstitial ad operations
/// Responsible for loading and showing rewarded interstitial ads
/// Follows SRP - Single Responsibility: Rewarded Interstitial Ad Management
class RewardedInterstitialAdService {
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isLoading = false;
  bool _isShowing = false;

  /// Check if rewarded interstitial ad is ready
  bool get isReady => _rewardedInterstitialAd != null && !_isShowing;

  /// Check if currently loading
  bool get isLoading => _isLoading;

  /// Check if currently showing
  bool get isShowing => _isShowing;

  /// Load a rewarded interstitial ad
  Future<Either<Failure, void>> load({
    required String adUnitId,
    void Function()? onAdLoaded,
    void Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    if (_isLoading) {
      return Left(
        AdLoadFailure('Rewarded interstitial ad already loading', code: 'ALREADY_LOADING'),
      );
    }

    try {
      _isLoading = true;

      final completer = Completer<Either<Failure, void>>();

      await RewardedInterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedInterstitialAd = ad;
            _isLoading = false;
            onAdLoaded?.call();
            completer.complete(const Right(null));
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
            onAdFailedToLoad?.call(error);
            completer.complete(Left(error.toFailure()));
          },
        ),
      );

      return completer.future;
    } catch (e) {
      _isLoading = false;
      return Left(
        AdLoadFailure(
          'Failed to load rewarded interstitial ad: ${e.toString()}',
          code: 'REWARDED_INTERSTITIAL_LOAD_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Show the loaded rewarded interstitial ad
  Future<Either<Failure, RewardedInterstitialAd?>> show({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    void Function()? onAdShowedFullScreenContent,
    void Function(Ad, AdError)? onAdFailedToShowFullScreenContent,
    void Function()? onAdDismissedFullScreenContent,
    void Function()? onAdImpression,
    void Function()? onAdClicked,
  }) async {
    if (_rewardedInterstitialAd == null) {
      return Left(AdShowFailure.notReady());
    }

    if (_isShowing) {
      return Left(AdShowFailure.alreadyShowing());
    }

    try {
      _isShowing = true;

      _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          onAdShowedFullScreenContent?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _isShowing = false;
          ad.dispose();
          _rewardedInterstitialAd = null;
          onAdFailedToShowFullScreenContent?.call(ad, error);
        },
        onAdDismissedFullScreenContent: (ad) {
          _isShowing = false;
          ad.dispose();
          _rewardedInterstitialAd = null;
          onAdDismissedFullScreenContent?.call();
        },
        onAdImpression: (ad) {
          onAdImpression?.call();
        },
        onAdClicked: (ad) {
          onAdClicked?.call();
        },
      );

      await _rewardedInterstitialAd!.show(
        onUserEarnedReward: onUserEarnedReward,
      );

      return Right(_rewardedInterstitialAd);
    } catch (e) {
      _isShowing = false;
      return Left(
        AdShowFailure(
          'Failed to show rewarded interstitial ad: ${e.toString()}',
          code: 'REWARDED_INTERSTITIAL_SHOW_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Dispose the rewarded interstitial ad
  Future<void> dispose() async {
    await _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
    _isLoading = false;
    _isShowing = false;
  }
}

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../shared/utils/ads_failures.dart';
import '../../../../shared/utils/failure.dart';

/// Specialized service for rewarded ad operations
/// Responsible for loading and showing rewarded ads
/// Follows SRP - Single Responsibility: Rewarded Ad Management
class RewardedAdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _isShowing = false;

  /// Check if rewarded ad is ready
  bool get isReady => _rewardedAd != null && !_isShowing;

  /// Check if currently loading
  bool get isLoading => _isLoading;

  /// Check if currently showing
  bool get isShowing => _isShowing;

  /// Load a rewarded ad
  Future<Either<Failure, void>> load({
    required String adUnitId,
    void Function()? onAdLoaded,
    void Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    if (_isLoading) {
      return const Left(
        AdLoadFailure('Rewarded ad already loading', code: 'ALREADY_LOADING'),
      );
    }

    try {
      _isLoading = true;

      final completer = Completer<Either<Failure, void>>();

      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
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
          'Failed to load rewarded ad: ${e.toString()}',
          code: 'REWARDED_LOAD_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Show the loaded rewarded ad
  Future<Either<Failure, RewardedAd?>> show({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    void Function()? onAdShowedFullScreenContent,
    void Function(Ad, AdError)? onAdFailedToShowFullScreenContent,
    void Function()? onAdDismissedFullScreenContent,
    void Function()? onAdImpression,
    void Function()? onAdClicked,
  }) async {
    if (_rewardedAd == null) {
      return Left(AdShowFailure.notReady());
    }

    if (_isShowing) {
      return Left(AdShowFailure.alreadyShowing());
    }

    try {
      _isShowing = true;

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          onAdShowedFullScreenContent?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _isShowing = false;
          ad.dispose();
          _rewardedAd = null;
          onAdFailedToShowFullScreenContent?.call(ad, error);
        },
        onAdDismissedFullScreenContent: (ad) {
          _isShowing = false;
          ad.dispose();
          _rewardedAd = null;
          onAdDismissedFullScreenContent?.call();
        },
        onAdImpression: (ad) {
          onAdImpression?.call();
        },
        onAdClicked: (ad) {
          onAdClicked?.call();
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: onUserEarnedReward,
      );

      return Right(_rewardedAd);
    } catch (e) {
      _isShowing = false;
      return Left(
        AdShowFailure(
          'Failed to show rewarded ad: ${e.toString()}',
          code: 'REWARDED_SHOW_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Dispose the rewarded ad
  Future<void> dispose() async {
    await _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoading = false;
    _isShowing = false;
  }
}

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../shared/utils/ads_failures.dart';
import '../../../../shared/utils/failure.dart';

/// Specialized service for interstitial ad operations
/// Responsible for loading and showing interstitial ads
/// Follows SRP - Single Responsibility: Interstitial Ad Management
class InterstitialAdService {
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  bool _isShowing = false;

  /// Check if interstitial is ready
  bool get isReady => _interstitialAd != null && !_isShowing;

  /// Check if currently loading
  bool get isLoading => _isLoading;

  /// Check if currently showing
  bool get isShowing => _isShowing;

  /// Load an interstitial ad
  Future<Either<Failure, void>> load({
    required String adUnitId,
    void Function()? onAdLoaded,
    void Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    if (_isLoading) {
      return Left(
        AdLoadFailure('Interstitial ad already loading', code: 'ALREADY_LOADING'),
      );
    }

    try {
      _isLoading = true;

      final completer = Completer<Either<Failure, void>>();

      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
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
          'Failed to load interstitial ad: ${e.toString()}',
          code: 'INTERSTITIAL_LOAD_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Show the loaded interstitial ad
  Future<Either<Failure, void>> show({
    void Function()? onAdShowedFullScreenContent,
    void Function(Ad, AdError)? onAdFailedToShowFullScreenContent,
    void Function()? onAdDismissedFullScreenContent,
    void Function()? onAdImpression,
    void Function()? onAdClicked,
  }) async {
    if (_interstitialAd == null) {
      return Left(AdShowFailure.notReady());
    }

    if (_isShowing) {
      return Left(AdShowFailure.alreadyShowing());
    }

    try {
      _isShowing = true;

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          onAdShowedFullScreenContent?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _isShowing = false;
          ad.dispose();
          _interstitialAd = null;
          onAdFailedToShowFullScreenContent?.call(ad, error);
        },
        onAdDismissedFullScreenContent: (ad) {
          _isShowing = false;
          ad.dispose();
          _interstitialAd = null;
          onAdDismissedFullScreenContent?.call();
        },
        onAdImpression: (ad) {
          onAdImpression?.call();
        },
        onAdClicked: (ad) {
          onAdClicked?.call();
        },
      );

      await _interstitialAd!.show();
      return const Right(null);
    } catch (e) {
      _isShowing = false;
      return Left(
        AdShowFailure(
          'Failed to show interstitial ad: ${e.toString()}',
          code: 'INTERSTITIAL_SHOW_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Dispose the interstitial ad
  Future<void> dispose() async {
    await _interstitialAd?.dispose();
    _interstitialAd = null;
    _isLoading = false;
    _isShowing = false;
  }
}

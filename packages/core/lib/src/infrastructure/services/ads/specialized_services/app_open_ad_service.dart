import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../shared/utils/ads_failures.dart';
import '../../../../shared/utils/failure.dart';

/// Specialized service for app open ad operations
/// Responsible for loading and showing app open ads
/// Follows SRP - Single Responsibility: App Open Ad Management
class AppOpenAdService {
  AppOpenAd? _appOpenAd;
  bool _isLoading = false;
  bool _isShowing = false;
  DateTime? _loadTime;

  /// Maximum ad age before reload (4 hours)
  static const Duration maxAdAge = Duration(hours: 4);

  /// Check if app open ad is ready
  bool get isReady => _appOpenAd != null && !_isShowing && !_isExpired;

  /// Check if currently loading
  bool get isLoading => _isLoading;

  /// Check if currently showing
  bool get isShowing => _isShowing;

  /// Check if loaded ad is expired
  bool get _isExpired {
    if (_loadTime == null) return true;
    final age = DateTime.now().difference(_loadTime!);
    return age >= maxAdAge;
  }

  /// Load an app open ad
  Future<Either<Failure, void>> load({
    required String adUnitId,
    void Function()? onAdLoaded,
    void Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    if (_isLoading) {
      return const Left(
        AdLoadFailure('App open ad already loading', code: 'ALREADY_LOADING'),
      );
    }

    try {
      _isLoading = true;

      final completer = Completer<Either<Failure, void>>();

      await AppOpenAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _loadTime = DateTime.now();
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
          'Failed to load app open ad: ${e.toString()}',
          code: 'APP_OPEN_LOAD_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Show the loaded app open ad
  Future<Either<Failure, void>> show({
    void Function()? onAdShowedFullScreenContent,
    void Function(Ad, AdError)? onAdFailedToShowFullScreenContent,
    void Function()? onAdDismissedFullScreenContent,
    void Function()? onAdImpression,
    void Function()? onAdClicked,
  }) async {
    if (_appOpenAd == null) {
      return Left(AdShowFailure.notReady());
    }

    if (_isExpired) {
      await dispose();
      return const Left(
        AdShowFailure('App open ad expired', code: 'AD_EXPIRED'),
      );
    }

    if (_isShowing) {
      return Left(AdShowFailure.alreadyShowing());
    }

    try {
      _isShowing = true;

      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          onAdShowedFullScreenContent?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _isShowing = false;
          ad.dispose();
          _appOpenAd = null;
          _loadTime = null;
          onAdFailedToShowFullScreenContent?.call(ad, error);
        },
        onAdDismissedFullScreenContent: (ad) {
          _isShowing = false;
          ad.dispose();
          _appOpenAd = null;
          _loadTime = null;
          onAdDismissedFullScreenContent?.call();
        },
        onAdImpression: (ad) {
          onAdImpression?.call();
        },
        onAdClicked: (ad) {
          onAdClicked?.call();
        },
      );

      await _appOpenAd!.show();
      return const Right(null);
    } catch (e) {
      _isShowing = false;
      return Left(
        AdShowFailure(
          'Failed to show app open ad: ${e.toString()}',
          code: 'APP_OPEN_SHOW_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Dispose the app open ad
  Future<void> dispose() async {
    await _appOpenAd?.dispose();
    _appOpenAd = null;
    _loadTime = null;
    _isLoading = false;
    _isShowing = false;
  }
}

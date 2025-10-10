import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../shared/utils/failure.dart';

/// Repository interface for Google Mobile Ads operations
/// Defines the contract for ad management following Clean Architecture
///
/// All methods return Either<Failure, T> for functional error handling
abstract class IAdsRepository {
  // ===== Initialization =====

  /// Initialize Google Mobile Ads SDK
  ///
  /// Must be called before any other ad operations
  /// [appId] - Google Mobile Ads App ID (platform-specific)
  ///
  /// Returns [Right(void)] on success, [Left(Failure)] on error
  Future<Either<Failure, void>> initialize({required String appId});

  // ===== Banner Ads =====

  /// Load a banner ad
  ///
  /// [adUnitId] - The ad unit ID for the banner
  /// [size] - The size of the banner (e.g., AdSize.banner)
  ///
  /// Returns [Right(BannerAd)] on success, [Left(Failure)] on error
  Future<Either<Failure, BannerAd>> loadBannerAd({
    required String adUnitId,
    required AdSize size,
  });

  // ===== Interstitial Ads =====

  /// Load an interstitial ad
  ///
  /// Call this before you need to show the ad
  /// [adUnitId] - The ad unit ID for the interstitial
  ///
  /// Returns [Right(void)] on success, [Left(Failure)] on error
  Future<Either<Failure, void>> loadInterstitialAd({required String adUnitId});

  /// Show the loaded interstitial ad
  ///
  /// Must call [loadInterstitialAd] first
  /// Check [isInterstitialReady] before calling
  ///
  /// Returns [Right(void)] on success, [Left(Failure)] on error
  Future<Either<Failure, void>> showInterstitialAd();

  /// Check if interstitial ad is ready to show
  bool get isInterstitialReady;

  // ===== Rewarded Ads =====

  /// Load a rewarded ad
  ///
  /// Call this before you need to show the ad
  /// [adUnitId] - The ad unit ID for the rewarded ad
  ///
  /// Returns [Right(void)] on success, [Left(Failure)] on error
  Future<Either<Failure, void>> loadRewardedAd({required String adUnitId});

  /// Show the loaded rewarded ad
  ///
  /// Must call [loadRewardedAd] first
  /// Check [isRewardedReady] before calling
  ///
  /// Returns [Right(RewardedAd)] on success with reward info, [Left(Failure)] on error
  Future<Either<Failure, RewardedAd?>> showRewardedAd();

  /// Check if rewarded ad is ready to show
  bool get isRewardedReady;

  // ===== Rewarded Interstitial Ads =====

  /// Load a rewarded interstitial ad
  ///
  /// Call this before you need to show the ad
  /// [adUnitId] - The ad unit ID for the rewarded interstitial
  ///
  /// Returns [Right(void)] on success, [Left(Failure)] on error
  Future<Either<Failure, void>> loadRewardedInterstitialAd({required String adUnitId});

  /// Show the loaded rewarded interstitial ad
  ///
  /// Must call [loadRewardedInterstitialAd] first
  /// Check [isRewardedInterstitialReady] before calling
  ///
  /// Returns [Right(RewardedInterstitialAd)] on success with reward info, [Left(Failure)] on error
  Future<Either<Failure, RewardedInterstitialAd?>> showRewardedInterstitialAd();

  /// Check if rewarded interstitial ad is ready to show
  bool get isRewardedInterstitialReady;

  // ===== App Open Ads =====

  /// Load an app open ad
  ///
  /// Call this when app starts or comes to foreground
  /// [adUnitId] - The ad unit ID for the app open ad
  ///
  /// Returns [Right(void)] on success, [Left(Failure)] on error
  Future<Either<Failure, void>> loadAppOpenAd({required String adUnitId});

  /// Show the loaded app open ad
  ///
  /// Must call [loadAppOpenAd] first
  /// Check [isAppOpenReady] before calling
  ///
  /// Returns [Right(void)] on success, [Left(Failure)] on error
  Future<Either<Failure, void>> showAppOpenAd();

  /// Check if app open ad is ready to show
  bool get isAppOpenReady;

  // ===== Configuration =====

  /// Set test device IDs for production testing
  ///
  /// [deviceIds] - List of device IDs to enable test ads
  ///
  /// Returns [Right(void)] on success, [Left(Failure)] on error
  Future<Either<Failure, void>> setTestDevices({required List<String> deviceIds});

  /// Check if ad should be shown based on frequency capping and user status
  ///
  /// [placement] - The placement identifier where ad will be shown
  ///
  /// Returns [Right(true)] if ad can be shown, [Right(false)] if blocked by frequency cap or premium status
  Future<Either<Failure, bool>> shouldShowAd({required String placement});

  // ===== Frequency Management =====

  /// Record that an ad was shown
  ///
  /// Updates frequency tracking counters
  /// [placement] - The placement identifier where ad was shown
  ///
  /// Returns [Right(void)] on success, [Left(Failure)] on error
  Future<Either<Failure, void>> recordAdShown({required String placement});

  /// Get the number of times an ad was shown
  ///
  /// [placement] - The placement identifier to check
  ///
  /// Returns [Right(int)] with count on success, [Left(Failure)] on error
  Future<Either<Failure, int>> getAdShowCount({required String placement});

  /// Reset frequency counters for a placement
  ///
  /// [placement] - The placement identifier to reset
  ///
  /// Returns [Right(void)] on success, [Left(Failure)] on error
  Future<Either<Failure, void>> resetFrequency({required String placement});

  // ===== Lifecycle =====

  /// Dispose all loaded ads and cleanup resources
  ///
  /// Call when ads are no longer needed or app is closing
  ///
  /// Returns [Right(void)] on success, [Left(Failure)] on error
  Future<Either<Failure, void>> dispose();
}

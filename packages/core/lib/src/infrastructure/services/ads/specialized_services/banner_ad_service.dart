import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../shared/utils/ads_failures.dart';
import '../../../../shared/utils/failure.dart';

/// Specialized service for banner ad operations
/// Responsible for loading and managing banner ads
/// Follows SRP - Single Responsibility: Banner Ad Management
class BannerAdService {
  /// Load a banner ad
  Future<Either<Failure, BannerAd>> loadBanner({
    required String adUnitId,
    required AdSize size,
    void Function()? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
    void Function(Ad)? onAdOpened,
    void Function(Ad)? onAdClosed,
    void Function(Ad)? onAdImpression,
    void Function(Ad)? onAdClicked,
  }) async {
    try {
      final bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            onAdLoaded?.call();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            onAdFailedToLoad?.call(ad, error);
          },
          onAdOpened: (ad) {
            onAdOpened?.call(ad);
          },
          onAdClosed: (ad) {
            onAdClosed?.call(ad);
          },
          onAdImpression: (ad) {
            onAdImpression?.call(ad);
          },
          onAdClicked: (ad) {
            onAdClicked?.call(ad);
          },
        ),
      );

      // Load the ad
      await bannerAd.load();

      return Right(bannerAd);
    } on LoadAdError catch (error) {
      return Left(error.toFailure());
    } catch (e) {
      return Left(
        AdLoadFailure(
          'Failed to load banner ad: ${e.toString()}',
          code: 'BANNER_LOAD_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Create banner ad with standard sizes
  Future<Either<Failure, BannerAd>> loadStandardBanner({
    required String adUnitId,
    void Function()? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    return loadBanner(
      adUnitId: adUnitId,
      size: AdSize.banner, // 320x50
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
    );
  }

  /// Create large banner ad
  Future<Either<Failure, BannerAd>> loadLargeBanner({
    required String adUnitId,
    void Function()? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    return loadBanner(
      adUnitId: adUnitId,
      size: AdSize.largeBanner, // 320x100
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
    );
  }

  /// Create medium rectangle banner ad
  Future<Either<Failure, BannerAd>> loadMediumRectangle({
    required String adUnitId,
    void Function()? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    return loadBanner(
      adUnitId: adUnitId,
      size: AdSize.mediumRectangle, // 300x250
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
    );
  }

  /// Create adaptive banner ad
  Future<Either<Failure, BannerAd>> loadAdaptiveBanner({
    required String adUnitId,
    required int width,
    void Function()? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );

    if (size == null) {
      return Left(
        AdLoadFailure.invalidRequest('Could not determine adaptive banner size'),
      );
    }

    return loadBanner(
      adUnitId: adUnitId,
      size: size,
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
    );
  }

  /// Dispose banner ad
  Future<void> disposeBanner(BannerAd ad) async {
    await ad.dispose();
  }
}

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Specialized service for managing ad lifecycle
/// Responsible for tracking active ads and proper disposal
/// Follows SRP - Single Responsibility: Lifecycle Management
class AdLifecycleManager {
  final Map<String, BannerAd> _bannerAds = {};
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  AppOpenAd? _appOpenAd;

  /// Register a banner ad
  void registerBanner(String id, BannerAd ad) {
    _bannerAds[id] = ad;
  }

  /// Unregister and dispose a banner ad
  Future<void> unregisterBanner(String id) async {
    final ad = _bannerAds.remove(id);
    await ad?.dispose();
  }

  /// Register an interstitial ad
  void registerInterstitial(InterstitialAd ad) {
    _interstitialAd?.dispose();
    _interstitialAd = ad;
  }

  /// Get current interstitial ad
  InterstitialAd? get interstitialAd => _interstitialAd;

  /// Clear interstitial ad
  void clearInterstitial() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  /// Register a rewarded ad
  void registerRewarded(RewardedAd ad) {
    _rewardedAd?.dispose();
    _rewardedAd = ad;
  }

  /// Get current rewarded ad
  RewardedAd? get rewardedAd => _rewardedAd;

  /// Clear rewarded ad
  void clearRewarded() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  /// Register a rewarded interstitial ad
  void registerRewardedInterstitial(RewardedInterstitialAd ad) {
    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = ad;
  }

  /// Get current rewarded interstitial ad
  RewardedInterstitialAd? get rewardedInterstitialAd => _rewardedInterstitialAd;

  /// Clear rewarded interstitial ad
  void clearRewardedInterstitial() {
    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
  }

  /// Register an app open ad
  void registerAppOpen(AppOpenAd ad) {
    _appOpenAd?.dispose();
    _appOpenAd = ad;
  }

  /// Get current app open ad
  AppOpenAd? get appOpenAd => _appOpenAd;

  /// Clear app open ad
  void clearAppOpen() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }

  /// Check if any banner ads are active
  bool get hasBannerAds => _bannerAds.isNotEmpty;

  /// Get number of active banner ads
  int get bannerAdCount => _bannerAds.length;

  /// Check if interstitial is ready
  bool get isInterstitialReady => _interstitialAd != null;

  /// Check if rewarded is ready
  bool get isRewardedReady => _rewardedAd != null;

  /// Check if rewarded interstitial is ready
  bool get isRewardedInterstitialReady => _rewardedInterstitialAd != null;

  /// Check if app open is ready
  bool get isAppOpenReady => _appOpenAd != null;

  /// Dispose all ads
  Future<void> disposeAll() async {
    // Dispose banners
    for (final ad in _bannerAds.values) {
      await ad.dispose();
    }
    _bannerAds.clear();

    // Dispose other ads
    await _interstitialAd?.dispose();
    _interstitialAd = null;

    await _rewardedAd?.dispose();
    _rewardedAd = null;

    await _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;

    await _appOpenAd?.dispose();
    _appOpenAd = null;
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'bannerCount': _bannerAds.length,
      'hasInterstitial': _interstitialAd != null,
      'hasRewarded': _rewardedAd != null,
      'hasRewardedInterstitial': _rewardedInterstitialAd != null,
      'hasAppOpen': _appOpenAd != null,
    };
  }
}

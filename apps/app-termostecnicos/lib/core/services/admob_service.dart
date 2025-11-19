import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../intermediate.dart';
import 'localstorage_service.dart';

part 'admob_service.g.dart';

/// AdMob state model
class AdMobState {
  final bool openAdsActive;
  final bool isPremiumAd;
  final int premiumAdHours;
  final bool altBannerAdIsLoaded;
  final bool onOpenAppAdIsLoaded;
  final bool rewardedAdIsLoaded;
  final NativeAd? altBannerAd;
  final NativeAd? onOpenAppAd;
  final RewardedAd? rewardedAd;

  const AdMobState({
    this.openAdsActive = false,
    this.isPremiumAd = false,
    this.premiumAdHours = 0,
    this.altBannerAdIsLoaded = false,
    this.onOpenAppAdIsLoaded = false,
    this.rewardedAdIsLoaded = false,
    this.altBannerAd,
    this.onOpenAppAd,
    this.rewardedAd,
  });

  AdMobState copyWith({
    bool? openAdsActive,
    bool? isPremiumAd,
    int? premiumAdHours,
    bool? altBannerAdIsLoaded,
    bool? onOpenAppAdIsLoaded,
    bool? rewardedAdIsLoaded,
    NativeAd? altBannerAd,
    NativeAd? onOpenAppAd,
    RewardedAd? rewardedAd,
  }) {
    return AdMobState(
      openAdsActive: openAdsActive ?? this.openAdsActive,
      isPremiumAd: isPremiumAd ?? this.isPremiumAd,
      premiumAdHours: premiumAdHours ?? this.premiumAdHours,
      altBannerAdIsLoaded: altBannerAdIsLoaded ?? this.altBannerAdIsLoaded,
      onOpenAppAdIsLoaded: onOpenAppAdIsLoaded ?? this.onOpenAppAdIsLoaded,
      rewardedAdIsLoaded: rewardedAdIsLoaded ?? this.rewardedAdIsLoaded,
      altBannerAd: altBannerAd ?? this.altBannerAd,
      onOpenAppAd: onOpenAppAd ?? this.onOpenAppAd,
      rewardedAd: rewardedAd ?? this.rewardedAd,
    );
  }
}

/// AdMob service provider
@riverpod
class AdMobService extends _$AdMobService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  @override
  AdMobState build() {
    return const AdMobState();
  }

  Future<void> init() async {
    if (await checkIsPremiumAd()) {
      return;
    } else {
      await getPremiumAd();

      loadNativeAd(
        admobId: GlobalEnvironment().altAdmobBanner,
        keywords: GlobalEnvironment().keywordsAds,
      );

      createRewardedAd(admobId: GlobalEnvironment().admobPremiado);

      if (await checkOpenAdsActive()) {
        onOpenApp(
          admobId: GlobalEnvironment().onOpenApp,
          keywords: GlobalEnvironment().keywordsAds,
        );
      }
    }
  }

  void loadNativeAd({
    required String admobId,
    required List<String> keywords,
  }) async {
    final ad = NativeAd(
      nativeAdOptions: NativeAdOptions(
        adChoicesPlacement: AdChoicesPlacement.topRightCorner,
        mediaAspectRatio: MediaAspectRatio.unknown,
        requestCustomMuteThisAd: false,
        shouldRequestMultipleImages: true,
        shouldReturnUrlsForImageAssets: false,
      ),
      adUnitId: admobId,
      request: AdRequest(nonPersonalizedAds: false, keywords: keywords),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) async {
          state = state.copyWith(altBannerAdIsLoaded: true);

          if (state.premiumAdHours > 0) {
            return;
          }

          Future.delayed(const Duration(seconds: 60), () {
            ad.dispose();
            state = state.copyWith(altBannerAdIsLoaded: false);

            loadNativeAd(
              admobId: GlobalEnvironment().altAdmobBanner,
              keywords: GlobalEnvironment().keywordsAds,
            );
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          state = state.copyWith(altBannerAdIsLoaded: false);
        },
        onAdOpened: (Ad ad) => {},
        onAdClosed: (Ad ad) => {},
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
      ),
    );

    state = state.copyWith(altBannerAd: ad);
    ad.load();
  }

  void onOpenApp({required String admobId, required List<String> keywords}) {
    final ad = NativeAd(
      nativeAdOptions: NativeAdOptions(
        adChoicesPlacement: AdChoicesPlacement.topRightCorner,
        mediaAspectRatio: MediaAspectRatio.square,
        requestCustomMuteThisAd: false,
        shouldRequestMultipleImages: false,
        shouldReturnUrlsForImageAssets: false,
      ),
      adUnitId: admobId,
      request: AdRequest(nonPersonalizedAds: false, keywords: keywords),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          state = state.copyWith(onOpenAppAdIsLoaded: true);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          state = state.copyWith(onOpenAppAdIsLoaded: false);
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    );

    state = state.copyWith(onOpenAppAd: ad);
    ad.load();
  }

  void createRewardedAd({required String admobId}) {
    if (state.premiumAdHours > 0) {
      return;
    }

    RewardedAd.load(
      adUnitId: admobId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          state = state.copyWith(rewardedAd: ad, rewardedAdIsLoaded: true);
        },
        onAdFailedToLoad: (error) {
          state = state.copyWith(rewardedAdIsLoaded: false);
        },
      ),
    );
  }

  void disposeAds() {
    state.altBannerAd?.dispose();
    state.onOpenAppAd?.dispose();
    state.rewardedAd?.dispose();
  }

  void setOpenAdsActive(bool value) {
    state = state.copyWith(openAdsActive: value);
    LocalStorageService().adicionar('openAdsActive', {
      'date': DateTime.now().toString(),
    });
  }

  Future<bool> checkOpenAdsActive() async {
    if (kIsWeb) {
      state = state.copyWith(openAdsActive: false);
      return false;
    }

    final data = await LocalStorageService().carregar('openAdsActive');
    if (data.isEmpty) {
      state = state.copyWith(openAdsActive: false);
      String gravar =
          DateTime.now().subtract(const Duration(days: 2)).toString();
      LocalStorageService().adicionar('openAdsActive', {'date': gravar});
      return true;
    }

    final date = DateTime.parse(data['date']);
    final now = DateTime.now();
    final difference = now.difference(date).inHours;

    if (difference >= 24) {
      state = state.copyWith(openAdsActive: true);
      return true;
    } else {
      state = state.copyWith(openAdsActive: false);
      return false;
    }
  }

  /// Sets premium ad hours and saves to local storage
  void setPremiumAd(int hours) {
    state = state.copyWith(isPremiumAd: true);
    LocalStorageService().adicionar('premiumAd', {
      'date': DateTime.now().add(Duration(hours: hours)).toString(),
    });
    getPremiumAd();
  }

  /// Checks if premium ad is active
  Future<bool> checkIsPremiumAd() async {
    final data = await LocalStorageService().carregar('premiumAd');
    if (data.isEmpty) {
      state = state.copyWith(isPremiumAd: false);
      return false;
    }

    final date = DateTime.parse(data['date']);
    final now = DateTime.now();
    final difference = now.difference(date).inHours;

    if (difference >= 0) {
      state = state.copyWith(isPremiumAd: false);
      return false;
    } else {
      state = state.copyWith(isPremiumAd: true);
      return true;
    }
  }

  /// Returns remaining premium ad hours
  Future<void> getPremiumAd() async {
    final data = await LocalStorageService().carregar('premiumAd');
    if (data.isEmpty) {
      state = state.copyWith(premiumAdHours: 0);
      return;
    }

    final date = DateTime.parse(data['date']);
    final now = DateTime.now();
    final difference = now.difference(date).inHours;

    if (difference >= 0) {
      state = state.copyWith(premiumAdHours: 0);
    } else {
      state = state.copyWith(premiumAdHours: difference.abs());
    }
  }
}

// Convenience providers for backward compatibility
@riverpod
NativeAd? altBannerAd(AltBannerAdRef ref) {
  return ref.watch(adMobServiceProvider).altBannerAd;
}

@riverpod
bool altBannerAdIsLoaded(AltBannerAdIsLoadedRef ref) {
  return ref.watch(adMobServiceProvider).altBannerAdIsLoaded;
}

@riverpod
NativeAd? onOpenAppAd(OnOpenAppAdRef ref) {
  return ref.watch(adMobServiceProvider).onOpenAppAd;
}

@riverpod
bool onOpenAppAdIsLoaded(OnOpenAppAdIsLoadedRef ref) {
  return ref.watch(adMobServiceProvider).onOpenAppAdIsLoaded;
}

@riverpod
RewardedAd? rewardedAd(RewardedAdRef ref) {
  return ref.watch(adMobServiceProvider).rewardedAd;
}

@riverpod
bool rewardedAdIsLoaded(RewardedAdIsLoadedRef ref) {
  return ref.watch(adMobServiceProvider).rewardedAdIsLoaded;
}

@riverpod
bool openAdsActive(OpenAdsActiveRef ref) {
  return ref.watch(adMobServiceProvider).openAdsActive;
}

@riverpod
bool isPremiumAd(IsPremiumAdRef ref) {
  return ref.watch(adMobServiceProvider).isPremiumAd;
}

@riverpod
int premiumAdHours(PremiumAdHoursRef ref) {
  return ref.watch(adMobServiceProvider).premiumAdHours;
}

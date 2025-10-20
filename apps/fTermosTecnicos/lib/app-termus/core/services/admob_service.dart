import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../intermediate.dart';
import 'localstorage_service.dart';

class AdmobRepository extends GetxController {
  static final AdmobRepository _instance = AdmobRepository._internal();

  factory AdmobRepository() {
    return _instance;
  }

  AdmobRepository._internal();

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  RxBool openAdsActive = false.obs;
  RxBool isPremiumAd = false.obs;
  RxInt premiumAdHours = 0.obs;

  late NativeAd? altBannerAd;
  RxBool altBannerAdIsLoaded = false.obs;

  late NativeAd? onOpenAppAd;
  RxBool onOpenAppAdIsLoaded = false.obs;

  late RewardedAd? rewardedAd;
  RxBool rewardedAdIsLoaded = false.obs;

  init() async {
    if (await checkIsPremiumAd()) {
      return;
    } else {
      getPremiumAd();

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
    altBannerAd = NativeAd(
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
          altBannerAdIsLoaded.value = true;

          if (premiumAdHours.value > 0) {
            return;
          }

          Future.delayed(const Duration(seconds: 60), () {
            ad.dispose();
            altBannerAdIsLoaded.value = false;

            loadNativeAd(
              admobId: GlobalEnvironment().altAdmobBanner,
              keywords: GlobalEnvironment().keywordsAds,
            );
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          altBannerAdIsLoaded.value = false;
        },
        onAdOpened: (Ad ad) => {},
        onAdClosed: (Ad ad) => {},
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
      ),
    );

    altBannerAd?.load();
  }

  void onOpenApp({required String admobId, required List<String> keywords}) {
    onOpenAppAd = NativeAd(
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
          onOpenAppAdIsLoaded.value = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    );

    onOpenAppAd?.load();
  }

  void createRewardedAd({required String admobId}) {
    if (premiumAdHours.value > 0) {
      return;
    }

    RewardedAd.load(
      adUnitId: admobId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          rewardedAdIsLoaded.value = true;
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    altBannerAd?.dispose();
    onOpenAppAd?.dispose();
    rewardedAd?.dispose();
  }

  void setOpenAdsActive(bool value) {
    openAdsActive.value = value;
    LocalStorageService().adicionar('openAdsActive', {
      'date': DateTime.now().toString(),
    });
  }

  Future<bool> checkOpenAdsActive() async {
    if (GetPlatform.isWeb) {
      openAdsActive.value = false;
      return false;
    }

    final data = await LocalStorageService().carregar('openAdsActive');
    if (data.isEmpty) {
      openAdsActive.value = false;
      String gravar =
          DateTime.now().subtract(const Duration(days: 2)).toString();
      LocalStorageService().adicionar('openAdsActive', {'date': gravar});
      return true;
    }

    final date = DateTime.parse(data['date']);
    final now = DateTime.now();
    final difference = now.difference(date).inHours;

    if (difference >= 24) {
      openAdsActive.value = true;
      return true;
    } else {
      openAdsActive.value = false;
      return false;
    }
  }

  //função vai receber x horas e deve gravar no localstorage a data atual + x horas
  void setPremiumAd(int hours) {
    isPremiumAd.value = true;
    LocalStorageService().adicionar('premiumAd', {
      'date': DateTime.now().add(Duration(hours: hours)).toString(),
    });
    getPremiumAd();
  }

  // valida se o premiumAd está ativo
  Future<bool> checkIsPremiumAd() async {
    final data = await LocalStorageService().carregar('premiumAd');
    if (data.isEmpty) {
      isPremiumAd.value = false;
      return false;
    }

    final date = DateTime.parse(data['date']);
    final now = DateTime.now();
    final difference = now.difference(date).inHours;

    if (difference >= 0) {
      isPremiumAd.value = false;
      return false;
    } else {
      isPremiumAd.value = true;
      return true;
    }
  }

  // retorna na função o tempo restante do premiumAd
  Future<void> getPremiumAd() async {
    final data = await LocalStorageService().carregar('premiumAd');
    if (data.isEmpty) {
      premiumAdHours.value = 0;
      return;
    }

    final date = DateTime.parse(data['date']);
    final now = DateTime.now();
    final difference = now.difference(date).inHours;

    if (difference >= 0) {
      premiumAdHours.value = 0;
    } else {
      premiumAdHours.value = difference.abs();
    }
  }
}

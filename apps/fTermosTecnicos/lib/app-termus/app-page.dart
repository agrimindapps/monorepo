import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'core/services/admob_service.dart';
import 'core/services/in_app_purchase_service.dart';
import 'core/services/revenuecat_service.dart';
import 'core/themes/manager.dart';
import 'core/widgets/admob/ads_open_app_widget.dart';
import 'const/revenuecat_const.dart';
import 'router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Timer? _timer, _timerTheme;
  ThemeData currentTheme = ThemeManager().currentTheme;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initPlatformState() async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      EntitlementInfo? entitlement =
          customerInfo.entitlements.all[entitlementID];
      RevenuecatService.entitlementIsActive = entitlement?.isActive ?? false;

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    if (GetPlatform.isMobile) {
      checkPremium();

      Future.delayed(const Duration(seconds: 6), () async {
        if (!InAppPurchaseService().isPremium.value) {
          if (await RevenuecatService.restorePurchases()) {
            checkPremium();
          }
        }
      });
    }

    _timerTheme = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        currentTheme = ThemeManager().currentTheme;
      });
    });

    if (GetPlatform.isMobile) initPlatformState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerTheme?.cancel();
    super.dispose();
  }

  void checkPremium() async {
    bool local = await InAppPurchaseService().checkSignature();
    if (local != InAppPurchaseService().isPremium.value) {
      InAppPurchaseService().isPremium.value = local;
      if (InAppPurchaseService().isPremium.value) {
        AdmobRepository().openAdsActive.value = false;
        AdmobRepository().isPremiumAd.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Termos Técnicos',
      debugShowCheckedModeBanner: false,
      theme: currentTheme,
      home: Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: Stack(
          children: [
            Navigator(
              key: navigatorKey,
              initialRoute: '/',
              onGenerateRoute: Routes.generateRoute,
            ),
            _openAppAd()
          ],
        ),
        // bottomNavigationBar: _bottomNavigatorBar(),
      ),
    );
  }

  Widget _openAppAd() {
    if (GetPlatform.isWeb) {
      return const SizedBox.shrink();
    }

    if (AdmobRepository().isPremiumAd.value ||
        InAppPurchaseService().isPremium.value) {
      AdmobRepository().openAdsActive.value = false;
      return const SizedBox.shrink();
    }

    return OpenAppAd(
      navigatorKey: navigatorKey,
    );
  }

  // Widget _bottomNavigatorBar() {
  //   return Obx(
  //     () {
  //       if (AdmobRepository().openAdsActive.value) {
  //         return const SizedBox.shrink();
  //       }

  //       return BottomNavigator(navigatorKey: navigatorKey);
  //     },
  //   );
  // }
}

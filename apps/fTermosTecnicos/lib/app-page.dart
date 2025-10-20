import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'core/services/admob_service.dart';
import 'core/services/in_app_purchase_service.dart';
import 'core/services/revenuecat_service.dart';
import 'core/theme/theme_providers.dart';
import 'core/widgets/admob/ads_open_app_widget.dart';
import 'core/router/app_router.dart';
import 'const/revenuecat_const.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  Timer? _timer;

  Future<void> initPlatformState() async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      EntitlementInfo? entitlement =
          customerInfo.entitlements.all[entitlementID];
      RevenuecatService.entitlementIsActive = entitlement?.isActive ?? false;

      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      checkPremium();

      Future.delayed(const Duration(seconds: 6), () async {
        if (!InAppPurchaseService().isPremium.value) {
          if (await RevenuecatService.restorePurchases()) {
            checkPremium();
          }
        }
      });

      initPlatformState();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void checkPremium() async {
    // Premium status is now handled by the Premium feature
    ref.read(premiumStatusNotifierProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(currentThemeModeProvider);
    final lightThemeData = ref.watch(lightThemeProvider);
    final darkThemeData = ref.watch(darkThemeProvider);

    return MaterialApp.router(
      title: 'Termos Técnicos',
      debugShowCheckedModeBanner: false,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade300,
          body: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              _openAppAd(),
            ],
          ),
        );
      },
    );
  }

  Widget _openAppAd() {
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    final isPremiumAd = ref.watch(isPremiumAdProvider);
    final isPremiumUser = ref.watch(isPremiumProvider);

    if (isPremiumAd || isPremiumUser) {
      return const SizedBox.shrink();
    }

    return OpenAppAd(
      navigatorKey: rootNavigatorKey,
    );
  }
}

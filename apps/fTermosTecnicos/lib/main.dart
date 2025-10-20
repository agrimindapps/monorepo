import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as purchases;

import 'package:core/core.dart';

import 'app-termus/app-page.dart';
import 'app-termus/const/environment_const.dart';
import 'app-termus/const/firebase_consts.dart';
import 'app-termus/const/revenuecat_const.dart';
import 'app-termus/hive_models/comentarios_models.dart';
import 'app-termus/core/services/admob_service.dart';
import 'app-termus/core/services/in_app_purchase_service.dart';
import 'app-termus/core/services/revenuecat_service.dart';
import 'app-termus/core/themes/manager.dart';

void main() async {
  if (GetPlatform.isIOS || GetPlatform.isMacOS) {
    RevenuecatService(
      store: purchases.Store.appStore,
      apiKey: appleApiKey,
    );
  } else if (GetPlatform.isAndroid) {
    RevenuecatService(
      store: purchases.Store.playStore,
      apiKey: googleApiKey,
    );
  }

  WidgetsFlutterBinding.ensureInitialized();
  if (!GetPlatform.isWeb) DartPluginRegistrant.ensureInitialized();

  usePathUrlStrategy();

  // Initialize production environment using core's PackageInfo
  await GlobalEnvironment.initialize();

  // Initialize Hive using core package
  await Hive.initFlutter();

  // Register custom adapters
  Hive.registerAdapter(ComentariosAdapter());

  ThemeData currentTheme = ThemeManager().currentTheme;

  if (GetPlatform.isMobile) {
    await InAppPurchaseService().checkSignature();

    await AdmobRepository.initialize();
    AdmobRepository().init();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase services from core package
  final analyticsService = FirebaseAnalyticsService();
  final crashlyticsService = FirebaseCrashlyticsService();

  Future.delayed(const Duration(milliseconds: 500), () async {
    if (GetPlatform.isMobile) await _configureSDK();
  });

  if (GetPlatform.isMobile) {
    runZonedGuarded<Future<void>>(() async {
      runApp(GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: currentTheme,
        home: const App(),
      ));
    }, (error, stackTrace) {
      crashlyticsService.recordError(
        exception: error,
        stackTrace: stackTrace,
        fatal: true,
      );
    });
  } else {
    runApp(GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: currentTheme,
      home: const App(),
    ));
  }
}

Future<void> _configureSDK() async {
  await purchases.Purchases.setLogLevel(purchases.LogLevel.error);

  purchases.PurchasesConfiguration configuration;
  if (RevenuecatService.isForAmazonAppstore()) {
    configuration = purchases.AmazonConfiguration(RevenuecatService.instance.apiKey)
      ..appUserID = null
      ..purchasesAreCompletedBy = const purchases.PurchasesAreCompletedByRevenueCat();
  } else {
    configuration = purchases.PurchasesConfiguration(RevenuecatService.instance.apiKey)
      ..appUserID = null
      ..purchasesAreCompletedBy = const purchases.PurchasesAreCompletedByRevenueCat();
  }
  await purchases.Purchases.configure(configuration);
}

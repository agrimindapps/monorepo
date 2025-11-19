import 'dart:async';

import 'dart:ui';

import 'package:flutter/foundation.dart'
    show debugPrint, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as purchases;

import 'package:core/core.dart' hide Column;

import 'app_page.dart';
import 'const/environment_const.dart';
import 'const/firebase_consts.dart';
import 'const/revenuecat_const.dart';
import 'core/services/admob_service.dart';
import 'core/services/in_app_purchase_service.dart';
import 'core/services/revenuecat_service.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) DartPluginRegistrant.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Initialize production environment using core's PackageInfo
  await GlobalEnvironment.initialize();

  // Initialize Firebase with error handling (BEFORE DI)
  bool firebaseInitialized = false;
  FirebaseCrashlyticsService? crashlyticsService;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;

    // Initialize Firebase services from core package
    crashlyticsService = FirebaseCrashlyticsService();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint(
      'App will continue without Firebase features (local-first mode)',
    );
    // App continues without Firebase - local storage works independently
  }

  // Initialize DI (AFTER Firebase)
  await configureDependencies();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    // RevenueCat setup
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      RevenuecatService(store: purchases.Store.appStore, apiKey: appleApiKey);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      RevenuecatService(store: purchases.Store.playStore, apiKey: googleApiKey);
    }

    await InAppPurchaseService().checkSignature();

    await AdMobService.initialize();
    // AdMob init() will be called through Riverpod providers when needed
  }

  Future.delayed(const Duration(milliseconds: 500), () async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      await _configureSDK();
    }
  });

  if (!kIsWeb &&
      firebaseInitialized &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    runZonedGuarded<Future<void>>(
      () async {
        runApp(const ProviderScope(child: App()));
      },
      (error, stackTrace) {
        crashlyticsService?.recordError(
          exception: error,
          stackTrace: stackTrace,
          fatal: true,
        );
      },
    );
  } else {
    runApp(const ProviderScope(child: App()));
  }
}

Future<void> _configureSDK() async {
  await purchases.Purchases.setLogLevel(purchases.LogLevel.error);

  purchases.PurchasesConfiguration configuration;
  if (RevenuecatService.isForAmazonAppstore()) {
    configuration =
        purchases.AmazonConfiguration(RevenuecatService.instance.apiKey)
          ..appUserID = null
          ..purchasesAreCompletedBy =
              const purchases.PurchasesAreCompletedByRevenueCat();
  } else {
    configuration =
        purchases.PurchasesConfiguration(RevenuecatService.instance.apiKey)
          ..appUserID = null
          ..purchasesAreCompletedBy =
              const purchases.PurchasesAreCompletedByRevenueCat();
  }
  await purchases.Purchases.configure(configuration);
}

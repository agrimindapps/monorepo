import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as purchases;

import 'package:core/core.dart';

import 'app-page.dart';
import 'const/environment_const.dart';
import 'const/firebase_consts.dart';
import 'const/revenuecat_const.dart';
import 'hive_models/comentarios_models.dart';
import 'core/services/admob_service.dart';
import 'core/services/in_app_purchase_service.dart';
import 'core/services/revenuecat_service.dart';
import 'core/di/injection.dart';

void main() async {
  // RevenueCat setup
  if (Platform.isIOS || Platform.isMacOS) {
    RevenuecatService(
      store: purchases.Store.appStore,
      apiKey: appleApiKey,
    );
  } else if (Platform.isAndroid) {
    RevenuecatService(
      store: purchases.Store.playStore,
      apiKey: googleApiKey,
    );
  }

  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) DartPluginRegistrant.ensureInitialized();

  usePathUrlStrategy();

  // Initialize production environment using core's PackageInfo
  await GlobalEnvironment.initialize();

  // Initialize Hive using core package
  await Hive.initFlutter();

  // Register custom adapters
  Hive.registerAdapter(ComentariosAdapter());

  // Initialize DI
  await configureDependencies();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
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
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _configureSDK();
    }
  });

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    runZonedGuarded<Future<void>>(() async {
      runApp(const ProviderScope(child: App()));
    }, (error, stackTrace) {
      crashlyticsService.recordError(
        exception: error,
        stackTrace: stackTrace,
        fatal: true,
      );
    });
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

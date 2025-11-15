import 'package:core/core.dart';
import 'package:dio/dio.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

/// Module for registering external dependencies from core package
@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio();

  // @lazySingleton
  // IAnalyticsRepository get analyticsRepository => FirebaseAnalyticsService();

  // @lazySingleton
  // FirebaseAnalyticsService get firebaseAnalyticsService =>
  //     FirebaseAnalyticsService();

  // @lazySingleton
  // ICrashlyticsRepository get crashlyticsRepository =>
  //     FirebaseCrashlyticsService();

  // @lazySingleton
  // IPerformanceRepository get performanceRepository => PerformanceService();

  // @lazySingleton
  // ISubscriptionRepository get subscriptionRepository => RevenueCatService();

  // @lazySingleton
  // INotificationRepository get notificationRepository =>
  //     LocalNotificationService();

  // @lazySingleton
  // IAuthRepository get authRepository => FirebaseAuthService();

  // @lazySingleton
  // IDriftManager get driftManager => DriftManager.instance;

  // @preResolve
  // Future<SharedPreferences> get sharedPreferences =>
  //     SharedPreferences.getInstance();

  // @lazySingleton
  // FlutterSecureStorage get flutterSecureStorage => const FlutterSecureStorage();
}

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => getIt.init();

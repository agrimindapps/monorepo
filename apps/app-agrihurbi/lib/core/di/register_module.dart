import 'package:core/core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Module for registering external dependencies from core package
@module
abstract class RegisterModule {
  @lazySingleton
  IAnalyticsRepository get analyticsRepository => FirebaseAnalyticsService();

  @lazySingleton
  FirebaseAnalyticsService get firebaseAnalyticsService =>
      FirebaseAnalyticsService();

  @lazySingleton
  ICrashlyticsRepository get crashlyticsRepository =>
      FirebaseCrashlyticsService();

  @lazySingleton
  IPerformanceRepository get performanceRepository => PerformanceService();

  @lazySingleton
  ISubscriptionRepository get subscriptionRepository => RevenueCatService();

  @lazySingleton
  INotificationRepository get notificationRepository =>
      LocalNotificationService();

  @lazySingleton
  IAuthRepository get authRepository => FirebaseAuthService();

  // @lazySingleton
  // IDriftManager get driftManager => DriftManager.instance;

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get flutterSecureStorage => const FlutterSecureStorage();
}

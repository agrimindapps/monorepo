// This module has been migrated to Riverpod dependency injection
// All dependencies are now managed through providers in lib/core/providers/
// TODO: Remove this file as it's no longer used

/*
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Module for registering external dependencies from core package
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio();

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

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  RevenueCatService get revenueCatService => RevenueCatService();

  @lazySingleton
  EnhancedAccountDeletionService get accountDeletionService =>
      EnhancedAccountDeletionService(authRepository: FirebaseAuthService());

  // Drift Database é registrado no DriftModule
}
*/

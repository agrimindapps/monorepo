import 'package:core/core.dart';

/// Module for registering external dependencies from core package
@module
abstract class RegisterModule {
  // Core Services from core package
  @lazySingleton
  IAnalyticsRepository get analyticsRepository => FirebaseAnalyticsService();

  @lazySingleton
  ICrashlyticsRepository get crashlyticsRepository => FirebaseCrashlyticsService();

  @lazySingleton
  IPerformanceRepository get performanceRepository => PerformanceService();

  @lazySingleton
  ISubscriptionRepository get subscriptionRepository => RevenueCatService();

  @lazySingleton
  INotificationRepository get notificationRepository => LocalNotificationService();

  @lazySingleton
  IAuthRepository get authRepository => FirebaseAuthService();
}

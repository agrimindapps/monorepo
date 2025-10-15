import 'package:injectable/injectable.dart';
import 'package:core/core.dart';
import 'package:core/src/services/optimized_analytics_wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_state_notifier.dart';

/// Module for third-party dependencies
/// Register external dependencies that aren't annotated with @injectable
@module
abstract class ThirdPartyModule {
  /// Firebase Firestore instance
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Firebase Auth instance
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  /// SharedPreferences instance
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  /// AuthStateNotifier singleton
  @lazySingleton
  AuthStateNotifier get authStateNotifier => AuthStateNotifier.instance;

  // TODO: Add other third-party dependencies here
  // Example:
  // @lazySingleton
  // Dio get dio => Dio();
}

/// Module for core services from the core package
@module
abstract class CoreServicesModule {
  /// Analytics Repository from core package
  @lazySingleton
  IAnalyticsRepository get analyticsRepository => FirebaseAnalyticsService();

  /// OptimizedAnalyticsWrapper for efficient event logging
  @lazySingleton
  OptimizedAnalyticsWrapper analyticsWrapper(IAnalyticsRepository analyticsRepo) =>
      OptimizedAnalyticsWrapper(analyticsRepo);

  /// Enhanced Notification Repository from core package
  /// Note: Requires manual initialization in main()
  @lazySingleton
  IEnhancedNotificationRepository get notificationRepository =>
      EnhancedNotificationService();

  // Note: ShareService doesn't need core dependencies
  // AnalyticsService, ShareService, and NotificationService are registered
  // via @lazySingleton annotations in their class definitions
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:core/core.dart' as core hide CacheService;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../cache/cache_service.dart';
import '../interfaces/logging_service.dart';
import '../logging/datasources/log_local_datasource.dart';
import '../logging/datasources/log_local_datasource_simple_impl.dart';
import '../logging/repositories/log_repository.dart';
import '../logging/repositories/log_repository_impl.dart';
import '../notifications/notification_service.dart';
import '../performance/lazy_loader.dart';
import '../performance/performance_service.dart';
import '../services/logging_service_impl.dart';
import '../services/mock_analytics_service.dart';

part 'core_services_providers.g.dart';

// ============================================================================
// EXTERNAL CORE SERVICES (Firebase, RevenueCat)
// ============================================================================

@riverpod
core.IAuthRepository externalAuthRepository(Ref ref) {
  return core.FirebaseAuthService();
}

@riverpod
core.IAnalyticsRepository analyticsRepository(Ref ref) {
  return kDebugMode ? MockAnalyticsService() : core.FirebaseAnalyticsService();
}

@riverpod
core.ICrashlyticsRepository crashlyticsRepository(Ref ref) {
  return core.FirebaseCrashlyticsService();
}

@riverpod
core.IPerformanceRepository performanceRepository(Ref ref) {
  return core.PerformanceService();
}

@riverpod
core.ISubscriptionRepository subscriptionRepository(Ref ref) {
  return core.RevenueCatService();
}

@riverpod
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@riverpod
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@riverpod
GoogleSignIn googleSignIn(Ref ref) {
  if (kIsWeb) {
    return GoogleSignIn(clientId: '');
  }
  return GoogleSignIn();
}


// ============================================================================
// LOCAL CORE SERVICES
// ============================================================================

@riverpod
CacheService cacheService(Ref ref) {
  return CacheService();
}

@riverpod
NotificationService? notificationService(Ref ref) {
  // Only on mobile platforms
  if (kIsWeb) return null;
  return NotificationService();
}

@riverpod
LocalPerformanceService localPerformanceService(Ref ref) {
  return LocalPerformanceService();
}

@riverpod
LazyLoader lazyLoader(Ref ref) {
  return LazyLoader();
}

// ============================================================================
// LOGGING SERVICES
// ============================================================================

@riverpod
LogLocalDataSource logLocalDataSource(Ref ref) {
  return LogLocalDataSourceSimpleImpl();
}

@riverpod
LogRepository logRepository(Ref ref) {
  return LogRepositoryImpl(
    localDataSource: ref.watch(logLocalDataSourceProvider),
  );
}

@riverpod
ILoggingService loggingService(Ref ref) {
  return LoggingServiceImpl(
    logRepository: ref.watch(logRepositoryProvider),
    analyticsRepository: ref.watch(analyticsRepositoryProvider),
    crashlyticsRepository: ref.watch(crashlyticsRepositoryProvider),
  );
}

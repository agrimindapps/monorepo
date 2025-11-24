import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:core/core.dart' as core;
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
import '../performance/performance_service.dart' as local_perf;
import '../services/logging_service_impl.dart';
import '../services/mock_analytics_service.dart';

part 'core_services_providers.g.dart';

// ============================================================================
// EXTERNAL CORE SERVICES (Firebase, RevenueCat)
// ============================================================================

@riverpod
core.IAuthRepository externalAuthRepository(ExternalAuthRepositoryRef ref) {
  return core.FirebaseAuthService();
}

@riverpod
core.IAnalyticsRepository analyticsRepository(AnalyticsRepositoryRef ref) {
  return kDebugMode ? MockAnalyticsService() : core.FirebaseAnalyticsService();
}

@riverpod
core.ICrashlyticsRepository crashlyticsRepository(
  CrashlyticsRepositoryRef ref,
) {
  return core.FirebaseCrashlyticsService();
}

@riverpod
core.IPerformanceRepository performanceRepository(
  PerformanceRepositoryRef ref,
) {
  return core.PerformanceService();
}

@riverpod
core.ISubscriptionRepository subscriptionRepository(
  SubscriptionRepositoryRef ref,
) {
  return core.RevenueCatService();
}

@riverpod
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

@riverpod
GoogleSignIn googleSignIn(GoogleSignInRef ref) {
  if (kIsWeb) {
    return GoogleSignIn(clientId: '');
  }
  return GoogleSignIn();
}


// ============================================================================
// LOCAL CORE SERVICES
// ============================================================================

@riverpod
CacheService cacheService(CacheServiceRef ref) {
  return CacheService();
}

@riverpod
NotificationService? notificationService(NotificationServiceRef ref) {
  // Only on mobile platforms
  if (kIsWeb) return null;
  return NotificationService();
}

@riverpod
local_perf.PerformanceService localPerformanceService(
  LocalPerformanceServiceRef ref,
) {
  return local_perf.PerformanceService();
}

@riverpod
LazyLoader lazyLoader(LazyLoaderRef ref) {
  return LazyLoader();
}

// ============================================================================
// LOGGING SERVICES
// ============================================================================

@riverpod
LogLocalDataSource logLocalDataSource(LogLocalDataSourceRef ref) {
  return LogLocalDataSourceSimpleImpl();
}

@riverpod
LogRepository logRepository(LogRepositoryRef ref) {
  return LogRepositoryImpl(
    localDataSource: ref.watch(logLocalDataSourceProvider),
  );
}

@riverpod
ILoggingService loggingService(LoggingServiceRef ref) {
  return LoggingServiceImpl(
    logRepository: ref.watch(logRepositoryProvider),
    analyticsRepository: ref.watch(analyticsRepositoryProvider),
    crashlyticsRepository: ref.watch(crashlyticsRepositoryProvider),
  );
}

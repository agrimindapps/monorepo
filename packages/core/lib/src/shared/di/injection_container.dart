import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../domain/repositories/i_analytics_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_crashlytics_repository.dart';
import '../../domain/repositories/i_local_storage_repository.dart';
import '../../domain/repositories/i_storage_repository.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../domain/services/i_box_registry_service.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../infrastructure/services/box_registry_service.dart';
import '../../infrastructure/services/firebase_analytics_service.dart';
import '../../infrastructure/services/firebase_auth_service.dart';
import '../../infrastructure/services/firebase_crashlytics_service.dart';
import '../../infrastructure/services/firebase_storage_service.dart';
import '../../infrastructure/services/hive_storage_service.dart';
import '../../infrastructure/services/mock_analytics_service.dart';
import '../../infrastructure/services/revenue_cat_service.dart';
import '../../shared/config/environment_config.dart';
import '../../../repositories/license_repository.dart';
import '../../../repositories/license_local_storage.dart';
import '../../../services/license_service.dart';
import '../../sync/interfaces/i_cache_manager.dart';
import '../../sync/interfaces/i_network_monitor.dart';
import '../../sync/interfaces/i_sync_orchestrator.dart';
import '../../sync/implementations/cache_manager_impl.dart';
import '../../sync/implementations/network_monitor_impl.dart';
import '../../sync/implementations/sync_orchestrator_impl.dart';
import '../../sync/factories/sync_service_factory.dart';
import '../../sync/config/sync_feature_flags.dart';
import '../services/uuid_service.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Dependency Injection Container for Core Package
///
/// Manages service registration and dependency resolution for all core services.
/// Services are registered in dependency order to ensure proper initialization.
class InjectionContainer {
  /// Initializes all core services and their dependencies
  ///
  /// Must be called before using any services from the core package.
  /// Throws exception if initialization fails.
  static Future<void> init() async {
    try {
      // Initialize Firebase first
      await Firebase.initializeApp();

      // Register Core Services (Order matters due to dependencies)

      // 1. BoxRegistryService - Required by HiveStorageService
      getIt.registerLazySingleton<IBoxRegistryService>(
        () => BoxRegistryService(),
      );

      // 2. Firebase Services
      getIt.registerLazySingleton<IAuthRepository>(() => FirebaseAuthService());

      getIt.registerLazySingleton<ICrashlyticsRepository>(
        () => FirebaseCrashlyticsService(),
      );

      getIt.registerLazySingleton<IStorageRepository>(
        () => FirebaseStorageService(),
      );

      // 3. Analytics - usa Mock em debug, Firebase em produção
      getIt.registerLazySingleton<IAnalyticsRepository>(
        () =>
            EnvironmentConfig.isDebugMode
                ? MockAnalyticsService()
                : FirebaseAnalyticsService(),
      );

      // 4. Hive Storage - Depends on IBoxRegistryService
      // Skip on Web platform due to Hive limitations
      if (!kIsWeb) {
        getIt.registerLazySingleton<ILocalStorageRepository>(
          () => HiveStorageService(getIt<IBoxRegistryService>()),
        );
      } else if (kDebugMode) {
        print('⚠️ [Core Package] ILocalStorageRepository skipped on Web platform (Hive limitations)');
      }

      // 5. RevenueCat para gerenciar assinaturas
      getIt.registerLazySingleton<ISubscriptionRepository>(
        () => RevenueCatService(),
      );

      // 5.5. UUID Service - Geração de identificadores únicos
      getIt.registerLazySingleton<UuidService>(
        () => UuidService(),
      );

      // 6. License System - License Repository and Service
      getIt.registerLazySingleton<LicenseRepository>(
        () => LicenseLocalStorage(),
      );

      getIt.registerLazySingleton<LicenseService>(
        () => LicenseService(getIt<LicenseRepository>()),
      );

      // Register Use Cases with explicit types
      getIt.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(
          getIt<IAuthRepository>(),
          getIt<IAnalyticsRepository>(),
        ),
      );

      getIt.registerLazySingleton<LogoutUseCase>(
        () => LogoutUseCase(
          getIt<IAuthRepository>(),
          getIt<IAnalyticsRepository>(),
        ),
      );

      // 7. New SOLID Sync Services (with feature flags)
      _registerSyncServices();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[InjectionContainer] Initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Registers the new SOLID sync services with feature flag support
  ///
  /// Only registers services if their corresponding feature flags are enabled
  static void _registerSyncServices() {
    final flags = SyncFeatureFlags.instance;
    
    if (kDebugMode) {
      debugPrint('[InjectionContainer] Sync feature flags: ${flags.getDebugInfo()}');
    }
    
    // Cache Manager
    if (flags.useNewCacheManager) {
      getIt.registerLazySingleton<ICacheManager>(
        () => CacheManagerImpl(),
      );
      
      if (kDebugMode) {
        debugPrint('[InjectionContainer] Registered new CacheManager');
      }
    }
    
    // Network Monitor
    if (flags.useNewNetworkMonitor) {
      getIt.registerLazySingleton<INetworkMonitor>(
        () => NetworkMonitorImpl(),
      );
      
      if (kDebugMode) {
        debugPrint('[InjectionContainer] Registered new NetworkMonitor');
      }
    }
    
    // Sync Service Factory
    if (flags.useNewSyncServiceFactory) {
      getIt.registerLazySingleton<SyncServiceFactory>(
        () => SyncServiceFactory.instance,
      );
      
      if (kDebugMode) {
        debugPrint('[InjectionContainer] Registered SyncServiceFactory');
      }
    }
    
    // Sync Orchestrator (depends on Cache and Network Monitor)
    if (flags.useNewSyncOrchestrator && 
        flags.useNewCacheManager && 
        flags.useNewNetworkMonitor) {
      getIt.registerLazySingleton<ISyncOrchestrator>(
        () => SyncOrchestratorImpl(
          cacheManager: getIt<ICacheManager>(),
          networkMonitor: getIt<INetworkMonitor>(),
        ),
      );
      
      if (kDebugMode) {
        debugPrint('[InjectionContainer] Registered new SyncOrchestrator');
      }
    }
  }

  /// Resets all registered services
  ///
  /// Used for testing or when reinitializing the container
  static void reset() {
    getIt.reset();
  }
}

import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';

// ❌ REMOVIDO: import '../../features/DetalheDefensivos/di/defensivo_details_di.dart';
import '../../features/analytics/analytics_service.dart';
// ❌ REMOVIDO: import '../../features/comentarios/di/comentarios_di.dart'; (via @LazySingleton)
import '../../features/comentarios/domain/comentarios_service.dart';
import '../../features/defensivos/data/services/defensivos_grouping_service.dart';
// ❌ REMOVIDO: import '../../features/defensivos/di/defensivos_di.dart'; // Unused after consolidation
// ✅ Diagnosticos imports removed - now managed by Injectable
import '../../features/favoritos/domain/favoritos_navigation_service.dart';
import '../../features/favoritos/favoritos_di.dart';
// ❌ REMOVIDO: import '../../features/pragas/di/pragas_di.dart'; (via @LazySingleton)
import '../../features/settings/di/device_management_di.dart';
import '../../features/settings/di/settings_di.dart';
import '../../features/settings/di/tts_module.dart';
// DEPRECATED: import '../data/repositories/comentarios_legacy_repository.dart';
// DEPRECATED: import '../data/repositories/premium_legacy_repository.dart';
import '../../database/repositories/fitossanitarios_repository.dart';
import '../../database/repositories/pragas_repository.dart';
import '../../database/repositories/culturas_repository.dart';
import '../../database/receituagro_database.dart';
import '../interfaces/i_premium_service.dart';
import '../navigation/agricultural_navigation_extension.dart';
import '../services/app_data_manager.dart';
import '../services/app_data_manager_drift.dart';
import '../services/cloud_functions_service.dart';
import '../services/device_identity_service.dart';
import '../services/diagnostico_integration_service.dart';
import '../services/firebase_messaging_service.dart';
import '../services/mock_premium_service.dart';
import '../services/premium_service.dart';
import '../services/promotional_notification_manager.dart';
import '../services/receituagro_data_cleaner.dart';
import '../services/receituagro_navigation_service.dart';
import '../services/receituagro_notification_service.dart';
import '../services/remote_config_service.dart';
import '../services/data_migration_service.dart';
import '../sync/sync_operations.dart';
import '../sync/sync_queue.dart';
import 'core_package_integration.dart';
import 'injection.dart' as injectable;
import 'modules/account_deletion_module.dart';
import 'repositories_di.dart';

final sl = core.GetIt.instance;

Future<void> init() async {
  await core.InjectionContainer.init();

  // ⚠️ IMPORTANTE: Registrar datasources e services SEM @injectable ANTES do Injectable
  // O Injectable precisa deles para criar repositories via @LazySingleton
  await DeviceManagementDI.registerDataSources(sl);

  // ✅ FavoritosDataResolverStrategyRegistry agora usa lazy loading dos repos
  // Não precisa registrá-los cedo mais
  FavoritosDI.registerServices(); // ⚠️ FavoritosService com lazy loading (não precisa de FavoritoRepository no construtor)

  await injectable.configureDependencies();
  FavoritosDI.registerRepository(); // ✅ Registra FavoritosRepositorySimplified como classe concreta
  configureAllRepositoriesDependencies();

  // ✅ FIXED: Registrar serviços que dependem de IHiveManager manualmente
  // (IHiveManager não é anotado com @injectable no core package)
  if (!sl.isRegistered<SyncQueue>()) {
    sl.registerLazySingleton<SyncQueue>(
      () => SyncQueue(sl<core.IHiveManager>()),
    );
  }

  if (!sl.isRegistered<SyncOperations>()) {
    sl.registerLazySingleton<SyncOperations>(
      () => SyncOperations(sl<SyncQueue>(), sl<core.ConnectivityService>()),
    );
  }

  // DataIntegrityService removed - no longer needed

  // ℹ️ SyncDIModule.init() é chamado no main.dart após Hive estar pronto
  // Não registramos aqui para evitar duplicação

  sl.registerLazySingleton<core.IAppDataCleaner>(
    () => ReceitaAgroDataCleaner(),
  );
  AccountDeletionModule.init(sl);
  if (!sl.isRegistered<core.FirebaseDeviceService>()) {
    sl.registerLazySingleton<core.FirebaseDeviceService>(
      () => core.FirebaseDeviceService(),
    );
  }

  // ✅ Registrar apenas use cases e services (IDeviceRepository já registrado via @LazySingleton)
  await DeviceManagementDI.registerUseCasesAndServices(sl);
  if (!sl.isRegistered<core.NavigationConfigurationService>()) {
    sl.registerLazySingleton<core.NavigationConfigurationService>(
      () => core.NavigationConfigurationService(),
    );
  }

  if (!sl.isRegistered<core.NavigationAnalyticsService>()) {
    sl.registerLazySingleton<core.NavigationAnalyticsService>(
      () =>
          core.NavigationAnalyticsService(sl<core.FirebaseAnalyticsService>()),
    );
  }

  if (!sl.isRegistered<core.EnhancedNavigationService>()) {
    sl.registerLazySingleton<core.EnhancedNavigationService>(
      () => core.EnhancedNavigationService(),
    );
  }
  sl.registerLazySingleton<DeviceIdentityService>(
    () => DeviceIdentityService.instance,
  );
  await CorePackageIntegration.initializeAuthServices();
  sl.registerLazySingleton<ReceitaAgroRemoteConfigService>(
    () => ReceitaAgroRemoteConfigService.instance,
  );
  sl.registerLazySingleton<ReceitaAgroCloudFunctionsService>(
    () => ReceitaAgroCloudFunctionsService.instance,
  );
  if (!sl.isRegistered<core.UnifiedSyncManager>()) {
    sl.registerLazySingleton<core.UnifiedSyncManager>(
      () => core.UnifiedSyncManager.instance,
    );
  }
  if (!sl.isRegistered<core.IBoxRegistryService>()) {
    sl.registerLazySingleton<core.IBoxRegistryService>(
      () => core.BoxRegistryService(),
    );
  }
  if (!sl.isRegistered<core.HiveStorageService>()) {
    sl.registerLazySingleton<core.HiveStorageService>(
      () => core.HiveStorageService(sl<core.IBoxRegistryService>()),
    );
  }
  if (!sl.isRegistered<core.ISubscriptionRepository>()) {
    sl.registerLazySingleton<core.ISubscriptionRepository>(
      () => core.RevenueCatService(),
    );
  }
  sl.registerLazySingleton<core.IAppRatingRepository>(
    () => core.AppRatingService(
      appStoreId: '967785485', // ReceitaAgro iOS App Store ID
      googlePlayId: 'br.com.agrimind.pragassoja', // Android Package ID
      minDays: 3,
      minLaunches: 5,
      remindDays: 7,
      remindLaunches: 10,
    ),
  );
  sl.registerLazySingleton<IAppDataManager>(() => AppDataManagerDrift());
  sl.registerLazySingleton<IReceitaAgroNotificationService>(
    () => ReceitaAgroNotificationService(),
  );
  sl.registerLazySingleton<ReceitaAgroNotificationService>(
    () =>
        sl<IReceitaAgroNotificationService>() as ReceitaAgroNotificationService,
  );
  sl.registerLazySingleton<ReceitaAgroFirebaseMessagingService>(
    () => ReceitaAgroFirebaseMessagingService(),
  );
  sl.registerLazySingleton<PromotionalNotificationManager>(
    () => PromotionalNotificationManager(),
  );
  if (!sl.isRegistered<core.EnhancedStorageService>()) {
    try {
      sl.registerLazySingleton<core.EnhancedStorageService>(
        () => core.EnhancedStorageService(),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'EnhancedStorageService registration failed',
          name: 'InjectionContainer',
          error: e,
          level: 1000,
        );
      }
    }
  }
  if (!kIsWeb && !sl.isRegistered<core.ILocalStorageRepository>()) {
    try {
      sl.registerLazySingleton<core.ILocalStorageRepository>(
        () => sl<core.HiveStorageService>(),
      );
      if (kDebugMode) {
        developer.log(
          'ILocalStorageRepository registered successfully',
          name: 'InjectionContainer',
          level: 500,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'ILocalStorageRepository registration failed',
          name: 'InjectionContainer',
          error: e,
          level: 900,
        );
      }
    }
  } else if (kIsWeb) {
    // Web storage handled differently - no specific repository needed
  }
  // Register Drift repositories for services that still use GetIt
  if (!sl.isRegistered<FitossanitariosRepository>()) {
    sl.registerLazySingleton<FitossanitariosRepository>(
      () => FitossanitariosRepository(sl<ReceituagroDatabase>()),
    );
  }

  if (!sl.isRegistered<PragasRepository>()) {
    sl.registerLazySingleton<PragasRepository>(
      () => PragasRepository(sl<ReceituagroDatabase>()),
    );
  }

  if (!sl.isRegistered<CulturasRepository>()) {
    sl.registerLazySingleton<CulturasRepository>(
      () => CulturasRepository(sl<ReceituagroDatabase>()),
    );
  }

  sl.registerLazySingleton<AgriculturalNavigationExtension>(
    () => AgriculturalNavigationExtension(),
  );
  sl.registerLazySingleton<ReceitaAgroNavigationService>(
    () => ReceitaAgroNavigationService(
      coreService: sl<core.EnhancedNavigationService>(),
      agricExtension: sl<AgriculturalNavigationExtension>(),
    ),
  );
  sl.registerLazySingleton<FavoritosNavigationService>(
    () => FavoritosNavigationService(
      fitossanitarioRepository: sl<FitossanitariosRepository>(),
      pragasRepository: sl<PragasRepository>(),
      integrationService: sl<DiagnosticoIntegrationService>(),
    ),
  );

  // ✅ PHASE 3: Setup GetIt for Pragas por Cultura services
  _setupPragasPorCulturaServices();

  // ❌ REMOVED: PremiumLegacyRepository (Hive dependency removed)
  // ❌ REMOVED: ComentarioRepository (Hive dependency removed)
  
  try {
    sl.registerLazySingleton<IPremiumService>(() => MockPremiumService());
  } catch (e) {
    if (kDebugMode) {
      developer.log(
        'Premium service registration failed',
        name: 'InjectionContainer',
        error: e,
        level: 1000,
      );
    }
  }

  // ❌ REMOVED: ComentariosService (depends on ComentarioRepository)
  // TODO: Migrate to Drift-based comentarios repository
  
  // ✅ IDiagnosticosRepository and all use cases now managed by Injectable (@LazySingleton, @injectable)
  sl.registerLazySingleton<DefensivosGroupingService>(
    () => DefensivosGroupingService(),
  );
  // ❌ REMOVIDO: FavoritosDI.registerDependencies(); // Duplica FavoritosRepositorySimplified (@LazySingleton)
  // ✅ FavoritosService agora registrado via FavoritosDI.registerServices() ANTES do Injectable
  // configureDefensivosDependencies(); // Already called in configureAllRepositoriesDependencies()
  // ❌ REMOVIDO: initDefensivoDetailsDI(); // Feature consolidada em defensivos/
  // ❌ REMOVIDO: PragasDI.configure(); // IPragasRepository e use cases agora gerenciados via @LazySingleton/@injectable
  // ❌ REMOVIDO: ComentariosDI.register(sl); // IComentariosRepository e use cases agora via @LazySingleton/@injectable
  SettingsDI.register(sl); // ⚠️ Ainda registra manualmente (sem @LazySingleton)
  await TTSModule.register(sl); // ✅ TTS feature

  // ✅ Registrar DataMigrationService para migração Hive -> Drift
  sl.registerLazySingleton<DataMigrationService>(
    () => DataMigrationService(sl<core.PreferencesService>(), sl()),
  );
  try {
    sl.registerLazySingleton<ReceitaAgroPremiumService>(() {
      if (!sl.isRegistered<ReceitaAgroAnalyticsService>()) {
        throw StateError(
          'ReceitaAgroAnalyticsService must be registered before ReceitaAgroPremiumService',
        );
      }
      if (!sl.isRegistered<ReceitaAgroCloudFunctionsService>()) {
        throw StateError(
          'ReceitaAgroCloudFunctionsService must be registered before ReceitaAgroPremiumService',
        );
      }
      if (!sl.isRegistered<ReceitaAgroRemoteConfigService>()) {
        throw StateError(
          'ReceitaAgroRemoteConfigService must be registered before ReceitaAgroPremiumService',
        );
      }
      if (!sl.isRegistered<core.ISubscriptionRepository>()) {
        throw StateError(
          'ISubscriptionRepository must be registered before ReceitaAgroPremiumService',
        );
      }
      final service = ReceitaAgroPremiumService(
        analytics: sl<ReceitaAgroAnalyticsService>(),
        cloudFunctions: sl<ReceitaAgroCloudFunctionsService>(),
        remoteConfig: sl<ReceitaAgroRemoteConfigService>(),
        subscriptionRepository: sl<core.ISubscriptionRepository>(),
      );
      ReceitaAgroPremiumService.setInstance(service);

      return service;
    });
    if (kDebugMode) {
      developer.log(
        'ReceitaAgroPremiumService registered successfully with core ISubscriptionRepository',
        name: 'InjectionContainer',
        level: 500,
      );
    }
  } catch (e) {
    if (kDebugMode) {
      developer.log(
        'ReceitaAgroPremiumService registration failed',
        name: 'InjectionContainer',
        error: e,
        level: 1000,
      );
    }
    rethrow;
  }
}

/// ✅ PHASE 3: Setup GetIt for Pragas por Cultura refactoring
/// Registers the 4 specialized services and ViewModel for the Pragas por Cultura feature
void _setupPragasPorCulturaServices() {
  // Import the services from the feature
  // Services are registered as singletons to ensure consistent instance across the app

  // For now, this function is a placeholder
  // The actual registration will be done when the services are created
  // TODO: Add service imports and registration when Phase 3 page refactoring is complete

  if (kDebugMode) {
    developer.log(
      'Pragas por Cultura services setup skipped (awaiting Page refactoring)',
      name: 'InjectionContainer - PragasPorCultura',
      level: 500,
    );
  }
}

import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';

// ❌ REMOVIDO: import '../../features/DetalheDefensivos/di/defensivo_details_di.dart';
import '../../features/analytics/analytics_service.dart';
// ❌ REMOVIDO: import '../../features/comentarios/di/comentarios_di.dart'; (via @LazySingleton)
import '../../features/defensivos/data/services/defensivos_grouping_service.dart';
// ❌ REMOVIDO: import '../../features/defensivos/di/defensivos_di.dart'; // Unused after consolidation
// ✅ Diagnosticos imports removed - now managed by Injectable
import '../../features/defensivos/data/strategies/defensivo_grouping_strategy_registry.dart';
import '../../features/defensivos/data/strategies/defensivo_grouping_service_v2.dart';
import '../../features/favoritos/domain/favoritos_navigation_service.dart';
import '../../features/favoritos/favoritos_di.dart';
// ❌ REMOVIDO: import '../../features/pragas/di/pragas_di.dart'; (via @LazySingleton)
import '../../features/pragas_por_cultura/data/services/pragas_cultura_query_service.dart';
import '../../features/pragas_por_cultura/data/services/pragas_cultura_sort_service.dart';
import '../../features/pragas_por_cultura/data/services/pragas_cultura_statistics_service.dart';
import '../../features/pragas_por_cultura/data/services/pragas_cultura_data_service.dart';
import '../../features/pragas_por_cultura/domain/repositories/i_pragas_cultura_repository.dart';
import '../../features/settings/di/device_management_di.dart';
import '../../features/settings/di/settings_di.dart';
import '../../features/settings/di/tts_module.dart';
import '../../database/repositories/fitossanitarios_repository.dart';
import '../../database/repositories/pragas_repository.dart';
import '../../database/repositories/culturas_repository.dart';
import '../../database/receituagro_database.dart';
import '../interfaces/i_premium_service.dart';
import '../sync/receituagro_drift_storage_adapter.dart';
import '../navigation/agricultural_navigation_extension.dart';
import '../services/app_data_manager.dart';
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
// ⚠️ REMOVED: import '../services/data_migration_service.dart';
import '../sync/sync_operations.dart';
import '../sync/sync_queue.dart';
import 'core_package_integration.dart';
import 'injection.dart' as injectable;
import 'modules/account_deletion_module.dart';
import 'repositories_di.dart';

final sl = core.GetIt.instance;

/// Initializes the Dependency Injection container
///
/// ✅ DEPENDENCY INVERSION PRINCIPLE (DIP) IMPLEMENTATION:
///
/// DI SETUP FLOW:
/// 1. Core infrastructure (GetIt instance setup)
/// 2. @LazySingleton annotated classes (auto-registered via Injectable)
/// 3. Manual registrations for complex setup
/// 4. Module-specific DI (Features, Services, Sync)
///
/// KEY PRINCIPLES:
/// - ✅ Depend on abstractions (interfaces), not concrete classes
/// - ✅ Use @LazySingleton for lazy initialization (on-demand)
/// - ✅ Register interfaces/abstract classes in the container
/// - ✅ Concrete implementations are internal to module
///
/// LAYERED REGISTRATION:
/// 1. Infrastructure: Database, Network, Storage
/// 2. Repositories: Data layer abstractions (IRepository)
/// 3. Use Cases: Business logic abstractions
/// 4. Services: Specialized services (IAnalytics, ICrashlytics, etc.)
/// 5. Notifiers: State management (Riverpod + GetIt)
///
/// EXAMPLE - Notifier Dependency Inversion:
/// ```dart
/// // Notifier depends on use case ABSTRACTION
/// @riverpod
/// class MyNotifier extends _$MyNotifier {
///   late final GetDataUseCase _useCase;
///
///   @override
///   Future<Data> build() async {
///     // DI container provides implementation
///     _useCase = di.sl<GetDataUseCase>();
///     return _useCase.call();
///   }
/// }
///
/// // Use case depends on repository ABSTRACTION
/// class GetDataUseCase {
///   final IDataRepository _repo; // Depends on interface
///   GetDataUseCase(this._repo);
/// }
///
/// // Repository IMPLEMENTATION injected by container
/// @LazySingleton(as: IDataRepository)
/// class DataRepositoryImpl implements IDataRepository { }
/// ```
Future<void> init() async {
  await core.InjectionContainer.init();

  // ⚠️ IMPORTANTE: Registrar datasources e services SEM @injectable ANTES do Injectable
  // O Injectable precisa deles para criar repositories via @LazySingleton
  // DeviceLocalDataSource e DeviceRemoteDataSource - auto-registered by @LazySingleton via Injectable
  // await DeviceManagementDI.registerDataSources(sl);

  // ✅ FavoritosDataResolverStrategyRegistry agora usa lazy loading dos repos
  // Não precisa registrá-los cedo mais
  FavoritosDI.registerServices(); // ⚠️ FavoritosService com lazy loading (não precisa de FavoritoRepository no construtor)

  await injectable.configureDependencies();
  FavoritosDI.registerRepository(); // ✅ Registra FavoritosRepositorySimplified como classe concreta
  configureAllRepositoriesDependencies();

  // ✅ SIMPLIFIED: SyncQueue uses in-memory storage
  if (!sl.isRegistered<SyncQueue>()) {
    sl.registerLazySingleton<SyncQueue>(() => SyncQueue());
  }

  if (!sl.isRegistered<SyncOperations>()) {
    sl.registerLazySingleton<SyncOperations>(
      () => SyncOperations(sl<SyncQueue>(), sl<core.ConnectivityService>()),
    );
  }

  // DataIntegrityService removed - no longer needed

  // ℹ️ SyncDIModule initialized in main.dart
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
  // ⚠️ REMOVED: Services no longer exist in core
  // if (!sl.isRegistered<core.IBoxRegistryService>()) {
  //   sl.registerLazySingleton<core.IBoxRegistryService>(
  //     () => core.BoxRegistryService(),
  //   );
  // }
  // if (!sl.isRegistered<core.HiveStorageService>()) {
  //   sl.registerLazySingleton<core.HiveStorageService>(
  //     () => core.HiveStorageService(sl<core.IBoxRegistryService>()),
  //   );
  // }
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
  sl.registerLazySingleton<IAppDataManager>(() => AppDataManager());
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
  // ⚠️ REMOVED: EnhancedStorageService no longer exists
  // if (!sl.isRegistered<core.EnhancedStorageService>()) {
  //   try {
  //     sl.registerLazySingleton<core.EnhancedStorageService>(
  //       () => core.EnhancedStorageService(),
  //     );
  //   } catch (e) {
  //     if (kDebugMode) {
  //       developer.log(
  //         'EnhancedStorageService registration failed',
  //         name: 'InjectionContainer',
  //         error: e,
  //         level: 1000,
  //       );
  //     }
  //   }
  // }
  // Register ReceituagroDriftStorageAdapter as ILocalStorageRepository
  // Este adapter customizado traduz entre as tabelas Drift específicas do ReceitaAgro
  // (Favoritos, Comentarios, AppSettings) e o sistema de sync genérico do core
  if (!sl.isRegistered<core.ILocalStorageRepository>()) {
    try {
      sl.registerLazySingleton<core.ILocalStorageRepository>(
        () => ReceituagroDriftStorageAdapter(sl<ReceituagroDatabase>()),
      );
      if (kDebugMode) {
        developer.log(
          'ILocalStorageRepository (ReceituagroDriftStorageAdapter) registered successfully',
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

  // ❌ REMOVED: PremiumLegacyRepository
  // ❌ REMOVED: ComentarioRepository

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

  // ✅ Estratégia Pattern para agrupamento de defensivos (SOLID - Open/Closed Principle)
  if (!sl.isRegistered<DefensivoGroupingStrategyRegistry>()) {
    sl.registerLazySingleton<DefensivoGroupingStrategyRegistry>(
      () => DefensivoGroupingStrategyRegistry(),
    );
  }

  if (!sl.isRegistered<DefensivoGroupingServiceV2>()) {
    sl.registerLazySingleton<DefensivoGroupingServiceV2>(
      () => DefensivoGroupingServiceV2(sl<DefensivoGroupingStrategyRegistry>()),
    );
  }

  // ⚠️ BACKWARD COMPATIBILITY: Manter DefensivosGroupingService por enquanto
  // TODO: Migrar todas as dependências para DefensivoGroupingServiceV2 e remover
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

  // ⚠️ REMOVED: DataMigrationService no longer exists
  // sl.registerLazySingleton<DataMigrationService>(
  //   () => DataMigrationService(sl<core.PreferencesService>(), sl()),
  // );
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
  // Register Query Service for filtering pragas
  if (!sl.isRegistered<IPragasCulturaQueryService>()) {
    sl.registerLazySingleton<IPragasCulturaQueryService>(
      () => PragasCulturaQueryService(),
    );
  }

  // Register Sort Service for ordering pragas
  if (!sl.isRegistered<IPragasCulturaSortService>()) {
    sl.registerLazySingleton<IPragasCulturaSortService>(
      () => PragasCulturaSortService(),
    );
  }

  // Register Statistics Service for calculating stats
  if (!sl.isRegistered<IPragasCulturaStatisticsService>()) {
    sl.registerLazySingleton<IPragasCulturaStatisticsService>(
      () => PragasCulturaStatisticsService(),
    );
  }

  // Register Data Service for loading pragas data
  if (!sl.isRegistered<IPragasCulturaDataService>()) {
    sl.registerLazySingleton<IPragasCulturaDataService>(
      () =>
          PragasCulturaDataService(repository: sl<IPragasCulturaRepository>()),
    );
  }

  if (kDebugMode) {
    developer.log(
      'Pragas por Cultura services registered successfully (Query, Sort, Statistics, Data)',
      name: 'InjectionContainer - PragasPorCultura',
      level: 500,
    );
  }
}

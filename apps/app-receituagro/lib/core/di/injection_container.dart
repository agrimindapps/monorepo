// Dart imports
import 'dart:async';

// Package imports
import 'package:core/core.dart' as core;
// Flutter imports
import 'package:flutter/foundation.dart';

// Local imports
import '../../features/DetalheDefensivos/di/defensivo_details_di.dart';
import '../../features/analytics/analytics_service.dart';
import '../../features/comentarios/di/comentarios_di.dart';
import '../../features/comentarios/domain/comentarios_service.dart';
import '../../features/diagnosticos/data/repositories/diagnosticos_repository_impl.dart';
import '../../features/diagnosticos/domain/repositories/i_diagnosticos_repository.dart';
import '../../features/diagnosticos/domain/usecases/get_diagnosticos_usecase.dart';
import '../../features/diagnosticos/presentation/providers/diagnosticos_provider.dart';
import '../../features/favoritos/favoritos_di.dart';
import '../../features/favoritos/domain/favoritos_cache_service.dart';
import '../../features/favoritos/domain/favoritos_navigation_service.dart';
import '../../features/pragas/di/pragas_di.dart';
import '../../features/settings/di/device_management_di.dart';
import '../../features/settings/di/settings_di.dart';
import '../interfaces/i_premium_service.dart';
import '../navigation/agricultural_navigation_extension.dart';
import '../providers/feature_flags_provider.dart';
import '../providers/remote_config_provider.dart';
import '../data/repositories/comentarios_hive_repository.dart';
import '../data/repositories/cultura_hive_repository.dart';
import '../data/repositories/diagnostico_hive_repository.dart';
import '../data/repositories/favoritos_hive_repository.dart';
import '../data/repositories/fitossanitario_hive_repository.dart';
import '../data/repositories/fitossanitario_info_hive_repository.dart';
import '../data/repositories/plantas_inf_hive_repository.dart';
import '../data/repositories/pragas_hive_repository.dart';
import '../data/repositories/pragas_inf_hive_repository.dart';
import '../data/repositories/premium_hive_repository.dart';
import '../services/app_data_manager.dart';
import '../services/cloud_functions_service.dart';
import '../services/device_identity_service.dart';
import '../services/diagnostico_integration_service.dart';
// REMOVED: enhanced_diagnostic_integration_service - obsolete stub
import '../services/firebase_messaging_service.dart';
import '../services/mock_premium_service.dart';
import '../services/premium_service.dart';
import '../services/promotional_notification_manager.dart';
import '../services/receituagro_data_cleaner.dart';
import '../services/receituagro_navigation_service.dart';
import '../services/receituagro_notification_service.dart';
import '../services/remote_config_service.dart';
import 'core_package_integration.dart';
import 'injection.dart' as injectable;
import 'modules/account_deletion_module.dart';
import 'repositories_di.dart';

final sl = core.GetIt.instance;

Future<void> init() async {
  // ===== INJECTABLE AUTO-WIRING =====
  // Configure Injectable dependencies first (automatic DI)
  await injectable.configureDependencies();

  // ===== CLEAN ARCHITECTURE REPOSITORIES & USE CASES =====
  // Configure all Clean Architecture dependencies first
  configureAllRepositoriesDependencies();

  // ===== DATA CLEANER =====
  // Register ReceitaAgroDataCleaner before AccountDeletionModule (required dependency)
  sl.registerLazySingleton<core.IAppDataCleaner>(
    () => ReceitaAgroDataCleaner(),
  );

  // ===== ACCOUNT DELETION =====
  // Initialize account deletion module after repositories
  AccountDeletionModule.init(sl);
  
  // ===== DEVICE MANAGEMENT =====
  // Register FirebaseDeviceService first (Web-safe)
  if (!sl.isRegistered<core.FirebaseDeviceService>()) {
    sl.registerLazySingleton<core.FirebaseDeviceService>(
      () => core.FirebaseDeviceService(),
    );
  }

  // Configure device management dependencies
  await DeviceManagementDI.registerDependencies(sl);

  // ===== ENHANCED NAVIGATION =====
  // Register enhanced core navigation services
  if (!sl.isRegistered<core.NavigationConfigurationService>()) {
    sl.registerLazySingleton<core.NavigationConfigurationService>(
      () => core.NavigationConfigurationService(),
    );
  }

  if (!sl.isRegistered<core.NavigationAnalyticsService>()) {
    sl.registerLazySingleton<core.NavigationAnalyticsService>(
      () => core.NavigationAnalyticsService(
        sl<core.FirebaseAnalyticsService>(),
      ),
    );
  }

  if (!sl.isRegistered<core.EnhancedNavigationService>()) {
    sl.registerLazySingleton<core.EnhancedNavigationService>(
      () => core.EnhancedNavigationService(),
    );
  }
  
  // ===== DEVICE IDENTITY SERVICE =====
  // Register DeviceIdentityService before Core Package Integration
  sl.registerLazySingleton<DeviceIdentityService>(
    () => DeviceIdentityService.instance,
  );
  
  // ===== CORE PACKAGE INTEGRATION - AUTH SERVICES ONLY =====
  // Enable only auth-related services for Sprint 1
  await CorePackageIntegration.initializeAuthServices();
  
  // ===== SPRINT 1 SERVICES =====
  // New services for Remote Config, Analytics, Cloud Functions, Premium
  
  // Remote Config Service
  sl.registerLazySingleton<ReceitaAgroRemoteConfigService>(
    () => ReceitaAgroRemoteConfigService.instance,
  );
  
  // Analytics Service - Registered via Core Package Integration
  
  // Cloud Functions Service
  sl.registerLazySingleton<ReceitaAgroCloudFunctionsService>(
    () => ReceitaAgroCloudFunctionsService.instance,
  );
  
  // Premium Service (New Architecture) - Registered after analytics is available
  // Moved after auth services initialization to ensure dependencies are available
  
  // Unified Sync Manager (from core package)
  if (!sl.isRegistered<core.UnifiedSyncManager>()) {
    sl.registerLazySingleton<core.UnifiedSyncManager>(
      () => core.UnifiedSyncManager.instance,
    );
  }

  // NOTE: ReceitaAgroSyncConfig.configure() is now called in main.dart
  // to avoid race conditions and ensure proper initialization order
  
  // Providers for state management
  sl.registerLazySingleton<RemoteConfigProvider>(
    () => RemoteConfigProvider(),
  );
  
  sl.registerLazySingleton<FeatureFlagsProvider>(
    () => FeatureFlagsProvider(),
  );
  
  // Premium Service (New Architecture) - Delayed registration
  // Register after all dependencies are confirmed available
  
  // Box Registry Service and Core Storage Service
  if (!sl.isRegistered<core.IBoxRegistryService>()) {
    sl.registerLazySingleton<core.IBoxRegistryService>(() => core.BoxRegistryService());
  }
  if (!sl.isRegistered<core.HiveStorageService>()) {
    sl.registerLazySingleton<core.HiveStorageService>(
      () => core.HiveStorageService(sl<core.IBoxRegistryService>()),
    );
  }

  // Analytics Repository - Now registered via Core Package Integration
  // sl.registerLazySingleton<IAnalyticsRepository>(
  //   () => FirebaseAnalyticsService(),
  // );

  // Crashlytics Repository - Now registered via Core Package Integration
  // sl.registerLazySingleton<ICrashlyticsRepository>(
  //   () => FirebaseCrashlyticsService(),
  // );

  // Subscription Repository (RevenueCat) - Using Core Package
  if (!sl.isRegistered<core.ISubscriptionRepository>()) {
    sl.registerLazySingleton<core.ISubscriptionRepository>(
      () => core.RevenueCatService(),
    );
  }

  // App Rating Repository - Using Core Package
  sl.registerLazySingleton<core.IAppRatingRepository>(() => core.AppRatingService(
    appStoreId: '6738924932', // ReceitaAgro App Store ID real
    googlePlayId: 'br.com.agrimind.pragassoja', // Using the correct package ID
    minDays: 3,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 10,
  ));
  
  // App Data Manager - Gerenciador principal de dados
  sl.registerLazySingleton<IAppDataManager>(
    () => AppDataManager(),
  );
  
  // Notification Service - Serviço de notificações
  sl.registerLazySingleton<IReceitaAgroNotificationService>(
    () => ReceitaAgroNotificationService(),
  );
  
  // Registro adicional para compatibilidade com código que busca por classe concreta
  sl.registerLazySingleton<ReceitaAgroNotificationService>(
    () => sl<IReceitaAgroNotificationService>() as ReceitaAgroNotificationService,
  );

  // ===== PUSH NOTIFICATIONS SYSTEM =====
  // Firebase Messaging Service para push notifications promocionais
  sl.registerLazySingleton<ReceitaAgroFirebaseMessagingService>(
    () => ReceitaAgroFirebaseMessagingService(),
  );

  // Promotional Notification Manager para gerenciar notificações contextuais
  sl.registerLazySingleton<PromotionalNotificationManager>(
    () => PromotionalNotificationManager(),
  );
  
  // Storage Service - Removed (using Core Package EnhancedStorageService)
  
  // Enhanced Storage Service from Core Package
  if (!sl.isRegistered<core.EnhancedStorageService>()) {
    try {
      sl.registerLazySingleton<core.EnhancedStorageService>(
        () => core.EnhancedStorageService(),
      );
    } catch (e) {
      if (kDebugMode) print('EnhancedStorageService registration failed: $e');
    }
  }

  // Interface do core para compatibilidade
  // Skip on Web platform due to Hive limitations
  if (!kIsWeb && !sl.isRegistered<core.ILocalStorageRepository>()) {
    try {
      sl.registerLazySingleton<core.ILocalStorageRepository>(
        () => sl<core.HiveStorageService>(),
      );
      if (kDebugMode) print('✅ ILocalStorageRepository registered successfully');
    } catch (e) {
      if (kDebugMode) print('⚠️ ILocalStorageRepository registration failed: $e');
    }
  } else if (kIsWeb && kDebugMode) {
    print('⚠️ ILocalStorageRepository skipped on Web platform (Hive limitations)');
  }
  
  // Navigation Service - Enhanced version via Core Package
  // Basic navigation service is already registered above as EnhancedNavigationService
  
  // Device Identity Service - Moved to before Core Package Integration
  
  // Hive Repositories - Repositórios de dados reais
  // Core repositories removed - using direct enhanced implementation
  
  // ===== ENHANCED DIAGNOSTICOS SERVICES =====
  // New enhanced services for optimal performance

  // Core repositories using enhanced storage
  sl.registerLazySingleton<CulturaHiveRepository>(
    () => CulturaHiveRepository(),
  );

  sl.registerLazySingleton<PragasHiveRepository>(
    () => PragasHiveRepository(),
  );

  sl.registerLazySingleton<PragasInfHiveRepository>(
    () => PragasInfHiveRepository(),
  );

  sl.registerLazySingleton<PlantasInfHiveRepository>(
    () => PlantasInfHiveRepository(),
  );

  sl.registerLazySingleton<FitossanitarioHiveRepository>(
    () => FitossanitarioHiveRepository(),
  );

  sl.registerLazySingleton<DiagnosticoHiveRepository>(
    () => DiagnosticoHiveRepository(),
  );

  sl.registerLazySingleton<FitossanitarioInfoHiveRepository>(
    () => FitossanitarioInfoHiveRepository(),
  );

  // Enhanced diagnostico services (singletons)
  // These are automatically initialized and managed
  // No need to register as they use singleton pattern
  
  // Integration Services - Enhanced version
  sl.registerLazySingleton<DiagnosticoIntegrationService>(
    () => DiagnosticoIntegrationService(
      diagnosticoRepo: sl<DiagnosticoHiveRepository>(),
      fitossanitarioRepo: sl<FitossanitarioHiveRepository>(),
      culturaRepo: sl<CulturaHiveRepository>(),
      pragasRepo: sl<PragasHiveRepository>(),
      fitossanitarioInfoRepo: sl<FitossanitarioInfoHiveRepository>(),
    ),
  );

  // Enhanced services use singleton pattern automatically
  
  // Enhanced Cache Services - Simplified registration
  sl.registerLazySingleton<FavoritosHiveRepository>(
    () => FavoritosHiveRepository(),
  );

  sl.registerLazySingleton<FavoritosCacheService>(
    () => FavoritosCacheService(
      favoritosRepository: sl<FavoritosHiveRepository>(),
      fitossanitarioRepository: sl<FitossanitarioHiveRepository>(),
      pragasRepository: sl<PragasHiveRepository>(),
      culturaRepository: sl<CulturaHiveRepository>(),
      integrationService: sl<DiagnosticoIntegrationService>(),
    ),
  );
  
  // Agricultural Navigation Extension
  sl.registerLazySingleton<AgriculturalNavigationExtension>(
    () => AgriculturalNavigationExtension(),
  );

  // Unified ReceitaAgro Navigation Service
  sl.registerLazySingleton<ReceitaAgroNavigationService>(
    () => ReceitaAgroNavigationService(
      coreService: sl<core.EnhancedNavigationService>(),
      agricExtension: sl<AgriculturalNavigationExtension>(),
    ),
  );

  // Navigation Services - Enhanced version
  sl.registerLazySingleton<FavoritosNavigationService>(
    () => FavoritosNavigationService(
      fitossanitarioRepository: sl<FitossanitarioHiveRepository>(),
      pragasRepository: sl<PragasHiveRepository>(),
      integrationService: sl<DiagnosticoIntegrationService>(),
    ),
  );

  // Sistema de Comentários
  sl.registerLazySingleton<ComentariosHiveRepository>(
    () => ComentariosHiveRepository(),
  );


  // Sistema Premium com cache Hive
  sl.registerLazySingleton<PremiumHiveRepository>(
    () => PremiumHiveRepository(),
  );

  // Premium Service - Using Mock Implementation for Development
  // TODO: Create proper adapter between core.RevenueCatService and IPremiumService when needed
  try {
    sl.registerLazySingleton<IPremiumService>(
      () => MockPremiumService(),
    );
  } catch (e) {
    if (kDebugMode) print('Premium service registration failed: $e');
  }

  sl.registerLazySingleton<ComentariosService>(
    () => ComentariosService(
      repository: sl<ComentariosHiveRepository>(),
      premiumService: sl<IPremiumService>(),
    ),
  );


  // ===== CULTURAS SIMPLIFIED =====
  // Clean Architecture removed - using direct CulturaCoreRepository access
  // ListaCulturasPage now uses sl<CulturaCoreRepository>() directly

  // ===== DIAGNÓSTICOS CLEAN ARCHITECTURE =====
  
  // REMOVED: EnhancedDiagnosticIntegrationService - obsolete stub that did nothing

  // Enhanced Diagnosticos Repository - Direct implementation (usando DiagnosticoHiveRepository já registrado)
  sl.registerLazySingleton<IDiagnosticosRepository>(
    () => DiagnosticosRepositoryImpl(sl<DiagnosticoHiveRepository>()),
  );

  // Use Cases para Diagnósticos
  sl.registerLazySingleton<GetDiagnosticosUseCase>(
    () => GetDiagnosticosUseCase(sl<IDiagnosticosRepository>()),
  );

  sl.registerLazySingleton<GetDiagnosticoByIdUseCase>(
    () => GetDiagnosticoByIdUseCase(sl<IDiagnosticosRepository>()),
  );

  sl.registerLazySingleton<GetRecomendacoesUseCase>(
    () => GetRecomendacoesUseCase(sl<IDiagnosticosRepository>()),
  );

  sl.registerLazySingleton<GetDiagnosticosByDefensivoUseCase>(
    () => GetDiagnosticosByDefensivoUseCase(sl<IDiagnosticosRepository>()),
  );

  sl.registerLazySingleton<GetDiagnosticosByCulturaUseCase>(
    () => GetDiagnosticosByCulturaUseCase(sl<IDiagnosticosRepository>()),
  );

  sl.registerLazySingleton<GetDiagnosticosByPragaUseCase>(
    () => GetDiagnosticosByPragaUseCase(sl<IDiagnosticosRepository>()),
  );

  sl.registerLazySingleton<SearchDiagnosticosWithFiltersUseCase>(
    () => SearchDiagnosticosWithFiltersUseCase(sl<IDiagnosticosRepository>()),
  );

  sl.registerLazySingleton<GetDiagnosticoStatsUseCase>(
    () => GetDiagnosticoStatsUseCase(sl<IDiagnosticosRepository>()),
  );

  sl.registerLazySingleton<ValidateCompatibilidadeUseCase>(
    () => ValidateCompatibilidadeUseCase(sl<IDiagnosticosRepository>()),
  );

  sl.registerLazySingleton<SearchDiagnosticosByPatternUseCase>(
    () => SearchDiagnosticosByPatternUseCase(sl<IDiagnosticosRepository>()),
  );

  sl.registerLazySingleton<GetDiagnosticoFiltersDataUseCase>(
    () => GetDiagnosticoFiltersDataUseCase(sl<IDiagnosticosRepository>()),
  );

  // Provider para Diagnósticos
  sl.registerLazySingleton<DiagnosticosProvider>(
    () => DiagnosticosProvider(
      getDiagnosticosUseCase: sl<GetDiagnosticosUseCase>(),
      getDiagnosticoByIdUseCase: sl<GetDiagnosticoByIdUseCase>(),
      getRecomendacoesUseCase: sl<GetRecomendacoesUseCase>(),
      getDiagnosticosByDefensivoUseCase: sl<GetDiagnosticosByDefensivoUseCase>(),
      getDiagnosticosByCulturaUseCase: sl<GetDiagnosticosByCulturaUseCase>(),
      getDiagnosticosByPragaUseCase: sl<GetDiagnosticosByPragaUseCase>(),
      searchDiagnosticosWithFiltersUseCase: sl<SearchDiagnosticosWithFiltersUseCase>(),
      getDiagnosticoStatsUseCase: sl<GetDiagnosticoStatsUseCase>(),
      validateCompatibilidadeUseCase: sl<ValidateCompatibilidadeUseCase>(),
      searchDiagnosticosByPatternUseCase: sl<SearchDiagnosticosByPatternUseCase>(),
      getDiagnosticoFiltersDataUseCase: sl<GetDiagnosticoFiltersDataUseCase>(),
    ),
  );
  
  // ===== FAVORITOS SYSTEM =====
  // Sistema de Favoritos usando DI simplificado
  FavoritosDI.registerDependencies();
  
  // ===== MÓDULOS ESPECÍFICOS =====
  
  // Configurar DI do módulo DetalheDefensivos
  initDefensivoDetailsDI();
  
  // Configurar DI do módulo de Pragas
  PragasDI.configure();
  
  // Configurar DI do módulo de Comentários
  ComentariosDI.register(sl);
  
  // Configurar DI do módulo de Settings
  SettingsDI.register(sl);
  
  // ===== FINAL REGISTRATION - SERVICES WITH COMPLEX DEPENDENCIES =====
  // Premium Service (New Architecture) - Register at the end when all dependencies are available
  // Updated to use Constructor Injection instead of Singleton pattern
  // Now uses core ISubscriptionRepository instead of direct purchases_flutter
  try {
    sl.registerLazySingleton<ReceitaAgroPremiumService>(
      () {
        // Verify all required dependencies are available
        if (!sl.isRegistered<ReceitaAgroAnalyticsService>()) {
          throw StateError('ReceitaAgroAnalyticsService must be registered before ReceitaAgroPremiumService');
        }
        if (!sl.isRegistered<ReceitaAgroCloudFunctionsService>()) {
          throw StateError('ReceitaAgroCloudFunctionsService must be registered before ReceitaAgroPremiumService');
        }
        if (!sl.isRegistered<ReceitaAgroRemoteConfigService>()) {
          throw StateError('ReceitaAgroRemoteConfigService must be registered before ReceitaAgroPremiumService');
        }
        if (!sl.isRegistered<core.ISubscriptionRepository>()) {
          throw StateError('ISubscriptionRepository must be registered before ReceitaAgroPremiumService');
        }

        // Create instance with constructor injection (NEW ARCHITECTURE)
        final service = ReceitaAgroPremiumService(
          analytics: sl<ReceitaAgroAnalyticsService>(),
          cloudFunctions: sl<ReceitaAgroCloudFunctionsService>(),
          remoteConfig: sl<ReceitaAgroRemoteConfigService>(),
          subscriptionRepository: sl<core.ISubscriptionRepository>(),
        );

        // Set deprecated singleton instance for backward compatibility
        ReceitaAgroPremiumService.setInstance(service);

        return service;
      },
    );
    if (kDebugMode) print('✅ ReceitaAgroPremiumService registered successfully with core ISubscriptionRepository');
  } catch (e) {
    if (kDebugMode) print('❌ ReceitaAgroPremiumService registration failed: $e');
    rethrow;
  }
}
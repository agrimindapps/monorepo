import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

// DetalheDefensivos DI
import '../../features/DetalheDefensivos/di/defensivo_details_di.dart';
import '../../features/comentarios/di/comentarios_di.dart';
import '../../features/comentarios/services/comentarios_hive_repository.dart';
import '../../features/comentarios/services/comentarios_service.dart';
// Culturas dependencies removed - using direct CulturaCoreRepository access
import '../../features/diagnosticos/data/repositories/diagnosticos_repository_impl.dart';
// Diagnósticos Clean Architecture
import '../../features/diagnosticos/domain/repositories/i_diagnosticos_repository.dart';
import '../../features/diagnosticos/domain/usecases/get_diagnosticos_usecase.dart';
import '../../features/diagnosticos/presentation/providers/diagnosticos_provider.dart';
import '../../features/favoritos/data/repositories/favoritos_repository_impl.dart';
import '../../features/favoritos/data/services/favoritos_storage_service.dart' as fav_services;
import '../../features/favoritos/domain/usecases/add_favorito_defensivo_usecase.dart';
import '../../features/favoritos/domain/usecases/favoritos_usecases_stub.dart';
import '../../features/favoritos/domain/usecases/get_favorito_defensivos_usecase.dart';
import '../../features/favoritos/domain/usecases/remove_favorito_defensivo_usecase.dart';
import '../../features/favoritos/favoritos_di.dart';
import '../../features/favoritos/services/favoritos_cache_service.dart';
import '../../features/favoritos/services/favoritos_navigation_service.dart';
import '../../features/pragas/di/pragas_di.dart';
import '../../features/settings/di/settings_di.dart';
import '../interfaces/i_premium_service.dart';
import '../repositories/comentarios_hive_repository.dart';
// New Core-based repositories
import '../repositories/cultura_core_repository.dart';
import '../repositories/cultura_hive_repository.dart';
import '../repositories/diagnostico_core_repository.dart';
import '../repositories/diagnostico_hive_repository.dart';
import '../repositories/favoritos_core_repository.dart';
import '../repositories/favoritos_hive_repository.dart';
import '../repositories/fitossanitario_core_repository.dart';
import '../repositories/fitossanitario_hive_repository.dart';
import '../repositories/fitossanitario_info_hive_repository.dart';
import '../repositories/pragas_core_repository.dart';
import '../repositories/pragas_hive_repository.dart';
import '../repositories/premium_hive_repository.dart';
import '../services/app_data_manager.dart';
import '../services/device_identity_service.dart';
import '../services/diagnostico_integration_service.dart';
import '../services/navigation_service.dart';
import '../services/premium_service_real.dart';
import '../services/receituagro_notification_service.dart';
import '../services/receituagro_storage_service.dart';
// Core Package Integration
import 'core_package_integration.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ===== CORE PACKAGE INTEGRATION (FASE 2.6 FINAL) =====
  // Initialize all Core Package services first
  await CorePackageIntegration.initializeCoreServices();
  
  // Core Storage Service - HiveStorageService do packages/core
  sl.registerLazySingleton<HiveStorageService>(
    () => HiveStorageService(),
  );

  // Analytics Repository
  sl.registerLazySingleton<IAnalyticsRepository>(
    () => FirebaseAnalyticsService(),
  );

  // Crashlytics Repository
  sl.registerLazySingleton<ICrashlyticsRepository>(
    () => FirebaseCrashlyticsService(),
  );

  // Subscription Repository (RevenueCat)
  sl.registerLazySingleton<ISubscriptionRepository>(
    () => RevenueCatService(),
  );

  // App Rating Repository
  sl.registerLazySingleton<IAppRatingRepository>(() => AppRatingService(
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
  
  // Storage Service - Adapter que usa HiveStorageService do core
  sl.registerLazySingleton<ReceitaAgroStorageService>(
    () => ReceitaAgroStorageService(),
  );
  
  // Interface do core para compatibilidade
  sl.registerLazySingleton<ILocalStorageRepository>(
    () => sl<HiveStorageService>(),
  );
  
  // Navigation Service - Serviço de navegação global
  sl.registerLazySingleton<INavigationService>(
    () => NavigationService(),
  );
  
  // Device Identity Service - Gerenciador de UUID único por dispositivo
  sl.registerLazySingleton<DeviceIdentityService>(
    () => DeviceIdentityService.instance,
  );
  
  // Hive Repositories - Repositórios de dados reais
  // LEGACY: Comentados durante migração para Core Package
  /*
  sl.registerLazySingleton<CulturaHiveRepository>(
    () => CulturaHiveRepository(),
  );
  
  sl.registerLazySingleton<PragasHiveRepository>(
    () => PragasHiveRepository(),
  );
  
  sl.registerLazySingleton<FitossanitarioHiveRepository>(
    () => FitossanitarioHiveRepository(),
  );
  
  sl.registerLazySingleton<DiagnosticoHiveRepository>(
    () => DiagnosticoHiveRepository(),
  );
  
  sl.registerLazySingleton<FavoritosHiveRepository>(
    () => FavoritosHiveRepository(),
  );
  
  sl.registerLazySingleton<FitossanitarioInfoHiveRepository>(
    () => FitossanitarioInfoHiveRepository(),
  );
  */

  // NEW: Core-based repositories using HiveStorageService
  sl.registerLazySingleton<PragasCoreRepository>(
    () => PragasCoreRepository(sl<ILocalStorageRepository>()),
  );
  
  sl.registerLazySingleton<FitossanitarioCoreRepository>(
    () => FitossanitarioCoreRepository(sl<ILocalStorageRepository>()),
  );
  
  sl.registerLazySingleton<FavoritosCoreRepository>(
    () => FavoritosCoreRepository(sl<ILocalStorageRepository>()),
  );
  
  sl.registerLazySingleton<CulturaCoreRepository>(
    () => CulturaCoreRepository(sl<ILocalStorageRepository>()),
  );
  
  sl.registerLazySingleton<DiagnosticoCoreRepository>(
    () => DiagnosticoCoreRepository(sl<ILocalStorageRepository>()),
  );
  
  // Temporary repositories that still need migration
  // TEMPORARY: Re-registering legacy repositories for backward compatibility
  // These should be removed once all pages are migrated to use Core repositories
  sl.registerLazySingleton<CulturaHiveRepository>(
    () => CulturaHiveRepository(),
  );
  
  sl.registerLazySingleton<PragasHiveRepository>(
    () => PragasHiveRepository(),
  );
  
  sl.registerLazySingleton<FitossanitarioHiveRepository>(
    () => FitossanitarioHiveRepository(),
  );
  
  sl.registerLazySingleton<FavoritosHiveRepository>(
    () => FavoritosHiveRepository(),
  );
  
  sl.registerLazySingleton<DiagnosticoHiveRepository>(
    () => DiagnosticoHiveRepository(),
  );
  
  sl.registerLazySingleton<FitossanitarioInfoHiveRepository>(
    () => FitossanitarioInfoHiveRepository(),
  );
  
  // Integration Services - Serviços que integram múltiplas boxes
  // TEMPORARY: Re-registering with legacy repositories for backward compatibility
  sl.registerLazySingleton<DiagnosticoIntegrationService>(
    () => DiagnosticoIntegrationService(
      diagnosticoRepo: sl<DiagnosticoHiveRepository>(),
      fitossanitarioRepo: sl<FitossanitarioHiveRepository>(),
      culturaRepo: sl<CulturaHiveRepository>(),
      pragasRepo: sl<PragasHiveRepository>(),
      fitossanitarioInfoRepo: sl<FitossanitarioInfoHiveRepository>(),
    ),
  );
  
  // Cache Services - Serviços de cache para otimização
  // TEMPORARY: Re-registering with legacy repositories for backward compatibility  
  sl.registerLazySingleton<FavoritosCacheService>(
    () => FavoritosCacheService(
      favoritosRepository: sl<FavoritosHiveRepository>(),
      fitossanitarioRepository: sl<FitossanitarioHiveRepository>(),
      pragasRepository: sl<PragasHiveRepository>(),
      culturaRepository: sl<CulturaHiveRepository>(),
      integrationService: sl<DiagnosticoIntegrationService>(),
    ),
  );
  
  // Navigation Services - Serviços de navegação inteligente
  // TEMPORARY: Re-registering with legacy repositories for backward compatibility
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

  sl.registerLazySingleton<ComentariosRealRepository>(
    () => ComentariosRealRepository(sl<ComentariosHiveRepository>()),
  );

  // Sistema Premium com cache Hive
  sl.registerLazySingleton<PremiumHiveRepository>(
    () => PremiumHiveRepository(),
  );

  sl.registerLazySingleton<IPremiumService>(
    () => PremiumServiceReal(
      hiveRepository: sl<PremiumHiveRepository>(),
      subscriptionRepository: sl<ISubscriptionRepository>(),
      navigationService: sl<INavigationService>(),
    ),
  );

  sl.registerLazySingleton<ComentariosService>(
    () => ComentariosService(
      repository: sl<ComentariosRealRepository>(),
      premiumService: sl<IPremiumService>(),
    ),
  );

  // ===== IMPLEMENTAÇÕES ESPECÍFICAS =====
  
  // Implementações para Favoritos
  sl.registerLazySingleton<fav_services.FavoritosValidatorService>(
    () => fav_services.FavoritosValidatorService(),
  );

  sl.registerLazySingleton<fav_services.FavoritosStorageService>(
    () => fav_services.FavoritosStorageService(),
  );

  sl.registerLazySingleton<fav_services.FavoritosCacheService>(
    () => fav_services.FavoritosCacheService(),
  );

  sl.registerLazySingleton<fav_services.FavoritosDataResolverService>(
    () => fav_services.FavoritosDataResolverService(),
  );

  sl.registerLazySingleton<fav_services.FavoritosEntityFactoryService>(
    () => fav_services.FavoritosEntityFactoryService(),
  );

  sl.registerLazySingleton<FavoritosDefensivosRepositoryImpl>(
    () => FavoritosDefensivosRepositoryImpl(
      storage: sl<fav_services.FavoritosStorageService>(),
      dataResolver: sl<fav_services.FavoritosDataResolverService>(),
      entityFactory: sl<fav_services.FavoritosEntityFactoryService>(),
      cache: sl<fav_services.FavoritosCacheService>(),
    ),
  );

  // ===== USE CASES =====
  
  // Use Cases para Favoritos de Defensivos
  sl.registerLazySingleton<GetFavoritoDefensivosUseCase>(
    () => GetFavoritoDefensivosUseCase(
      sl<FavoritosDefensivosRepositoryImpl>(),
    ),
  );

  sl.registerLazySingleton<AddFavoritoDefensivoUseCase>(
    () => AddFavoritoDefensivoUseCase(
      sl<FavoritosDefensivosRepositoryImpl>(),
      sl<fav_services.FavoritosValidatorService>(),
    ),
  );

  sl.registerLazySingleton<RemoveFavoritoDefensivoUseCase>(
    () => RemoveFavoritoDefensivoUseCase(
      sl<FavoritosDefensivosRepositoryImpl>(),
      sl<fav_services.FavoritosValidatorService>(),
    ),
  );

  // Agregador de Use Cases para Favoritos (stub temporário)
  sl.registerLazySingleton<FavoritosUsecases>(
    () => const FavoritosUsecases(),
  );

  // ===== CULTURAS SIMPLIFIED =====
  // Clean Architecture removed - using direct CulturaCoreRepository access
  // ListaCulturasPage now uses sl<CulturaCoreRepository>() directly

  // ===== DIAGNÓSTICOS CLEAN ARCHITECTURE =====
  
  // Repository Implementation para Diagnósticos
  sl.registerLazySingleton<IDiagnosticosRepository>(
    () => DiagnosticosRepositoryImpl(sl<DiagnosticoCoreRepository>()),
  );
  
  // Registro adicional para compatibilidade com código que busca por classe concreta
  sl.registerLazySingleton<DiagnosticosRepositoryImpl>(
    () => sl<IDiagnosticosRepository>() as DiagnosticosRepositoryImpl,
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
  
  // ===== MÓDULOS ESPECÍFICOS =====
  
  // Configurar DI do módulo DetalheDefensivos
  initDefensivoDetailsDI();
  
  // Configurar DI do módulo de Favoritos  
  FavoritosDI.registerDependencies();
  
  // Configurar DI do módulo de Pragas
  PragasDI.configure();
  
  // Configurar DI do módulo de Comentários
  ComentariosDI.register(sl);
  
  // Configurar DI do módulo de Settings
  SettingsDI.register(sl);
}
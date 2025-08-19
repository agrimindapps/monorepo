import 'package:get_it/get_it.dart';
import 'package:core/core.dart';
import '../services/app_data_manager.dart';
import '../services/receituagro_notification_service.dart';
import '../services/receituagro_storage_service.dart';
import '../repositories/cultura_hive_repository.dart';
import '../repositories/pragas_hive_repository.dart';
import '../repositories/fitossanitario_hive_repository.dart';
import '../repositories/diagnostico_hive_repository.dart';
import '../repositories/favoritos_hive_repository.dart';
import '../repositories/fitossanitario_info_hive_repository.dart';
import '../services/diagnostico_integration_service.dart';
import '../../features/favoritos/services/favoritos_cache_service.dart';
import '../../features/favoritos/services/favoritos_navigation_service.dart';
import '../repositories/comentarios_hive_repository.dart';
import '../repositories/premium_hive_repository.dart';
import '../services/premium_service_real.dart';
import '../interfaces/i_premium_service.dart';
import '../../features/comentarios/services/comentarios_hive_repository.dart';
import '../../features/comentarios/services/comentarios_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
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
    appStoreId: '123456789', // TODO: Replace with actual App Store ID for ReceitaAgro
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
  
  // Storage Service - Serviço de armazenamento
  sl.registerLazySingleton<ReceitaAgroStorageService>(
    () => ReceitaAgroStorageService(),
  );
  
  // Hive Repositories - Repositórios de dados reais
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
  
  // Integration Services - Serviços que integram múltiplas boxes
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
    ),
  );

  sl.registerLazySingleton<ComentariosService>(
    () => ComentariosService(
      repository: sl<ComentariosRealRepository>(),
      premiumService: sl<IPremiumService>(),
    ),
  );
}
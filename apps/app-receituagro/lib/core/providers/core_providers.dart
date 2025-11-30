import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart' as core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/receituagro_database.dart';
import '../../database/repositories/repositories.dart';
import '../../database/sync/adapters/comentarios_drift_sync_adapter.dart';
import '../../database/sync/adapters/favoritos_drift_sync_adapter.dart';
import '../../features/analytics/analytics_providers.dart';
import '../../features/analytics/analytics_service.dart';
import '../../features/favoritos/presentation/providers/favoritos_providers.dart';
import '../../features/sync/services/sync_coordinator.dart';
import '../navigation/agricultural_navigation_extension.dart';
import '../services/app_data_manager.dart';
import '../services/cloud_functions_service.dart';
import '../services/device_identity_service.dart';
import '../services/diagnostico_integration_service.dart';
import '../services/firebase_messaging_service.dart';
import '../services/premium_service.dart';
import '../services/promotional_notification_manager.dart';
import '../services/receita_agro_sync_service.dart';
import '../services/receituagro_data_cleaner.dart';
import '../services/receituagro_navigation_service.dart';
import '../services/receituagro_notification_service.dart';
import '../services/remote_config_service.dart';
import '../sync/receituagro_drift_storage_adapter.dart';
import '../sync/sync_operations.dart';
import '../sync/sync_queue.dart';

// ============================================================================
// MANUAL PROVIDERS - Riverpod 3.0 Compatible
// Seguindo padrão do app-plantis para evitar problemas com code generation
// ============================================================================

// ========== DATABASE ==========

/// Provider do banco de dados Drift (Singleton)
final receituagroDatabaseProvider = Provider<ReceituagroDatabase>((ref) {
  final db = ReceituagroDatabase.production();
  ref.onDispose(() => db.close());
  return db;
});

// ========== FIREBASE PROVIDERS ==========

/// Firebase Firestore Provider
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Auth Provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// ========== CORE SERVICES (from core package) ==========

/// Provider do serviço de conectividade do core
final connectivityServiceProvider = Provider<core.ConnectivityService>((ref) {
  return core.ConnectivityService.instance;
});

/// Provider do serviço enhanced de conectividade
final enhancedConnectivityServiceProvider = Provider<core.EnhancedConnectivityService>((ref) {
  return core.EnhancedConnectivityService();
});

/// Provider do unified sync manager do core
final unifiedSyncManagerProvider = Provider<core.UnifiedSyncManager>((ref) {
  return core.UnifiedSyncManager.instance;
});

/// Provider do serviço de navegação do core
final coreNavigationServiceProvider = Provider<core.EnhancedNavigationService>((ref) {
  return core.EnhancedNavigationService();
});

/// Provider do data cleaner
final dataCleanerServiceProvider = Provider<core.IAppDataCleaner>((ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return ReceitaAgroDataCleaner(db);
});

/// Provider do repositório de autenticação
final authRepositoryProvider = Provider<core.IAuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return core.FirebaseAuthService(firebaseAuth: firebaseAuth);
});

/// Provider do serviço de autenticação Firebase
final firebaseAuthServiceProvider = Provider<core.FirebaseAuthService>((ref) {
  return core.FirebaseAuthService();
});

/// Provider do repositório de armazenamento local
final localStorageRepositoryProvider = Provider<core.ILocalStorageRepository>((ref) {
  return ReceituagroDriftStorageAdapter(ref.watch(receituagroDatabaseProvider));
});

/// Provider do serviço de account deletion
final accountDeletionServiceProvider = Provider<core.AccountDeletionService>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final dataCleaner = ref.watch(dataCleanerServiceProvider);
  return core.AccountDeletionService(
    authRepository: authRepo,
    appDataCleaner: dataCleaner,
  );
});

/// Provider do serviço enhanced de account deletion
final enhancedAccountDeletionServiceProvider = Provider<core.EnhancedAccountDeletionService>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final dataCleaner = ref.watch(dataCleanerServiceProvider);
  return core.EnhancedAccountDeletionService(
    authRepository: authRepo,
    appDataCleaner: dataCleaner,
  );
});

/// Provider do repositório de subscription
final subscriptionRepositoryProvider = Provider<core.ISubscriptionRepository>((ref) {
  return core.RevenueCatService();
});

/// Provider do serviço de rating
final appRatingRepositoryProvider = Provider<core.IAppRatingRepository>((ref) {
  return core.AppRatingService(
    appStoreId: '967785485',
    googlePlayId: 'br.com.agrimind.pragassoja',
    minDays: 3,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 10,
  );
});

/// Provider do serviço de device do Firebase
final firebaseDeviceServiceProvider = Provider<core.FirebaseDeviceService>((ref) {
  return core.FirebaseDeviceService();
});

/// Provider do serviço de analytics do Firebase
final firebaseAnalyticsServiceProvider = Provider<core.FirebaseAnalyticsService>((ref) {
  return core.FirebaseAnalyticsService();
});

/// Provider do serviço de analytics de navegação
final navigationAnalyticsServiceProvider = Provider<core.NavigationAnalyticsService>((ref) {
  final firebaseAnalytics = ref.watch(firebaseAnalyticsServiceProvider);
  return core.NavigationAnalyticsService(firebaseAnalytics);
});

/// Provider do serviço de configuração de navegação
final navigationConfigurationServiceProvider = Provider<core.NavigationConfigurationService>((ref) {
  return core.NavigationConfigurationService();
});

// ========== REPOSITORY PROVIDERS ==========

/// Provider do repositório de diagnósticos
final diagnosticoRepositoryProvider = Provider<DiagnosticoRepository>((ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return DiagnosticoRepository(db);
});

/// Provider do repositório de fitossanitários
final fitossanitariosRepositoryProvider = Provider<FitossanitariosRepository>((ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return FitossanitariosRepository(db);
});

/// Provider do repositório de culturas
final culturasRepositoryProvider = Provider<CulturasRepository>((ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return CulturasRepository(db);
});

/// Provider do repositório de pragas
final pragasRepositoryProvider = Provider<PragasRepository>((ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return PragasRepository(db);
});

/// Provider do repositório de preferências do usuário
final userPreferencesRepositoryProvider = Provider<UserPreferencesRepository>((ref) {
  final appSettingsRepo = ref.watch(appSettingsRepositoryProvider);
  return UserPreferencesRepository(appSettingsRepo);
});

/// Provider do repositório de configurações do app
final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return AppSettingsRepository(db);
});

/// Provider do adapter de sincronização de favoritos
final favoritosSyncAdapterProvider = Provider<FavoritosDriftSyncAdapter>((ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return FavoritosDriftSyncAdapter(db, firestore, connectivity);
});

/// Provider do adapter de sincronização de comentários
final comentariosSyncAdapterProvider = Provider<ComentariosDriftSyncAdapter>((ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return ComentariosDriftSyncAdapter(db, firestore, connectivity);
});

// ========== CORE SERVICES (app-specific) ==========

/// Provider do serviço de analytics
final analyticsServiceProvider = Provider<ReceitaAgroAnalyticsService>((ref) {
  final analyticsRepo = ref.watch(analyticsRepositoryProvider);
  final crashlyticsRepo = ref.watch(crashlyticsRepositoryProvider);
  return ReceitaAgroAnalyticsService(
    analyticsRepository: analyticsRepo,
    crashlyticsRepository: crashlyticsRepo,
  );
});

/// Provider do serviço de device identity
final deviceIdentityServiceProvider = Provider<DeviceIdentityService>((ref) {
  return DeviceIdentityService.instance;
});

/// Provider do serviço de remote config
final remoteConfigServiceProvider = Provider<ReceitaAgroRemoteConfigService>((ref) {
  return ReceitaAgroRemoteConfigService.instance;
});

/// Provider do serviço de cloud functions
final cloudFunctionsServiceProvider = Provider<ReceitaAgroCloudFunctionsService>((ref) {
  return ReceitaAgroCloudFunctionsService.instance;
});

/// Provider do serviço de notificações
final notificationServiceProvider = Provider<ReceitaAgroNotificationService>((ref) {
  return ReceitaAgroNotificationService();
});

/// Provider do serviço de Firebase Messaging
final firebaseMessagingServiceProvider = Provider<ReceitaAgroFirebaseMessagingService>((ref) {
  return ReceitaAgroFirebaseMessagingService();
});

/// Provider do serviço de navegação
final navigationServiceProvider = Provider<ReceitaAgroNavigationService>((ref) {
  final coreService = ref.watch(coreNavigationServiceProvider);
  final agricExtension = ref.watch(agriculturalNavigationExtensionProvider);
  return ReceitaAgroNavigationService(
    coreService: coreService,
    agricExtension: agricExtension,
  );
});

/// Provider da extensão de navegação agrícola
final agriculturalNavigationExtensionProvider = Provider<AgriculturalNavigationExtension>((ref) {
  return AgriculturalNavigationExtension();
});

/// Provider do serviço de integração de diagnósticos
final diagnosticoIntegrationServiceProvider = Provider<DiagnosticoIntegrationService>((ref) {
  return DiagnosticoIntegrationService(
    diagnosticoRepo: ref.watch(diagnosticoRepositoryProvider),
    fitossanitarioRepo: ref.watch(fitossanitariosRepositoryProvider),
    culturaRepo: ref.watch(culturasRepositoryProvider),
    pragasRepo: ref.watch(pragasRepositoryProvider),
  );
});

/// Provider do app data manager
final appDataManagerProvider = Provider<AppDataManager>((ref) {
  return AppDataManager(ref);
});

// ========== SYNC SERVICES ==========

/// Provider da fila de sincronização
final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue();
});

/// Provider das operações de sincronização
final syncOperationsProvider = Provider<SyncOperations>((ref) {
  final queue = ref.watch(syncQueueProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return SyncOperations(queue, connectivity);
});

/// Provider do coordenador de sincronização
final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  final favoritosAdapter = ref.watch(favoritosSyncAdapterProvider);
  final comentariosAdapter = ref.watch(comentariosSyncAdapterProvider);
  return SyncCoordinator(
    connectivityService,
    favoritosAdapter,
    comentariosAdapter,
  );
});

/// Provider do gerenciador de notificações promocionais
final promotionalNotificationManagerProvider = Provider<PromotionalNotificationManager>((ref) {
  return PromotionalNotificationManager();
});

/// Provider do serviço de sincronização do ReceitaAgro
final receitaAgroSyncServiceProvider = Provider<ReceitaAgroSyncService>((ref) {
  return ReceitaAgroSyncService(
    favoritosRepository: ref.watch(favoritosRepositorySimplifiedProvider),
  );
});

// ========== PREMIUM SERVICES ==========

/// Provider do serviço de premium
final premiumServiceProvider = Provider<ReceitaAgroPremiumService>((ref) {
  final analytics = ref.watch(analyticsServiceProvider);
  final cloudFunctions = ref.watch(cloudFunctionsServiceProvider);
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);

  final service = ReceitaAgroPremiumService(
    analytics: analytics,
    cloudFunctions: cloudFunctions,
    remoteConfig: remoteConfig,
    subscriptionRepository: subscriptionRepo,
  );

  ReceitaAgroPremiumService.setInstance(service);
  return service;
});

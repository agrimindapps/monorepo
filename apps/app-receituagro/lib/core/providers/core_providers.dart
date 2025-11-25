import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart' as core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/receituagro_database.dart';
import '../../database/repositories/repositories.dart';
import '../../database/sync/adapters/favoritos_drift_sync_adapter.dart';
import '../../database/sync/adapters/comentarios_drift_sync_adapter.dart';
import '../../features/analytics/analytics_service.dart';
import '../../features/analytics/analytics_providers.dart';
import '../navigation/agricultural_navigation_extension.dart';
import '../services/app_data_manager.dart';
import '../services/cloud_functions_service.dart';
import '../services/device_identity_service.dart';
import '../services/diagnostico_integration_service.dart';
import '../services/firebase_messaging_service.dart';
import '../services/premium_service.dart';
import '../services/receituagro_data_cleaner.dart';
import '../services/receituagro_navigation_service.dart';
import '../services/receituagro_notification_service.dart';
import '../services/remote_config_service.dart';
import '../services/receita_agro_sync_service.dart';
import '../services/promotional_notification_manager.dart';
import '../sync/receituagro_drift_storage_adapter.dart';
import '../sync/sync_operations.dart';
import '../../features/favoritos/presentation/providers/favoritos_providers.dart';
import '../../features/sync/services/sync_coordinator.dart';

part 'core_providers.g.dart';

// ========== DATABASE ==========

/// Provider do banco de dados Drift (Singleton)
@Riverpod(keepAlive: true)
ReceituagroDatabase receituagroDatabase(Ref ref) {
  final db = ReceituagroDatabase.production();
  ref.onDispose(() => db.close());
  return db;
}

// ========== REPOSITORY PROVIDERS (needed to avoid circular dependency) ==========

/// Provider do repositório de diagnósticos
@Riverpod(keepAlive: true)
DiagnosticoRepository diagnosticoRepository(Ref ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return DiagnosticoRepository(db);
}

/// Provider do repositório de fitossanitários
@Riverpod(keepAlive: true)
FitossanitariosRepository fitossanitariosRepository(Ref ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return FitossanitariosRepository(db);
}

/// Provider do repositório de culturas
@Riverpod(keepAlive: true)
CulturasRepository culturasRepository(Ref ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return CulturasRepository(db);
}

/// Provider do repositório de pragas
@Riverpod(keepAlive: true)
PragasRepository pragasRepository(Ref ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return PragasRepository(db);
}

/// Provider do repositório de preferências do usuário
@Riverpod(keepAlive: true)
UserPreferencesRepository userPreferencesRepository(Ref ref) {
  final appSettingsRepo = ref.watch(appSettingsRepositoryProvider);
  return UserPreferencesRepository(appSettingsRepo);
}

/// Provider do repositório de configurações do app
@Riverpod(keepAlive: true)
AppSettingsRepository appSettingsRepository(Ref ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return AppSettingsRepository(db);
}

/// Provider do adapter de sincronização de favoritos
@Riverpod(keepAlive: true)
FavoritosDriftSyncAdapter favoritosSyncAdapter(Ref ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return FavoritosDriftSyncAdapter(db, firestore, connectivity);
}

/// Provider do adapter de sincronização de comentários
@Riverpod(keepAlive: true)
ComentariosDriftSyncAdapter comentariosSyncAdapter(Ref ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return ComentariosDriftSyncAdapter(db, firestore, connectivity);
}

// ========== CORE SERVICES ==========

/// Provider do serviço de analytics
@Riverpod(keepAlive: true)
ReceitaAgroAnalyticsService analyticsService(Ref ref) {
  final analyticsRepo = ref.watch(analyticsRepositoryProvider);
  final crashlyticsRepo = ref.watch(crashlyticsRepositoryProvider);
  return ReceitaAgroAnalyticsService(
    analyticsRepository: analyticsRepo,
    crashlyticsRepository: crashlyticsRepo,
  );
}

/// Provider do serviço de device identity
@Riverpod(keepAlive: true)
DeviceIdentityService deviceIdentityService(Ref ref) {
  return DeviceIdentityService.instance;
}

/// Provider do serviço de remote config
@Riverpod(keepAlive: true)
ReceitaAgroRemoteConfigService remoteConfigService(Ref ref) {
  return ReceitaAgroRemoteConfigService.instance;
}

/// Provider do serviço de cloud functions
@Riverpod(keepAlive: true)
ReceitaAgroCloudFunctionsService cloudFunctionsService(Ref ref) {
  return ReceitaAgroCloudFunctionsService.instance;
}

/// Provider do serviço de notificações
@Riverpod(keepAlive: true)
ReceitaAgroNotificationService notificationService(Ref ref) {
  return ReceitaAgroNotificationService();
}

/// Provider do serviço de Firebase Messaging
@Riverpod(keepAlive: true)
ReceitaAgroFirebaseMessagingService firebaseMessagingService(Ref ref) {
  return ReceitaAgroFirebaseMessagingService();
}

/// Provider do serviço de navegação
@Riverpod(keepAlive: true)
ReceitaAgroNavigationService navigationService(Ref ref) {
  final coreService = ref.watch(coreNavigationServiceProvider);
  final agricExtension = ref.watch(agriculturalNavigationExtensionProvider);
  return ReceitaAgroNavigationService(
    coreService: coreService,
    agricExtension: agricExtension,
  );
}

/// Provider da extensão de navegação agrícola
@Riverpod(keepAlive: true)
AgriculturalNavigationExtension agriculturalNavigationExtension(Ref ref) {
  return AgriculturalNavigationExtension();
}

/// Provider do serviço de navegação do core
@Riverpod(keepAlive: true)
core.EnhancedNavigationService coreNavigationService(Ref ref) {
  return core.EnhancedNavigationService();
}

/// Provider do serviço de integração de diagnósticos
@Riverpod(keepAlive: true)
DiagnosticoIntegrationService diagnosticoIntegrationService(Ref ref) {
  return DiagnosticoIntegrationService(
    diagnosticoRepo: ref.watch(diagnosticoRepositoryProvider),
    fitossanitarioRepo: ref.watch(fitossanitariosRepositoryProvider),
    culturaRepo: ref.watch(culturasRepositoryProvider),
    pragasRepo: ref.watch(pragasRepositoryProvider),
  );
}

/// Provider do data cleaner
@Riverpod(keepAlive: true)
core.IAppDataCleaner dataCleanerService(Ref ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return ReceitaAgroDataCleaner(db);
}

/// Provider do app data manager
@Riverpod(keepAlive: true)
IAppDataManager appDataManager(Ref ref) {
  return AppDataManager(ref);
}

// ========== SYNC SERVICES ==========

/// Provider da fila de sincronização
@Riverpod(keepAlive: true)
SyncQueue syncQueue(Ref ref) {
  return SyncQueue();
}

/// Provider das operações de sincronização
@Riverpod(keepAlive: true)
SyncOperations syncOperations(Ref ref) {
  final queue = ref.watch(syncQueueProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return SyncOperations(queue, connectivity);
}

/// Provider do serviço de conectividade do core
@Riverpod(keepAlive: true)
core.ConnectivityService connectivityService(Ref ref) {
  return core.ConnectivityService.instance;
}

/// Provider do serviço enhanced de conectividade
@Riverpod(keepAlive: true)
core.EnhancedConnectivityService enhancedConnectivityService(Ref ref) {
  return core.EnhancedConnectivityService();
}

/// Provider do unified sync manager do core
@Riverpod(keepAlive: true)
core.UnifiedSyncManager unifiedSyncManager(Ref ref) {
  return core.UnifiedSyncManager.instance;
}

/// Provider do coordenador de sincronização
@Riverpod(keepAlive: true)
SyncCoordinator syncCoordinator(Ref ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  final favoritosAdapter = ref.watch(favoritosSyncAdapterProvider);
  final comentariosAdapter = ref.watch(comentariosSyncAdapterProvider);

  return SyncCoordinator(
    connectivityService,
    favoritosAdapter,
    comentariosAdapter,
  );
}

/// Provider do gerenciador de notificações promocionais
@Riverpod(keepAlive: true)
PromotionalNotificationManager promotionalNotificationManager(Ref ref) {
  return PromotionalNotificationManager();
}

/// Provider do serviço de sincronização do ReceitaAgro
@Riverpod(keepAlive: true)
ReceitaAgroSyncService receitaAgroSyncService(Ref ref) {
  return ReceitaAgroSyncService(
    favoritosRepository: ref.watch(favoritosRepositorySimplifiedProvider),
  );
}

// ========== FIREBASE SERVICES (from core) ==========

/// Provider do serviço de device do Firebase
@Riverpod(keepAlive: true)
core.FirebaseDeviceService firebaseDeviceService(Ref ref) {
  return core.FirebaseDeviceService();
}

/// Provider do serviço de analytics do Firebase
@Riverpod(keepAlive: true)
core.FirebaseAnalyticsService firebaseAnalyticsService(Ref ref) {
  return core.FirebaseAnalyticsService();
}

// ========== AUTH SERVICES (from core) ==========

/// Provider do repositório de autenticação
@Riverpod(keepAlive: true)
core.IAuthRepository authRepository(Ref ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  // final googleSignIn = ref.watch(googleSignInProvider);
  return core.FirebaseAuthService(
    firebaseAuth: firebaseAuth,
    // googleSignIn: googleSignIn,
  );
}

/// Provider do serviço de autenticação Firebase
@Riverpod(keepAlive: true)
core.FirebaseAuthService firebaseAuthService(Ref ref) {
  return core.FirebaseAuthService();
}

/// Provider do repositório de armazenamento local
@Riverpod(keepAlive: true)
core.ILocalStorageRepository localStorageRepository(Ref ref) {
  return ReceituagroDriftStorageAdapter(ref.watch(receituagroDatabaseProvider));
}

/// Provider do serviço de account deletion
@Riverpod(keepAlive: true)
core.AccountDeletionService accountDeletionService(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final dataCleaner = ref.watch(dataCleanerServiceProvider);
  return core.AccountDeletionService(
    authRepository: authRepo,
    appDataCleaner: dataCleaner,
  );
}

/// Provider do serviço enhanced de account deletion
@Riverpod(keepAlive: true)
core.EnhancedAccountDeletionService enhancedAccountDeletionService(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final dataCleaner = ref.watch(dataCleanerServiceProvider);
  return core.EnhancedAccountDeletionService(
    authRepository: authRepo,
    appDataCleaner: dataCleaner,
  );
}

// ========== SUBSCRIPTION/PREMIUM SERVICES ==========

// Temporarily disabled during riverpod_generator fix
// /// Provider do repositório de subscription
// @Riverpod(keepAlive: true)
// core.ISubscriptionRepository subscriptionRepository(Ref ref) {
//   return core.RevenueCatService();
// }

// /// Provider do serviço de rating
// @Riverpod(keepAlive: true)
// core.IAppRatingRepository appRatingRepository(Ref ref) {
//   return core.AppRatingService(
//     appStoreId: '967785485', // ReceitaAgro iOS App Store ID
//     googlePlayId: 'br.com.agrimind.pragassoja', // Android Package ID
//     minDays: 3,
//     minLaunches: 5,
//     remindDays: 7,
//     remindLaunches: 10,
//   );
// }

// Temporarily disabled during riverpod_generator fix
// /// Provider do serviço de premium
// @Riverpod(keepAlive: true)
// ReceitaAgroPremiumService premiumService(Ref ref) {
//   final analytics = ref.watch(analyticsServiceProvider);
//   final cloudFunctions = ref.watch(cloudFunctionsServiceProvider);
//   final remoteConfig = ref.watch(remoteConfigServiceProvider);
//   final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);
//
//   final service = ReceitaAgroPremiumService(
//     analytics: analytics,
//     cloudFunctions: cloudFunctions,
//     remoteConfig: remoteConfig,
//     subscriptionRepository: subscriptionRepo,
//   );
//
//   ReceitaAgroPremiumService.setInstance(service);
//   return service;
// }

// ========== NAVIGATION ANALYTICS ==========

// Temporarily disabled during riverpod_generator fix
// /// Provider do serviço de analytics de navegação
// @Riverpod(keepAlive: true)
// core.NavigationAnalyticsService navigationAnalyticsService(Ref ref) {
//   final firebaseAnalytics = ref.watch(firebaseAnalyticsServiceProvider);
//   return core.NavigationAnalyticsService(firebaseAnalytics);
// }

// /// Provider do serviço de configuração de navegação
// @Riverpod(keepAlive: true)
// core.NavigationConfigurationService navigationConfigurationService(Ref ref) {
//   return core.NavigationConfigurationService();
// }

// /// Firebase Firestore Provider
// @Riverpod(keepAlive: true)
// FirebaseFirestore firebaseFirestore(Ref ref) {
//   return FirebaseFirestore.instance;
// }

// /// Firebase Auth Provider
// @Riverpod(keepAlive: true)
// FirebaseAuth firebaseAuth(Ref ref) {
//   return FirebaseAuth.instance;
// }

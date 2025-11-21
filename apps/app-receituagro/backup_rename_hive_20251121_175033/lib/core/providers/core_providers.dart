import 'package:core/core.dart' as core;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/receituagro_database.dart';
import '../../features/analytics/analytics_service.dart';
import '../../features/analytics/analytics_providers.dart';
import '../di/injection_container.dart' as di;
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
import '../sync/sync_operations.dart';
import '../sync/sync_queue.dart';

part 'core_providers.g.dart';

// ========== DATABASE ==========

/// Provider do banco de dados Drift (Singleton)
@Riverpod(keepAlive: true)
ReceituagroDatabase receituagroDatabase(Ref ref) {
  return ReceituagroDatabase.injectable();
}

// ========== CORE SERVICES ==========

/// Provider do serviço de analytics
@Riverpod(keepAlive: true)
ReceitaAgroAnalyticsService analyticsService(Ref ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  return ReceitaAgroAnalyticsService(repo);
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
  return di.sl<DiagnosticoIntegrationService>();
}

/// Provider do data cleaner
@Riverpod(keepAlive: true)
core.IAppDataCleaner dataCleanerService(Ref ref) {
  return ReceitaAgroDataCleaner();
}

/// Provider do app data manager
@Riverpod(keepAlive: true)
IAppDataManager appDataManager(Ref ref) {
  return AppDataManager();
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

/// Provider do unified sync manager do core
@Riverpod(keepAlive: true)
core.UnifiedSyncManager unifiedSyncManager(Ref ref) {
  return core.UnifiedSyncManager.instance;
}

/// Provider do serviço de sincronização do ReceitaAgro
@Riverpod(keepAlive: true)
ReceitaAgroSyncService receitaAgroSyncService(Ref ref) {
  return ReceitaAgroSyncService();
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
  return di.sl<core.FirebaseAnalyticsService>();
}

// ========== AUTH SERVICES (from core) ==========

/// Provider do repositório de autenticação
@Riverpod(keepAlive: true)
core.IAuthRepository authRepository(Ref ref) {
  return di.sl<core.IAuthRepository>();
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

/// Provider do repositório de subscription
@Riverpod(keepAlive: true)
core.ISubscriptionRepository subscriptionRepository(Ref ref) {
  return core.RevenueCatService();
}

/// Provider do serviço de rating
@Riverpod(keepAlive: true)
core.IAppRatingRepository appRatingRepository(Ref ref) {
  return core.AppRatingService(
    appStoreId: '967785485', // ReceitaAgro iOS App Store ID
    googlePlayId: 'br.com.agrimind.pragassoja', // Android Package ID
    minDays: 3,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 10,
  );
}

/// Provider do serviço de premium
@Riverpod(keepAlive: true)
ReceitaAgroPremiumService premiumService(Ref ref) {
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
}

// ========== NAVIGATION ANALYTICS ==========

/// Provider do serviço de analytics de navegação
@Riverpod(keepAlive: true)
core.NavigationAnalyticsService navigationAnalyticsService(Ref ref) {
  final firebaseAnalytics = ref.watch(firebaseAnalyticsServiceProvider);
  return core.NavigationAnalyticsService(firebaseAnalytics);
}

/// Provider do serviço de configuração de navegação
@Riverpod(keepAlive: true)
core.NavigationConfigurationService navigationConfigurationService(Ref ref) {
  return core.NavigationConfigurationService();
}

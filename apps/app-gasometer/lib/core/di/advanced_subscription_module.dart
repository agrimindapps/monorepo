import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:core/src/domain/services/i_subscription_sync_service.dart';
import 'package:core/src/services/subscription/subscription_sync_models.dart'
    as subscription_models;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Módulo de injeção de dependências para o sistema avançado de subscription
///
/// Configura todos os providers e serviços necessários para sincronização
/// multi-source de assinaturas premium no GasOMeter.
@module
abstract class AdvancedSubscriptionModule {
  // ==================== Data Providers ====================

  /// Provider RevenueCat (Priority: 100)
  @lazySingleton
  RevenueCatSubscriptionProvider revenueCatProvider(
    ISubscriptionRepository subscriptionRepository,
  ) {
    return RevenueCatSubscriptionProvider(
      subscriptionRepository: subscriptionRepository,
    );
  }

  /// Provider Firebase (Priority: 80)
  @lazySingleton
  FirebaseSubscriptionProvider firebaseProvider(
    FirebaseFirestore firestore,
    IAuthRepository authRepository,
  ) {
    return FirebaseSubscriptionProvider(
      firestore: firestore,
      authRepository: authRepository,
    );
  }

  /// Provider Local (Priority: 40)
  @lazySingleton
  LocalSubscriptionProvider localProvider(SharedPreferences sharedPreferences) {
    return LocalSubscriptionProvider(sharedPreferences: sharedPreferences);
  }

  // ==================== Support Services ====================

  /// Conflict resolver com estratégia baseada em prioridade
  @lazySingleton
  SubscriptionConflictResolver conflictResolver() {
    return SubscriptionConflictResolver(
      strategy: subscription_models.ConflictResolutionStrategy.priorityBased,
    );
  }

  /// Debounce manager para throttling
  @lazySingleton
  SubscriptionDebounceManager debounceManager() {
    return SubscriptionDebounceManager();
  }

  /// Retry manager com exponential backoff
  @lazySingleton
  SubscriptionRetryManager retryManager() {
    return SubscriptionRetryManager();
  }

  /// Cache service em memória
  @lazySingleton
  SubscriptionCacheService cacheService() {
    return SubscriptionCacheService();
  }

  // ==================== Advanced Sync Service ====================

  /// Serviço de sincronização avançada
  ///
  /// Substitui o PremiumSyncService local, integrando:
  /// - RevenueCat (in-app purchases)
  /// - Firebase (cross-device sync)
  /// - Local (offline support)
  @lazySingleton
  AdvancedSubscriptionSyncService advancedSyncService(
    RevenueCatSubscriptionProvider revenueCatProvider,
    FirebaseSubscriptionProvider firebaseProvider,
    LocalSubscriptionProvider localProvider,
    SubscriptionConflictResolver conflictResolver,
    SubscriptionDebounceManager debounceManager,
    SubscriptionRetryManager retryManager,
    SubscriptionCacheService cacheService,
  ) {
    return AdvancedSubscriptionSyncService(
      providers: [revenueCatProvider, firebaseProvider, localProvider],
      configuration: subscription_models.AdvancedSyncConfiguration.standard,
      conflictResolver: conflictResolver,
      debounceManager: debounceManager,
      retryManager: retryManager,
      cacheService: cacheService,
    );
  }

  // ==================== Legacy Compatibility ====================

  /// Alias para manter compatibilidade com código existente
  ///
  /// Permite usar ISubscriptionSyncService no lugar de PremiumSyncService
  /// sem quebrar código existente.
  @lazySingleton
  ISubscriptionSyncService subscriptionSyncService(
    AdvancedSubscriptionSyncService advancedSyncService,
  ) {
    return advancedSyncService;
  }
}

/// Módulo para serviços legados do GasOMeter
///
/// Mantém compatibilidade com código existente durante migração
@module
abstract class LegacyPremiumModule {
  // Note: PremiumSyncServiceAdapter deve ser registrado manualmente
  // ou via @injectable no próprio arquivo para evitar dependências circulares
}

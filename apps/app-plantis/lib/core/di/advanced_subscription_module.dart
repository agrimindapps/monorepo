import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:core/src/domain/services/i_subscription_sync_service.dart';
import 'package:core/src/services/subscription/subscription_sync_models.dart'
    as subscription_models;

/// Módulo de injeção de dependências para o sistema avançado de subscription
///
/// Configura todos os providers e serviços necessários para sincronização
/// multi-source de assinaturas premium no Plantis.
///
/// Benefícios:
/// - Cross-device sync via Firebase
/// - Offline support com cache local
/// - Retry automático com exponential backoff
/// - Debounce para evitar syncs excessivos
///
/// Plantis Premium Features:
/// - Unlimited plants (vs 5 free)
/// - Advanced notifications
/// - Data export
/// - Cloud backup
@module
abstract class AdvancedSubscriptionModule {
  // ==================== Data Providers ====================

  /// Provider RevenueCat (Priority: 100)
  /// Fonte primária de verdade para in-app purchases
  ///
  /// NOTE: ISubscriptionRepository is now registered in ExternalModule
  @lazySingleton
  RevenueCatSubscriptionProvider revenueCatProvider(
    ISubscriptionRepository subscriptionRepository,
  ) {
    return RevenueCatSubscriptionProvider(
      subscriptionRepository: subscriptionRepository,
    );
  }

  /// Provider Firebase (Priority: 80)
  /// Cross-device sync em tempo real
  ///
  /// Essencial para Plantis: permite sincronizar plant limits e
  /// premium features entre múltiplos dispositivos
  ///
  /// NOTE: IAuthRepository is now registered in ExternalModule
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
  /// Offline fallback com SharedPreferences
  ///
  /// Crítico para Plantis: garante que plant limits funcionem offline
  @lazySingleton
  LocalSubscriptionProvider localProvider(SharedPreferences sharedPreferences) {
    return LocalSubscriptionProvider(sharedPreferences: sharedPreferences);
  }

  // ==================== Support Services ====================

  /// Conflict resolver com estratégia baseada em prioridade
  ///
  /// Priority order: RevenueCat (100) > Firebase (80) > Local (40)
  /// Importante para Plantis: garante que RevenueCat sempre vence
  @lazySingleton
  SubscriptionConflictResolver conflictResolver() {
    return const SubscriptionConflictResolver(
      strategy: subscription_models.ConflictResolutionStrategy.priorityBased,
    );
  }

  /// Debounce manager para throttling de sync
  ///
  /// Evita múltiplas chamadas de sync em rápida sucessão
  /// Plantis: útil quando usuário adiciona várias plantas rapidamente
  @lazySingleton
  SubscriptionDebounceManager debounceManager() {
    return SubscriptionDebounceManager();
  }

  /// Retry manager com exponential backoff
  ///
  /// Garante resiliência em caso de falhas de rede
  /// Plantis: critical para manter plant limits corretos
  @lazySingleton
  SubscriptionRetryManager retryManager() {
    return SubscriptionRetryManager();
  }

  /// Cache service em memória com TTL
  ///
  /// Performance boost para acessos frequentes
  /// Plantis: reduz latência ao verificar plant limits
  @lazySingleton
  SubscriptionCacheService cacheService() {
    return SubscriptionCacheService();
  }

  // ==================== Advanced Sync Service ====================

  /// Serviço de sincronização avançada
  ///
  /// Orquestra os 3 providers (RevenueCat, Firebase, Local) com:
  /// - Conflict resolution automática
  /// - Retry em caso de erro
  /// - Debounce de atualizações
  /// - Cache em memória
  ///
  /// Configuração: Standard (balanced)
  /// - Debounce: 2s
  /// - Max retries: 3
  /// - Sync interval: 30min
  /// - Log level: info
  ///
  /// Substitui o SubscriptionSyncService customizado (1,085 linhas)
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
  /// Permite usar ISubscriptionSyncService no lugar de
  /// SimpleSubscriptionSyncService ou SubscriptionSyncService customizado.
  ///
  /// O adapter irá wrappear este serviço para preservar a
  /// interface existente dos managers do Plantis.
  @lazySingleton
  ISubscriptionSyncService subscriptionSyncService(
    AdvancedSubscriptionSyncService advancedSyncService,
  ) {
    return advancedSyncService;
  }
}

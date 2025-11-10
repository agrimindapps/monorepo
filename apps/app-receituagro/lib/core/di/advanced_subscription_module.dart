import 'package:core/core.dart' hide Column;
import 'package:core/src/services/subscription/subscription_sync_models.dart'
    as subscription_models;

/// Módulo de injeção de dependências para o sistema avançado de subscription
///
/// Configura todos os providers e serviços necessários para sincronização
/// multi-source de assinaturas premium no ReceitaAgro.
///
/// Benefícios:
/// - Cross-device sync via Firebase
/// - Offline support com cache local
/// - Retry automático com exponential backoff
/// - Debounce para evitar syncs excessivos
@module
abstract class AdvancedSubscriptionModule {
  // ==================== Data Providers ====================

  /// Provider RevenueCat (Priority: 100)
  /// Fonte primária de verdade para in-app purchases
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
  @lazySingleton
  LocalSubscriptionProvider localProvider(SharedPreferences sharedPreferences) {
    return LocalSubscriptionProvider(sharedPreferences: sharedPreferences);
  }

  // ==================== Support Services ====================

  /// Conflict resolver com estratégia baseada em prioridade
  ///
  /// Priority order: RevenueCat (100) > Firebase (80) > Local (40)
  @lazySingleton
  SubscriptionConflictResolver conflictResolver() {
    return const SubscriptionConflictResolver(
      strategy: subscription_models.ConflictResolutionStrategy.priorityBased,
    );
  }

  /// Debounce manager para throttling de sync
  ///
  /// Evita múltiplas chamadas de sync em rápida sucessão
  @lazySingleton
  SubscriptionDebounceManager debounceManager() {
    return SubscriptionDebounceManager();
  }

  /// Retry manager com exponential backoff
  ///
  /// Garante resiliência em caso de falhas de rede
  @lazySingleton
  SubscriptionRetryManager retryManager() {
    return SubscriptionRetryManager();
  }

  /// Cache service em memória com TTL
  ///
  /// Performance boost para acessos frequentes
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
  /// SimpleSubscriptionSyncService sem quebrar código existente.
  @lazySingleton
  ISubscriptionSyncService subscriptionSyncService(
    AdvancedSubscriptionSyncService advancedSyncService,
  ) {
    return advancedSyncService;
  }
}

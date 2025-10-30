import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../models/user_subscription_model.dart';
import '../notifiers/index.dart';
import '../services/subscription_error_message_service.dart';
import '../../domain/entities/index.dart';

final sl = GetIt.instance;

// ═══════════════════════════════════════════════════════════════
// INDIVIDUAL NOTIFIER PROVIDERS
// ═══════════════════════════════════════════════════════════════

/// Provider do SubscriptionStatusNotifier
/// Gerencia estado de subscription do usuário
final subscriptionStatusNotifierProvider =
    StateNotifierProvider<SubscriptionStatusNotifier, SubscriptionStatusState>(
      (ref) =>
          SubscriptionStatusNotifier(sl<SubscriptionErrorMessageService>()),
      name: 'subscriptionStatusNotifier',
    );

/// Provider do TrialNotifier
/// Gerencia estado de trial do usuário
final trialNotifierProvider = StateNotifierProvider<TrialNotifier, TrialState>(
  (ref) => TrialNotifier(),
  name: 'trialNotifier',
);

/// Provider do BillingNotifier
/// Gerencia problemas de cobrança
final billingNotifierProvider =
    StateNotifierProvider<BillingNotifier, BillingState>(
      (ref) => BillingNotifier(sl<SubscriptionErrorMessageService>()),
      name: 'billingNotifier',
    );

/// Provider do PurchaseNotifier
/// Gerencia histórico de compras
final purchaseNotifierProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>(
      (ref) => PurchaseNotifier(),
      name: 'purchaseNotifier',
    );

// ═══════════════════════════════════════════════════════════════
// COMPOSITE PROVIDER
// ═══════════════════════════════════════════════════════════════

/// Provider principal que combina todos os notifiers
///
/// Este provider:
/// - Watches todos os 4 notifiers individuais
/// - Recomputa agregação sempre que algum muda
/// - Fornece view única e tipada via UserSubscriptionModel
/// - Oferece getters convenientes para UI
///
/// Uso na UI:
/// ```dart
/// final userSubscription = ref.watch(userSubscriptionProvider);
///
/// if (userSubscription.hasActiveSubscription) {
///   // Render premium content
/// }
/// ```
final userSubscriptionProvider = Provider<UserSubscriptionModel>((ref) {
  // Watch todos os 4 notifiers
  final subscriptionState = ref.watch(subscriptionStatusNotifierProvider);
  final trialState = ref.watch(trialNotifierProvider);
  final billingState = ref.watch(billingNotifierProvider);
  final purchaseState = ref.watch(purchaseNotifierProvider);

  // Agregar em um único modelo
  return UserSubscriptionModel(
    // Dados de subscription
    subscription: subscriptionState.subscription,
    subscriptionLoading: subscriptionState.isLoading,
    subscriptionError: subscriptionState.error,

    // Dados de trial
    trial: trialState.trial,
    trialLoading: trialState.isLoading,
    trialError: trialState.error,

    // Dados de cobrança
    billingIssues: billingState.issues,
    billingLoading: billingState.isLoading,
    billingError: billingState.error,

    // Dados de compras
    purchases: purchaseState.purchases,
    purchasesLoading: purchaseState.isLoading,
    purchasesError: purchaseState.error,
  );
});

// ═══════════════════════════════════════════════════════════════
// HELPER PROVIDERS (Derived/Computed)
// ═══════════════════════════════════════════════════════════════

/// Provider que indica se usuário tem acesso premium
///
/// Útil para condicionar renderização de features premium
///
/// Uso:
/// ```dart
/// final hasPremiumAccess = ref.watch(hasPremiumAccessProvider);
/// if (hasPremiumAccess) { /* render premium */ }
/// ```
final hasPremiumAccessProvider = Provider<bool>((ref) {
  final subscription = ref.watch(userSubscriptionProvider);
  return subscription.hasActiveSubscription;
});

/// Provider que indica se há atenção necessária
///
/// Retorna true se:
/// - Subscription expirando em breve
/// - Trial expirando em breve
/// - Problemas críticos de billing
/// - Compras pendentes
///
/// Útil para mostrar badge/notificação na UI
final needsUserAttentionProvider = Provider<bool>((ref) {
  final subscription = ref.watch(userSubscriptionProvider);
  return subscription.needsUserAttention;
});

/// Provider que retorna próxima ação recomendada
///
/// Valores possíveis:
/// - fixBillingIssue
/// - convertTrialToSubscription
/// - renewSubscription
/// - purchaseSubscription
/// - retryFailedPurchase
/// - updatePaymentMethod
/// - null (nenhuma ação recomendada)
///
/// Útil para mostrar CTA (Call-To-Action) prioritário
final recommendedUserActionProvider = Provider<UserAction?>((ref) {
  final subscription = ref.watch(userSubscriptionProvider);
  return subscription.recommendedAction;
});

/// Provider que retorna banner prioritário para exibir
///
/// Retorna o banner mais importante baseado em:
/// 1. Problemas críticos de billing
/// 2. Trial expirando
/// 3. Subscription expirando
/// 4. Sem acesso
///
/// Useful para Top Banner da app
final priorityBannerProvider = Provider<PriorityBanner?>((ref) {
  final subscription = ref.watch(userSubscriptionProvider);
  return subscription.priorityBanner;
});

/// Provider que retorna status compacto para exibir
///
/// Exemplos:
/// - "⚠️ Problema de cobrança"
/// - "⏰ Trial expirando em 3d"
/// - "✅ Premium Ativo"
/// - "❌ Sem acesso"
///
/// Útil para badges e status indicadores
final statusSummaryProvider = Provider<String>((ref) {
  final subscription = ref.watch(userSubscriptionProvider);
  return subscription.statusSummary;
});

/// Provider que retorna status de acesso
///
/// Valores:
/// - AccessStatus.subscriptionActive
/// - AccessStatus.trialActive
/// - AccessStatus.gracePeriod
/// - AccessStatus.noAccess
final accessStatusProvider = Provider<AccessStatus>((ref) {
  final subscription = ref.watch(userSubscriptionProvider);
  return subscription.accessStatus;
});

/// Provider que indica se há problemas de cobrança pendentes
final hasBillingIssuesProvider = Provider<bool>((ref) {
  final subscription = ref.watch(userSubscriptionProvider);
  return subscription.hasBillingIssues;
});

/// Provider que indica se há problemas críticos de cobrança
final hasCriticalBillingIssuesProvider = Provider<bool>((ref) {
  final subscription = ref.watch(userSubscriptionProvider);
  return subscription.hasCriticalBillingIssues;
});

/// Provider que retorna todos os erros agregados
final allErrorsProvider = Provider<List<String>>((ref) {
  final subscription = ref.watch(userSubscriptionProvider);
  return subscription.allErrors;
});

/// Provider que indica se alguma operação está em progresso
final isLoadingProvider = Provider<bool>((ref) {
  final subscription = ref.watch(userSubscriptionProvider);
  return subscription.isLoading;
});

// ═══════════════════════════════════════════════════════════════
// ACTION PROVIDERS (Family)
// ═══════════════════════════════════════════════════════════════

/// Provider para ações comuns em subscription
///
/// Permite chamar métodos dos notifiers através do Riverpod
///
/// Uso:
/// ```dart
/// final subscriptionActions = ref.read(subscriptionActionsProvider.notifier);
/// await subscriptionActions.loadAll();
/// await subscriptionActions.upgradeSubscription(newTier, 'monthly');
/// ```
final subscriptionActionsProvider = Provider<SubscriptionActions>((ref) {
  final subscriptionNotifier = ref.read(
    subscriptionStatusNotifierProvider.notifier,
  );
  final trialNotifier = ref.read(trialNotifierProvider.notifier);
  final billingNotifier = ref.read(billingNotifierProvider.notifier);
  final purchaseNotifier = ref.read(purchaseNotifierProvider.notifier);

  return SubscriptionActions(
    subscriptionNotifier: subscriptionNotifier,
    trialNotifier: trialNotifier,
    billingNotifier: billingNotifier,
    purchaseNotifier: purchaseNotifier,
  );
});

// ═══════════════════════════════════════════════════════════════
// SUBSCRIPTION ACTIONS CLASS
// ═══════════════════════════════════════════════════════════════

/// Classe que agrupa ações comuns de subscription
///
/// Fornece interface simplificada para UI chamar operações
class SubscriptionActions {
  final SubscriptionStatusNotifier subscriptionNotifier;
  final TrialNotifier trialNotifier;
  final BillingNotifier billingNotifier;
  final PurchaseNotifier purchaseNotifier;

  SubscriptionActions({
    required this.subscriptionNotifier,
    required this.trialNotifier,
    required this.billingNotifier,
    required this.purchaseNotifier,
  });

  /// Carrega todos os dados (operação batch)
  /// Útil na inicialização
  Future<void> loadAll() async {
    await Future.wait([
      subscriptionNotifier.loadSubscriptionStatus(),
      trialNotifier.loadTrialInfo(),
      billingNotifier.loadBillingIssues(),
      purchaseNotifier.loadPurchaseHistory(),
    ]);
  }

  /// Sincroniza todos os dados com backend
  /// Útil quando app volta de background
  Future<void> syncAll() async {
    await Future.wait([
      subscriptionNotifier.syncWithBackend(),
      trialNotifier.syncWithBackend(),
      billingNotifier.syncWithBackend(),
      purchaseNotifier.syncWithBackend(),
    ]);
  }

  /// Faz upgrade de subscription
  Future<void> upgradeSubscription({
    required SubscriptionTier newTier,
    required String billingCycle,
  }) async {
    await subscriptionNotifier.upgradeSubscription(
      newTier: newTier,
      billingCycle: billingCycle,
    );
  }

  /// Faz downgrade de subscription
  Future<void> downgradeSubscription({
    required SubscriptionTier newTier,
    required DateTime? effectiveDate,
  }) async {
    await subscriptionNotifier.downgradeSubscription(
      newTier: newTier,
      effectiveDate: effectiveDate,
    );
  }

  /// Cancela subscription
  Future<void> cancelSubscription({
    required String reason,
    String? feedback,
    bool immediateEffect = false,
  }) async {
    await subscriptionNotifier.cancelSubscription(
      reason: reason,
      feedback: feedback,
      immediateEffect: immediateEffect,
    );
  }

  /// Reativa subscription cancelada
  Future<void> reactiveSubscription() async {
    await subscriptionNotifier.reactiveSubscription();
  }

  /// Inicia novo trial
  Future<void> startNewTrial({
    required String productId,
    int durationInDays = 14,
  }) async {
    await trialNotifier.startNewTrial(
      productId: productId,
      durationInDays: durationInDays,
    );
  }

  /// Cancela trial
  Future<void> cancelTrial({required String reason}) async {
    await trialNotifier.cancelTrial(reason: reason);
  }

  /// Faz retry de cobrança falhada
  Future<void> retryFailedBilling({required String issueId}) async {
    await billingNotifier.retryFailedBilling(issueId: issueId);
  }

  /// Resolve problema de cobrança
  Future<void> resolveBillingIssue({
    required String issueId,
    String? resolutionNotes,
  }) async {
    await billingNotifier.resolveBillingIssue(
      issueId: issueId,
      resolutionNotes: resolutionNotes,
    );
  }

  /// Atualiza método de pagamento
  Future<void> updatePaymentMethod({required String paymentMethodToken}) async {
    await billingNotifier.updatePaymentMethod(
      paymentMethodToken: paymentMethodToken,
    );
  }

  /// Compra produto
  Future<void> purchaseProduct({
    required String productId,
    required double amount,
    required PurchaseType purchaseType,
  }) async {
    await purchaseNotifier.purchaseProduct(
      productId: productId,
      amount: amount,
      purchaseType: purchaseType,
    );
  }

  /// Restaura compras anteriores
  Future<void> restorePurchases({bool includeExpired = true}) async {
    await purchaseNotifier.restorePurchases(includeExpired: includeExpired);
  }

  /// Faz retry de compra falhada
  Future<void> retryFailedPurchase({required String purchaseId}) async {
    await purchaseNotifier.retryFailedPurchase(purchaseId: purchaseId);
  }

  /// Limpa todos os dados em cache
  void clearAll() {
    subscriptionNotifier.clearState();
    trialNotifier.clearState();
    billingNotifier.clearState();
    purchaseNotifier.clearState();
  }
}

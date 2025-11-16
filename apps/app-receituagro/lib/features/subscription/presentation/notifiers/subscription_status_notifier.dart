import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/index.dart';
import '../services/subscription_error_message_service.dart';

part 'subscription_status_notifier.g.dart';

/// Estado da assinatura do usuário com indicadores de progresso
class SubscriptionStatusState {
  final SubscriptionEntity? subscription;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const SubscriptionStatusState({
    this.subscription,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  factory SubscriptionStatusState.initial() {
    return const SubscriptionStatusState(
      subscription: null,
      isLoading: false,
      error: null,
      lastUpdated: null,
    );
  }

  /// Cópia com atualizações seletivas
  SubscriptionStatusState copyWith({
    SubscriptionEntity? subscription,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return SubscriptionStatusState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Indicador se existe assinatura ativa
  bool get hasActiveSubscription =>
      subscription != null && subscription!.isActive;

  /// Indica se precisa de atualização (> 1 hora)
  bool get needsRefresh {
    if (lastUpdated == null) return true;
    final diff = DateTime.now().difference(lastUpdated!);
    return diff.inHours > 1;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionStatusState &&
          runtimeType == other.runtimeType &&
          subscription == other.subscription &&
          isLoading == other.isLoading &&
          error == other.error &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode =>
      subscription.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      lastUpdated.hashCode;

  @override
  String toString() =>
      'SubscriptionStatusState(subscription: $subscription, isLoading: $isLoading, error: $error, lastUpdated: $lastUpdated)';
}

/// Notifier que gerencia o estado da assinatura
///
/// Responsabilidades:
/// - Carregar status da assinatura
/// - Validar validade e expiração
/// - Atualizar automaticamente
/// - Gerenciar operações de upgrade/downgrade
/// - Rastrear histórico de mudanças
@riverpod
class SubscriptionStatusNotifier extends _$SubscriptionStatusNotifier {
  @override
  SubscriptionStatusState build(SubscriptionErrorMessageService errorService) {
    return SubscriptionStatusState.initial();
  }

  SubscriptionErrorMessageService get _errorService => errorService;

  /// Carrega o status da assinatura do usuário
  ///
  /// Simula chamada a um repositório/serviço de backend
  /// Em uma aplicação real, buscaria de:
  /// - Base de dados local (Hive)
  /// - API remota
  /// - Sistema de assinatura (App Store, Play Store)
  Future<void> loadSubscriptionStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simula latência de rede
      await Future<void>.delayed(const Duration(milliseconds: 800));

      // TODO: Substituir por chamada real ao repositório
      // final subscription = await _subscriptionRepository.getActiveSubscription();

      // Dados de exemplo (remover em produção)
      final exampleSubscription = SubscriptionEntity(
        id: 'sub_123456',
        productId: 'com.receituagro.premium.monthly',
        status: SubscriptionStatus.active,
        tier: SubscriptionTier.premium,
        expirationDate: DateTime.now().add(const Duration(days: 25)),
        renewalDate: DateTime.now().add(const Duration(days: 25)),
        store: Store.playStore,
        isAutoRenewing: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        subscription: exampleSubscription,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _errorService.getLoadStatusError(error.toString()),
      );
    }
  }

  /// Atualiza o status da assinatura manualmente
  /// Útil quando o usuário toma uma ação que afeta assinatura
  Future<void> refreshStatus() async {
    if (state.subscription == null) {
      await loadSubscriptionStatus();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // TODO: Fazer refresh real contra backend
      // final updated = await _subscriptionRepository.refreshSubscriptionStatus();

      state = state.copyWith(isLoading: false, lastUpdated: DateTime.now());
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _errorService.getUpdateStatusError(error.toString()),
      );
    }
  }

  /// Valida a validade da assinatura atual
  /// Retorna true se a assinatura é válida e ativa
  bool validateSubscriptionValidity() {
    final subscription = state.subscription;
    if (subscription == null) return false;

    // Validação básica
    if (!subscription.isActive) return false;
    if (subscription.isExpired) return false;

    // Validação de data
    if (subscription.expirationDate == null) return false;
    if (subscription.expirationDate!.isBefore(DateTime.now())) return false;

    return true;
  }

  /// Verifica se a assinatura está prestes a expirar
  /// e realiza ações automatizadas
  Future<void> checkExpirationStatus() async {
    final subscription = state.subscription;
    if (subscription == null) return;

    // Se está expirando em menos de 7 dias
    if (subscription.isExpiringSoon && !subscription.isAutoRenewing) {
      // TODO: Disparar notificação/alerta ao usuário
      // _notificationService.showExpirationWarning(subscription);
    }

    // Se expirou e estava em período de graça
    if (subscription.isExpired && subscription.isInGracePeriod) {
      // TODO: Aplicar limitações parciais
      // _featureAccessService.applyGracePeriodLimitations();
    }

    // Se expirou completamente
    if (subscription.isExpired && !subscription.isInGracePeriod) {
      // TODO: Remover acesso a features premium
      // _featureAccessService.removeAllPremiumAccess();
    }
  }

  /// Realiza um upgrade de tier de assinatura
  ///
  /// Parâmetros:
  /// - [newTier]: Novo tier a fazer upgrade
  /// - [billingCycle]: 'monthly' ou 'yearly'
  Future<void> upgradeSubscription({
    required SubscriptionTier newTier,
    required String billingCycle,
  }) async {
    final currentSubscription = state.subscription;
    if (currentSubscription == null) {
      state = state.copyWith(
        error: 'Nenhuma assinatura ativa para fazer upgrade',
      );
      return;
    }

    // Validar upgrade (não fazer downgrade)
    if (newTier.index <= currentSubscription.tier.index) {
      state = state.copyWith(error: 'Novo tier deve ser superior ao atual');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      // TODO: Chamar backend/API de upgrade
      // final updated = await _subscriptionRepository.upgradeSubscription(
      //   newTier: newTier,
      //   billingCycle: billingCycle,
      // );

      final updated = currentSubscription.copyWith(
        tier: newTier,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        subscription: updated,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // TODO: Log event de upgrade
      // _analyticsService.logEvent('subscription_upgrade', {
      //   'from_tier': currentSubscription.tier.toString(),
      //   'to_tier': newTier.toString(),
      //   'billing_cycle': billingCycle,
      // });
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _errorService.getUpgradeSubscriptionError(error.toString()),
      );
    }
  }

  /// Realiza downgrade de tier de assinatura
  ///
  /// Parâmetros:
  /// - [newTier]: Novo tier (deve ser inferior ao atual)
  /// - [effectiveDate]: Data em que o downgrade entra em vigor
  Future<void> downgradeSubscription({
    required SubscriptionTier newTier,
    required DateTime? effectiveDate,
  }) async {
    final currentSubscription = state.subscription;
    if (currentSubscription == null) {
      state = state.copyWith(
        error: 'Nenhuma assinatura ativa para fazer downgrade',
      );
      return;
    }

    // Validar downgrade (não fazer upgrade)
    if (newTier.index >= currentSubscription.tier.index) {
      state = state.copyWith(error: 'Novo tier deve ser inferior ao atual');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      // TODO: Chamar backend/API de downgrade
      // final updated = await _subscriptionRepository.downgradeSubscription(
      //   newTier: newTier,
      //   effectiveDate: effectiveDate,
      // );

      final updated = currentSubscription.copyWith(
        tier: newTier,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        subscription: updated,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // TODO: Log event de downgrade
      // _analyticsService.logEvent('subscription_downgrade', {
      //   'from_tier': currentSubscription.tier.toString(),
      //   'to_tier': newTier.toString(),
      // });
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _errorService.getDowngradeSubscriptionError(error.toString()),
      );
    }
  }

  /// Cancela a assinatura do usuário
  ///
  /// Parâmetros:
  /// - [reason]: Motivo do cancelamento (para analytics)
  /// - [feedback]: Feedback opcional do usuário
  /// - [immediateEffect]: Se true, cancela imediatamente; se false, na próxima renovação
  Future<void> cancelSubscription({
    required String reason,
    String? feedback,
    bool immediateEffect = false,
  }) async {
    final currentSubscription = state.subscription;
    if (currentSubscription == null) {
      state = state.copyWith(error: 'Nenhuma assinatura ativa para cancelar');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // TODO: Chamar backend/API de cancelamento
      // await _subscriptionRepository.cancelSubscription(
      //   immediate: immediateEffect,
      // );

      final updated = currentSubscription.copyWith(
        status: SubscriptionStatus.cancelled,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        subscription: updated,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // TODO: Log event de cancelamento
      // _analyticsService.logEvent('subscription_cancelled', {
      //   'reason': reason,
      //   'feedback': feedback,
      //   'tier': currentSubscription.tier.toString(),
      //   'immediate': immediateEffect,
      // });
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _errorService.getCancelSubscriptionError(error.toString()),
      );
    }
  }

  /// Reativa uma assinatura cancelada
  Future<void> reactiveSubscription() async {
    final currentSubscription = state.subscription;
    if (currentSubscription == null) {
      state = state.copyWith(error: 'Nenhuma assinatura para reativar');
      return;
    }

    if (currentSubscription.status != SubscriptionStatus.cancelled) {
      state = state.copyWith(
        error: 'Apenas assinaturas canceladas podem ser reativadas',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      // TODO: Chamar backend/API de reativação
      // final updated = await _subscriptionRepository.reactiveSubscription();

      final updated = currentSubscription.copyWith(
        status: SubscriptionStatus.active,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        subscription: updated,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // TODO: Log event de reativação
      // _analyticsService.logEvent('subscription_reactivated');
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _errorService.getReactivateSubscriptionError(error.toString()),
      );
    }
  }

  /// Sincroniza status com backend
  /// Chamado periodicamente ou quando volta para foreground
  Future<void> syncWithBackend() async {
    if (state.needsRefresh) {
      await refreshStatus();
    }
  }

  /// Limpa o estado e dados em cache
  void clearState() {
    state = SubscriptionStatusState.initial();
  }
}

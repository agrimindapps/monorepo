import '../../domain/entities/index.dart';

/// Modelo agregador que combina dados de todos os notifiers
///
/// Responsabilidade:
/// - Fornecer view única e consistente do estado de subscription
/// - Computar indicadores agregados
/// - Oferecer getters convenientes para UI
/// - Manter coerência entre múltiplas fontes de dados
class UserSubscriptionModel {
  // Dados de subscription
  final SubscriptionEntity? subscription;
  final bool subscriptionLoading;
  final String? subscriptionError;

  // Dados de trial
  final TrialInfoEntity? trial;
  final bool trialLoading;
  final String? trialError;

  // Dados de cobrança
  final List<BillingIssueEntity> billingIssues;
  final bool billingLoading;
  final String? billingError;

  // Dados de compras
  final List<PurchaseHistoryEntity> purchases;
  final bool purchasesLoading;
  final String? purchasesError;

  const UserSubscriptionModel({
    this.subscription,
    this.subscriptionLoading = false,
    this.subscriptionError,
    this.trial,
    this.trialLoading = false,
    this.trialError,
    this.billingIssues = const [],
    this.billingLoading = false,
    this.billingError,
    this.purchases = const [],
    this.purchasesLoading = false,
    this.purchasesError,
  });

  /// Factory para estado inicial vazio
  factory UserSubscriptionModel.initial() {
    return const UserSubscriptionModel(
      subscription: null,
      subscriptionLoading: false,
      subscriptionError: null,
      trial: null,
      trialLoading: false,
      trialError: null,
      billingIssues: [],
      billingLoading: false,
      billingError: null,
      purchases: [],
      purchasesLoading: false,
      purchasesError: null,
    );
  }

  /// Cópia com atualizações seletivas
  UserSubscriptionModel copyWith({
    SubscriptionEntity? subscription,
    bool? subscriptionLoading,
    String? subscriptionError,
    TrialInfoEntity? trial,
    bool? trialLoading,
    String? trialError,
    List<BillingIssueEntity>? billingIssues,
    bool? billingLoading,
    String? billingError,
    List<PurchaseHistoryEntity>? purchases,
    bool? purchasesLoading,
    String? purchasesError,
  }) {
    return UserSubscriptionModel(
      subscription: subscription ?? this.subscription,
      subscriptionLoading: subscriptionLoading ?? this.subscriptionLoading,
      subscriptionError: subscriptionError ?? this.subscriptionError,
      trial: trial ?? this.trial,
      trialLoading: trialLoading ?? this.trialLoading,
      trialError: trialError ?? this.trialError,
      billingIssues: billingIssues ?? this.billingIssues,
      billingLoading: billingLoading ?? this.billingLoading,
      billingError: billingError ?? this.billingError,
      purchases: purchases ?? this.purchases,
      purchasesLoading: purchasesLoading ?? this.purchasesLoading,
      purchasesError: purchasesError ?? this.purchasesError,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INDICADORES AGREGADOS
  // ═══════════════════════════════════════════════════════════════

  /// Indicador se qualquer operação está em progresso
  bool get isLoading =>
      subscriptionLoading || trialLoading || billingLoading || purchasesLoading;

  /// Lista de todos os erros ativos
  List<String> get allErrors => [
    if (subscriptionError != null) subscriptionError!,
    if (trialError != null) trialError!,
    if (billingError != null) billingError!,
    if (purchasesError != null) purchasesError!,
  ];

  /// Indicador se existe algum erro
  bool get hasError => allErrors.isNotEmpty;

  /// Primeiro erro (prioritário para UI)
  String? get primaryError => allErrors.isEmpty ? null : allErrors.first;

  // ═══════════════════════════════════════════════════════════════
  // INDICADORES DE SUBSCRIPTION
  // ═══════════════════════════════════════════════════════════════

  /// Indica se há assinatura ativa
  bool get hasActiveSubscription =>
      subscription != null && subscription!.isActive;

  /// Indica se subscription está expirada
  bool get isSubscriptionExpired =>
      subscription != null && subscription!.isExpired;

  /// Indica se subscription está expirando em breve (< 7 dias)
  bool get isSubscriptionExpiringSoon =>
      subscription != null && subscription!.isExpiringSoon;

  /// Tempo até expiração da assinatura
  Duration? get timeUntilSubscriptionExpiry => subscription?.timeUntilExpiry;

  /// Percentual de vida da assinatura (0-100)
  double get subscriptionPercentageExpired =>
      subscription?.percentageExpired ?? 0.0;

  /// Tier da assinatura atual
  SubscriptionTier? get currentTier => subscription?.tier;

  // ═══════════════════════════════════════════════════════════════
  // INDICADORES DE TRIAL
  // ═══════════════════════════════════════════════════════════════

  /// Indica se há trial ativo
  bool get hasActiveTrial => trial != null && trial!.isActive;

  /// Indica se trial está expirado
  bool get isTrialExpired => trial != null && trial!.isExpired;

  /// Indica se trial está expirando em breve (< 3 dias)
  bool get isTrialExpiringSoon => trial != null && trial!.isExpiringSoon;

  /// Dias restantes no trial
  Duration? get trialDaysRemaining => trial?.daysRemaining;

  /// Percentual de progresso do trial (0-100)
  double get trialProgressPercentage => trial?.progressPercentage ?? 0.0;

  /// Texto formatado dos dias restantes no trial
  String get trialRemainingDisplay {
    if (trial == null) return 'Sem período experimental';
    if (!trial!.isActive) return 'Período experimental finalizado';

    final daysRemaining = trial!.daysRemaining;
    if (daysRemaining == null) return 'Período experimental ativo';

    final days = daysRemaining.inDays;
    if (days > 1) {
      return '$days dias restantes';
    } else if (days == 1) {
      return 'Expira amanhã';
    } else {
      final hours = daysRemaining.inHours;
      if (hours > 0) {
        return 'Expira em $hours horas';
      } else {
        return 'Expira em poucos minutos';
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // INDICADORES DE COBRANÇA
  // ═══════════════════════════════════════════════════════════════

  /// Indica se há problemas de cobrança
  bool get hasBillingIssues => billingIssues.isNotEmpty;

  /// Indica se há problemas críticos de cobrança
  bool get hasCriticalBillingIssues =>
      billingIssues.any((issue) => issue.isCritical);

  /// Problemas de cobrança que precisam de atenção
  List<BillingIssueEntity> get billingIssuesThatNeedAttention =>
      billingIssues.where((issue) => issue.needsAttention).toList();

  /// Problemas críticos de cobrança
  List<BillingIssueEntity> get criticalBillingIssues =>
      billingIssues.where((issue) => issue.isCritical).toList();

  /// Quantidade de problemas que precisam ação do usuário
  int get billingIssueCount => billingIssuesThatNeedAttention.length;

  /// Indica se próximo retry está programado
  bool get hasScheduledBillingRetry =>
      billingIssues.any((issue) => issue.canRetry && issue.nextRetryAt != null);

  // ═══════════════════════════════════════════════════════════════
  // INDICADORES DE COMPRAS
  // ═══════════════════════════════════════════════════════════════

  /// Indica se há compras pendentes
  bool get hasPendingPurchases => purchases.any((p) => p.isPending);

  /// Indica se há compras falhadas
  bool get hasFailedPurchases => purchases.any((p) => p.isFailed);

  /// Compras pendentes
  List<PurchaseHistoryEntity> get pendingPurchases =>
      purchases.where((p) => p.isPending).toList();

  /// Compras falhadas
  List<PurchaseHistoryEntity> get failedPurchases =>
      purchases.where((p) => p.isFailed).toList();

  /// Total gasto em compras bem-sucedidas
  double get totalAmountSpent => purchases
      .where((p) => p.isSuccessful)
      .fold<double>(0, (sum, p) => sum + p.totalAmount);

  // ═══════════════════════════════════════════════════════════════
  // INDICADORES INTEGRADOS (COMBINAR MÚLTIPLAS FONTES)
  // ═══════════════════════════════════════════════════════════════

  /// Indicador se usuário precisa de atenção (subscription, trial ou billing)
  bool get needsUserAttention =>
      isSubscriptionExpiringSoon ||
      isTrialExpiringSoon ||
      hasCriticalBillingIssues ||
      hasPendingPurchases;

  /// Status de acesso geral do usuário
  AccessStatus get accessStatus {
    // Se subscription expirou e não há trial ativo e não está em graça
    if (isSubscriptionExpired && !hasActiveTrial) {
      if (subscription != null && subscription!.isInGracePeriod) {
        return AccessStatus.gracePeriod;
      }
      return AccessStatus.noAccess;
    }

    // Se tem subscription ativa
    if (hasActiveSubscription) {
      return AccessStatus.subscriptionActive;
    }

    // Se tem trial ativo
    if (hasActiveTrial) {
      return AccessStatus.trialActive;
    }

    // Padrão
    return AccessStatus.noAccess;
  }

  /// Indicador se é necessário atualizar método de pagamento
  bool get needsPaymentMethodUpdate => billingIssues.any(
    (issue) =>
        issue.type == BillingIssueType.paymentMethodExpired ||
        issue.type == BillingIssueType.paymentFailed,
  );

  /// Indicador se conversão de trial para subscription é possível
  bool get canConvertTrialToSubscription =>
      hasActiveTrial && !hasActiveSubscription && !hasCriticalBillingIssues;

  /// Próxima ação recomendada para usuário
  UserAction? get recommendedAction {
    // Problemas críticos de billing são prioritários
    if (hasCriticalBillingIssues) {
      return UserAction.fixBillingIssue;
    }

    // Trial expirando é importante
    if (isTrialExpiringSoon && hasActiveTrial) {
      return UserAction.convertTrialToSubscription;
    }

    // Subscription expirando
    if (isSubscriptionExpiringSoon && !hasActiveTrial) {
      return UserAction.renewSubscription;
    }

    // Sem acesso é critical
    if (accessStatus == AccessStatus.noAccess) {
      return UserAction.purchaseSubscription;
    }

    // Compras falhadas
    if (hasFailedPurchases) {
      return UserAction.retryFailedPurchase;
    }

    return null;
  }

  /// Texto para exibir status de acesso principal
  String get accessStatusDisplay {
    switch (accessStatus) {
      case AccessStatus.subscriptionActive:
        return 'Premium Ativo';
      case AccessStatus.trialActive:
        return 'Trial Ativo';
      case AccessStatus.gracePeriod:
        return 'Período de Graça';
      case AccessStatus.noAccess:
        return 'Sem Acesso';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILIDADES PARA UI
  // ═══════════════════════════════════════════════════════════════

  /// Banner prioritário para exibir
  PriorityBanner? get priorityBanner {
    // Erro crítico tem prioridade máxima
    if (hasCriticalBillingIssues) {
      return PriorityBanner(
        title: 'Problema na Cobrança',
        message: criticalBillingIssues.first.displayMessage,
        severity: BannerSeverity.critical,
        action: 'Resolver Agora',
      );
    }

    // Trial expirando
    if (isTrialExpiringSoon && hasActiveTrial) {
      return PriorityBanner(
        title: 'Trial Expirando',
        message: trialRemainingDisplay,
        severity: BannerSeverity.warning,
        action: 'Upgrade Agora',
      );
    }

    // Subscription expirando
    if (isSubscriptionExpiringSoon) {
      return PriorityBanner(
        title: 'Assinatura Expirando',
        message: 'Renovar em ${timeUntilSubscriptionExpiry?.inDays ?? 0} dias',
        severity: BannerSeverity.info,
        action: 'Renovar',
      );
    }

    // Sem acesso
    if (accessStatus == AccessStatus.noAccess && !hasActiveTrial) {
      return PriorityBanner(
        title: 'Acesso Limitado',
        message: 'Faça upgrade para acessar recursos premium',
        severity: BannerSeverity.warning,
        action: 'Upgrade',
      );
    }

    return null;
  }

  /// Resumo de status para widget compacto
  String get statusSummary {
    if (hasCriticalBillingIssues) {
      return '⚠️ Problema de cobrança';
    }
    if (isTrialExpiringSoon && hasActiveTrial) {
      return '⏰ Trial expirando em ${trialDaysRemaining?.inDays ?? 0}d';
    }
    if (isSubscriptionExpiringSoon) {
      return '⏰ Assinatura expira em ${timeUntilSubscriptionExpiry?.inDays ?? 0}d';
    }
    if (hasActiveSubscription) {
      return '✅ Premium Ativo';
    }
    if (hasActiveTrial) {
      return '🎁 Trial Ativo';
    }
    return '❌ Sem acesso';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSubscriptionModel &&
          runtimeType == other.runtimeType &&
          subscription == other.subscription &&
          subscriptionLoading == other.subscriptionLoading &&
          subscriptionError == other.subscriptionError &&
          trial == other.trial &&
          trialLoading == other.trialLoading &&
          trialError == other.trialError &&
          billingIssues == other.billingIssues &&
          billingLoading == other.billingLoading &&
          billingError == other.billingError &&
          purchases == other.purchases &&
          purchasesLoading == other.purchasesLoading &&
          purchasesError == other.purchasesError;

  @override
  int get hashCode =>
      subscription.hashCode ^
      subscriptionLoading.hashCode ^
      subscriptionError.hashCode ^
      trial.hashCode ^
      trialLoading.hashCode ^
      trialError.hashCode ^
      billingIssues.hashCode ^
      billingLoading.hashCode ^
      billingError.hashCode ^
      purchases.hashCode ^
      purchasesLoading.hashCode ^
      purchasesError.hashCode;

  @override
  String toString() =>
      'UserSubscriptionModel(subscription: $subscription, trial: $trial, billingIssues: ${billingIssues.length}, purchases: ${purchases.length}, isLoading: $isLoading, hasError: $hasError)';
}

// ═══════════════════════════════════════════════════════════════
// ENUMS AUXILIARES
// ═══════════════════════════════════════════════════════════════

/// Status de acesso do usuário ao app
enum AccessStatus { subscriptionActive, trialActive, gracePeriod, noAccess }

/// Ações recomendadas para o usuário
enum UserAction {
  purchaseSubscription,
  convertTrialToSubscription,
  renewSubscription,
  fixBillingIssue,
  retryFailedPurchase,
  updatePaymentMethod,
}

/// Severidade de banner para UI
enum BannerSeverity { critical, warning, info }

/// Banner com conteúdo prioritário
class PriorityBanner {
  final String title;
  final String message;
  final BannerSeverity severity;
  final String? action;

  PriorityBanner({
    required this.title,
    required this.message,
    required this.severity,
    this.action,
  });

  /// Cor para UI baseada na severidade
  String get colorCode {
    switch (severity) {
      case BannerSeverity.critical:
        return '#DC2626'; // Vermelho
      case BannerSeverity.warning:
        return '#F59E0B'; // Âmbar
      case BannerSeverity.info:
        return '#3B82F6'; // Azul
    }
  }

  /// Icon para UI
  String get iconCode {
    switch (severity) {
      case BannerSeverity.critical:
        return '⚠️';
      case BannerSeverity.warning:
        return '⏰';
      case BannerSeverity.info:
        return 'ℹ️';
    }
  }
}

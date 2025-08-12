// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

/// Status detalhado da assinatura do usuário
class SubscriptionStatus {
  final bool isPremium;
  final bool isLoading;
  final String? error;
  final CustomerInfo? customerInfo;
  final DateTime? expirationDate;
  final DateTime? purchaseDate;
  final String? activeProductId;
  final bool willRenew;
  final bool isInGracePeriod;
  final bool isTestSubscription;

  const SubscriptionStatus({
    required this.isPremium,
    this.isLoading = false,
    this.error,
    this.customerInfo,
    this.expirationDate,
    this.purchaseDate,
    this.activeProductId,
    this.willRenew = false,
    this.isInGracePeriod = false,
    this.isTestSubscription = false,
  });

  /// Factory para estado inicial/loading
  factory SubscriptionStatus.loading() {
    return const SubscriptionStatus(
      isPremium: false,
      isLoading: true,
    );
  }

  /// Factory para estado de erro
  factory SubscriptionStatus.error(String errorMessage) {
    return SubscriptionStatus(
      isPremium: false,
      isLoading: false,
      error: errorMessage,
    );
  }

  /// Factory para usuário não premium
  factory SubscriptionStatus.free() {
    return const SubscriptionStatus(
      isPremium: false,
      isLoading: false,
    );
  }

  /// Factory para test subscription (desenvolvimento)
  factory SubscriptionStatus.testSubscription({
    required DateTime expirationDate,
  }) {
    return SubscriptionStatus(
      isPremium: true,
      isLoading: false,
      isTestSubscription: true,
      expirationDate: expirationDate,
      activeProductId: 'test_subscription',
      willRenew: false,
    );
  }

  /// Factory baseado em CustomerInfo do RevenueCat
  factory SubscriptionStatus.fromCustomerInfo(
    CustomerInfo customerInfo, {
    String entitlementId = 'gasometer_premium',
  }) {
    final entitlement = customerInfo.entitlements.active[entitlementId];
    final isPremium = entitlement != null && entitlement.isActive;

    return SubscriptionStatus(
      isPremium: isPremium,
      isLoading: false,
      customerInfo: customerInfo,
      expirationDate: entitlement?.expirationDate != null 
          ? DateTime.parse(entitlement!.expirationDate!) 
          : null,
      purchaseDate: entitlement?.latestPurchaseDate != null 
          ? DateTime.parse(entitlement!.latestPurchaseDate) 
          : null,
      activeProductId: entitlement?.productIdentifier,
      willRenew: entitlement?.willRenew ?? false,
      isInGracePeriod: entitlement?.periodType == PeriodType.trial,
    );
  }

  /// Cria uma cópia com novos valores
  SubscriptionStatus copyWith({
    bool? isPremium,
    bool? isLoading,
    String? error,
    CustomerInfo? customerInfo,
    DateTime? expirationDate,
    DateTime? purchaseDate,
    String? activeProductId,
    bool? willRenew,
    bool? isInGracePeriod,
    bool? isTestSubscription,
  }) {
    return SubscriptionStatus(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      customerInfo: customerInfo ?? this.customerInfo,
      expirationDate: expirationDate ?? this.expirationDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      activeProductId: activeProductId ?? this.activeProductId,
      willRenew: willRenew ?? this.willRenew,
      isInGracePeriod: isInGracePeriod ?? this.isInGracePeriod,
      isTestSubscription: isTestSubscription ?? this.isTestSubscription,
    );
  }

  /// Verifica se a assinatura está próxima do vencimento (7 dias)
  bool get isNearExpiration {
    if (expirationDate == null || !isPremium) return false;
    
    final daysUntilExpiration = expirationDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiration <= 7 && daysUntilExpiration > 0;
  }

  /// Verifica se a assinatura expirou
  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  /// Obtém os dias restantes da assinatura
  int get daysRemaining {
    if (expirationDate == null || !isPremium) return 0;
    
    final difference = expirationDate!.difference(DateTime.now());
    return difference.inDays.clamp(0, double.infinity).toInt();
  }

  /// Obtém uma descrição legível do status
  String get statusDescription {
    if (isLoading) return 'Verificando assinatura...';
    if (error != null) return 'Erro: $error';
    if (isTestSubscription) return 'Test Subscription Ativa';
    if (!isPremium) return 'Versão gratuita';
    
    if (isExpired) return 'Assinatura expirada';
    if (isNearExpiration) return 'Expira em $daysRemaining dias';
    if (willRenew) return 'Assinatura ativa (renovação automática)';
    
    return 'Assinatura ativa';
  }

  @override
  String toString() {
    return 'SubscriptionStatus(isPremium: $isPremium, '
           'activeProduct: $activeProductId, '
           'expiration: $expirationDate, '
           'status: $statusDescription)';
  }
}

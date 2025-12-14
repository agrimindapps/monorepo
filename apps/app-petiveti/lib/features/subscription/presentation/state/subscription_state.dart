import 'package:core/core.dart' hide Column, SubscriptionState, SubscriptionInfo;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_state.freezed.dart';

/// Estado da assinatura para o Petiveti
/// Usado pelo SubscriptionNotifier para gerenciar o estado reativo
@freezed
abstract class SubscriptionState with _$SubscriptionState {
  const SubscriptionState._();

  const factory SubscriptionState({
    @Default(false) bool isLoadingPlans,
    @Default(false) bool isLoadingCurrentSubscription,
    @Default(false) bool isProcessingPurchase,
    @Default(false) bool isRestoringPurchases,
    @Default([]) List<ProductInfo> availablePlans,
    PetivetiSubscriptionInfo? currentSubscription,
    String? errorMessage,
  }) = _SubscriptionState;

  /// Factory para estado inicial
  factory SubscriptionState.initial() => const SubscriptionState();

  /// Factory para estado de loading
  factory SubscriptionState.loading() => const SubscriptionState(
        isLoadingPlans: true,
        isLoadingCurrentSubscription: true,
      );

  // Computed properties

  /// Verifica se está carregando qualquer coisa
  bool get isLoading =>
      isLoadingPlans ||
      isLoadingCurrentSubscription ||
      isProcessingPurchase ||
      isRestoringPurchases;

  /// Verifica se está carregando ofertas (para compatibilidade)
  bool get isLoadingOfferings => isLoadingPlans;

  /// Lista de ofertas (alias para compatibilidade com UI existente)
  List<Offering> get offerings => [];

  /// Verifica se tem erro
  bool get hasError => errorMessage != null;

  /// Verifica se usuário é premium
  bool get isPremium => currentSubscription?.isPremium ?? false;

  /// Verifica se assinatura está ativa
  bool get isActive => currentSubscription?.isActive ?? false;

  /// Verifica se está em período de trial
  bool get isTrialActive => currentSubscription?.isTrialPeriod ?? false;

  /// Dias até expiração
  int get daysUntilExpiration => currentSubscription?.daysUntilExpiration ?? -1;

  /// Verifica se vai expirar em breve (7 dias)
  bool get willExpireSoon {
    final days = daysUntilExpiration;
    return days >= 0 && days <= 7;
  }

  /// Limpa o erro atual
  SubscriptionState clearError() => copyWith(errorMessage: null);
}

/// Informações de assinatura simplificadas (para UI) - específico do Petiveti
class PetivetiSubscriptionInfo {
  final String productId;
  final bool isPremium;
  final bool isTrialPeriod;
  final bool hasUsedTrial;
  final DateTime? purchaseDate;
  final DateTime? expirationDate;
  final String? originalTransactionId;
  final EntitlementInfo? entitlementInfo;

  const PetivetiSubscriptionInfo({
    required this.productId,
    required this.isPremium,
    this.isTrialPeriod = false,
    this.hasUsedTrial = false,
    this.purchaseDate,
    this.expirationDate,
    this.originalTransactionId,
    this.entitlementInfo,
  });

  bool get isActive =>
      isPremium && (expirationDate?.isAfter(DateTime.now()) ?? false);
  bool get isExpired => !isActive && expirationDate != null;

  int get daysUntilExpiration {
    if (expirationDate == null) return -1;
    return expirationDate!.difference(DateTime.now()).inDays;
  }

  /// Cria PetivetiSubscriptionInfo a partir de SubscriptionEntity do core
  factory PetivetiSubscriptionInfo.fromEntity(SubscriptionEntity entity) {
    return PetivetiSubscriptionInfo(
      productId: entity.productId,
      isPremium: entity.isActive,
      isTrialPeriod: entity.isTrialActive,
      hasUsedTrial: entity.trialEndDate != null,
      purchaseDate: entity.purchaseDate,
      expirationDate: entity.expirationDate,
      originalTransactionId: entity.id,
    );
  }
}

/// Classe placeholder para Offering (compatibilidade com UI)
class Offering {
  final String identifier;
  final List<Package> availablePackages;

  const Offering({
    required this.identifier,
    required this.availablePackages,
  });
}

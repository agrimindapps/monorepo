import 'base_entity.dart';

/// Entidade de assinatura compartilhada entre os apps
/// Representa o status de assinatura do usuário via RevenueCat
class SubscriptionEntity extends BaseEntity {
  const SubscriptionEntity({
    required super.id,
    required this.userId,
    required this.productId,
    required this.status,
    required this.tier,
    this.expirationDate,
    this.purchaseDate,
    this.originalPurchaseDate,
    this.renewalDate,
    this.trialEndDate,
    this.cancellationReason,
    this.store = Store.appStore,
    this.isInTrial = false,
    this.isSandbox = false,
    super.createdAt,
    super.updatedAt,
  });

  /// ID do usuário proprietário da assinatura
  final String userId;

  /// ID do produto da assinatura (Plantis/ReceitaAgro)
  final String productId;

  /// Status atual da assinatura
  final SubscriptionStatus status;

  /// Nível da assinatura (free, premium, pro)
  final SubscriptionTier tier;

  /// Data de expiração da assinatura
  final DateTime? expirationDate;

  /// Data da compra
  final DateTime? purchaseDate;

  /// Data da compra original (para renovações)
  final DateTime? originalPurchaseDate;

  /// Data da próxima renovação
  final DateTime? renewalDate;

  /// Data de fim do trial gratuito
  final DateTime? trialEndDate;

  /// Razão do cancelamento (se aplicável)
  final String? cancellationReason;

  /// Loja onde foi feita a compra
  final Store store;

  /// Se está em período de trial
  final bool isInTrial;

  /// Se é ambiente de sandbox/teste
  final bool isSandbox;

  /// Retorna true se a assinatura está ativa
  bool get isActive {
    if (status != SubscriptionStatus.active) return false;
    if (expirationDate == null) return true;
    return DateTime.now().isBefore(expirationDate!);
  }

  /// Retorna true se a assinatura está expirada
  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  /// Retorna true se está no período de grace
  bool get isInGracePeriod {
    return status == SubscriptionStatus.gracePeriod;
  }

  /// Retorna true se o trial está ativo
  bool get isTrialActive {
    if (!isInTrial || trialEndDate == null) return false;
    return DateTime.now().isBefore(trialEndDate!);
  }

  /// Dias restantes da assinatura
  int? get daysRemaining {
    if (expirationDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expirationDate!)) return 0;
    return expirationDate!.difference(now).inDays;
  }

  /// Se a assinatura é para o app Plantis
  bool get isPlantisSubscription {
    return productId.toLowerCase().contains('plantis');
  }

  /// Se a assinatura é para o app ReceitaAgro
  bool get isReceitaAgroSubscription {
    return productId.toLowerCase().contains('receituagro');
  }

  @override
  BaseEntity copyWith({
    String? id,
    String? userId,
    String? productId,
    SubscriptionStatus? status,
    SubscriptionTier? tier,
    DateTime? expirationDate,
    DateTime? purchaseDate,
    DateTime? originalPurchaseDate,
    DateTime? renewalDate,
    DateTime? trialEndDate,
    String? cancellationReason,
    Store? store,
    bool? isInTrial,
    bool? isSandbox,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      expirationDate: expirationDate ?? this.expirationDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      originalPurchaseDate: originalPurchaseDate ?? this.originalPurchaseDate,
      renewalDate: renewalDate ?? this.renewalDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      store: store ?? this.store,
      isInTrial: isInTrial ?? this.isInTrial,
      isSandbox: isSandbox ?? this.isSandbox,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        userId,
        productId,
        status,
        tier,
        expirationDate,
        purchaseDate,
        originalPurchaseDate,
        renewalDate,
        trialEndDate,
        cancellationReason,
        store,
        isInTrial,
        isSandbox,
      ];
}

/// Status da assinatura
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  gracePeriod,
  pending,
  unknown,
}

/// Níveis de assinatura
enum SubscriptionTier {
  free,
  premium,
  pro,
}

/// Lojas onde a compra pode ser feita
enum Store {
  appStore,
  playStore,
  stripe,
  promotional,
  unknown,
}

extension SubscriptionStatusExtension on SubscriptionStatus {
  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Ativo';
      case SubscriptionStatus.expired:
        return 'Expirado';
      case SubscriptionStatus.cancelled:
        return 'Cancelado';
      case SubscriptionStatus.gracePeriod:
        return 'Período de Graça';
      case SubscriptionStatus.pending:
        return 'Pendente';
      case SubscriptionStatus.unknown:
        return 'Desconhecido';
    }
  }

  bool get isActiveStatus => this == SubscriptionStatus.active;
}

extension SubscriptionTierExtension on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Gratuito';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.pro:
        return 'Pro';
    }
  }

  bool get isPaid => this != SubscriptionTier.free;
}

extension StoreExtension on Store {
  String get displayName {
    switch (this) {
      case Store.appStore:
        return 'App Store';
      case Store.playStore:
        return 'Play Store';
      case Store.stripe:
        return 'Stripe';
      case Store.promotional:
        return 'Promocional';
      case Store.unknown:
        return 'Desconhecido';
    }
  }
}
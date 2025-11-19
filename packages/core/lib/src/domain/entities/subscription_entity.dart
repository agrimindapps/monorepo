import 'base_sync_entity.dart';

/// Entidade de assinatura compartilhada entre os apps
/// Representa o status de assinatura do usuário via RevenueCat
class SubscriptionEntity extends BaseSyncEntity {
  const SubscriptionEntity({
    required super.id,
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
    this.isAutoRenewing = false,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    required super.userId,
    super.moduleName,
  });

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

  /// Se a renovação automática está ativa
  final bool isAutoRenewing;

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

  /// Check if subscription is expiring soon (within 7 days)
  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final remaining = expirationDate!.difference(DateTime.now());
    return remaining.inDays <= 7 && remaining.inDays > 0;
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
  SubscriptionEntity copyWith({
    String? id,
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
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
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
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
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

  /// Implementação dos métodos abstratos do BaseSyncEntity
  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'user_id': userId,
      'product_id': productId,
      'status': status.name,
      'tier': tier.name,
      'expiration_date': expirationDate?.toIso8601String(),
      'purchase_date': purchaseDate?.toIso8601String(),
      'original_purchase_date': originalPurchaseDate?.toIso8601String(),
      'renewal_date': renewalDate?.toIso8601String(),
      'trial_end_date': trialEndDate?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'store': store.name,
      'is_in_trial': isInTrial,
      'is_sandbox': isSandbox,
    };
  }

  /// Create SubscriptionEntity from Firebase map
  static SubscriptionEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

    return SubscriptionEntity(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String? ?? map['user_id'] as String,
      moduleName: baseFields['moduleName'] as String?,
      productId: map['product_id'] as String,
      status: SubscriptionStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String),
        orElse: () => SubscriptionStatus.unknown,
      ),
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == (map['tier'] as String),
        orElse: () => SubscriptionTier.free,
      ),
      expirationDate: map['expiration_date'] != null
          ? DateTime.parse(map['expiration_date'] as String)
          : null,
      purchaseDate: map['purchase_date'] != null
          ? DateTime.parse(map['purchase_date'] as String)
          : null,
      originalPurchaseDate: map['original_purchase_date'] != null
          ? DateTime.parse(map['original_purchase_date'] as String)
          : null,
      renewalDate: map['renewal_date'] != null
          ? DateTime.parse(map['renewal_date'] as String)
          : null,
      trialEndDate: map['trial_end_date'] != null
          ? DateTime.parse(map['trial_end_date'] as String)
          : null,
      cancellationReason: map['cancellation_reason'] as String?,
      store: Store.values.firstWhere(
        (s) => s.name == (map['store'] as String),
        orElse: () => Store.unknown,
      ),
      isInTrial: map['is_in_trial'] as bool? ?? false,
      isSandbox: map['is_sandbox'] as bool? ?? false,
    );
  }

  @override
  SubscriptionEntity markAsDirty() {
    return copyWith(isDirty: true, updatedAt: DateTime.now());
  }

  @override
  SubscriptionEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(isDirty: false, lastSyncAt: syncTime ?? DateTime.now());
  }

  @override
  SubscriptionEntity markAsDeleted() {
    return copyWith(isDeleted: true, isDirty: true, updatedAt: DateTime.now());
  }

  @override
  SubscriptionEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  SubscriptionEntity withUserId(String userId) {
    return copyWith(userId: userId, isDirty: true, updatedAt: DateTime.now());
  }

  @override
  SubscriptionEntity withModule(String moduleName) {
    return copyWith(
      moduleName: moduleName,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }
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

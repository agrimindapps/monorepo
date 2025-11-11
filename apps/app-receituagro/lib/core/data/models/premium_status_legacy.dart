import 'package:core/core.dart' hide Column;

// part 'premium_status_hive.g.dart';

@HiveType(typeId: 111)
class PremiumStatusHive extends HiveObject {
  @HiveField(0)
  String? sync_objectId;

  @HiveField(1)
  int? sync_createdAt;

  @HiveField(2)
  int? sync_updatedAt;

  @HiveField(3)
  String userId;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  bool isTestSubscription;

  @HiveField(6)
  int? expiryDateTimestamp;

  @HiveField(7)
  String? planType;

  @HiveField(8)
  String? subscriptionId;

  @HiveField(9)
  String? productId;

  @HiveField(10)
  int? sync_lastSyncTimestamp;

  @HiveField(11)
  bool sync_needsOnlineSync;

  PremiumStatusHive({
    this.sync_objectId,
    this.sync_createdAt,
    this.sync_updatedAt,
    required this.userId,
    required this.isActive,
    this.isTestSubscription = false,
    this.expiryDateTimestamp,
    this.planType,
    this.subscriptionId,
    this.productId,
    this.sync_lastSyncTimestamp,
    this.sync_needsOnlineSync = true,
  });

  /// Converte timestamp para DateTime
  DateTime? get expiryDate => expiryDateTimestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(expiryDateTimestamp!)
      : null;

  /// Define data de expiração
  set expiryDate(DateTime? date) {
    expiryDateTimestamp = date?.millisecondsSinceEpoch;
  }

  /// Data da última sincronização
  DateTime? get lastSync => sync_lastSyncTimestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(sync_lastSyncTimestamp!)
      : null;

  /// Define data da última sincronização
  set lastSync(DateTime? date) {
    sync_lastSyncTimestamp = date?.millisecondsSinceEpoch;
  }

  /// Verifica se o premium está válido (não expirado)
  bool get isValidPremium {
    if (!isActive) return false;
    if (expiryDate == null) return true; // Premium sem expiração
    return DateTime.now().isBefore(expiryDate!);
  }

  /// Verifica se precisa sincronizar (dados antigos > 1 hora)
  bool get shouldSyncOnline {
    if (sync_needsOnlineSync) return true;
    if (lastSync == null) return true;

    final hoursSinceSync = DateTime.now().difference(lastSync!).inHours;
    return hoursSinceSync >= 1; // Sincronizar a cada hora
  }

  /// Marca como sincronizado
  void markAsSynced() {
    lastSync = DateTime.now();
    sync_needsOnlineSync = false;
  }

  /// Marca como necessitando sincronização
  void markNeedsSync() {
    sync_needsOnlineSync = true;
  }

  /// Factory para criar a partir de dados do RevenueCat/Core
  factory PremiumStatusHive.fromSubscriptionEntity(
    String userId,
    dynamic subscriptionEntity,
  ) {
    return PremiumStatusHive(
      userId: userId,
      isActive: (subscriptionEntity?.isActive as bool?) ?? false,
      expiryDateTimestamp:
          subscriptionEntity?.expiryDate?.millisecondsSinceEpoch as int?,
      planType: subscriptionEntity?.planType as String?,
      subscriptionId: subscriptionEntity?.id as String?,
      productId: subscriptionEntity?.productId as String?,
      sync_createdAt: DateTime.now().millisecondsSinceEpoch,
      sync_updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Copia com novos valores
  PremiumStatusHive copyWith({
    String? sync_objectId,
    int? sync_createdAt,
    int? sync_updatedAt,
    String? userId,
    bool? isActive,
    bool? isTestSubscription,
    int? expiryDateTimestamp,
    String? planType,
    String? subscriptionId,
    String? productId,
    int? sync_lastSyncTimestamp,
    bool? sync_needsOnlineSync,
  }) {
    return PremiumStatusHive(
      sync_objectId: sync_objectId ?? this.sync_objectId,
      sync_createdAt: sync_createdAt ?? this.sync_createdAt,
      sync_updatedAt: sync_updatedAt ?? this.sync_updatedAt,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      isTestSubscription: isTestSubscription ?? this.isTestSubscription,
      expiryDateTimestamp: expiryDateTimestamp ?? this.expiryDateTimestamp,
      planType: planType ?? this.planType,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      productId: productId ?? this.productId,
      sync_lastSyncTimestamp:
          sync_lastSyncTimestamp ?? this.sync_lastSyncTimestamp,
      sync_needsOnlineSync: sync_needsOnlineSync ?? this.sync_needsOnlineSync,
    );
  }

  @override
  String toString() {
    return 'PremiumStatusHive(userId: $userId, isActive: $isActive, isValidPremium: $isValidPremium, planType: $planType, expiryDate: $expiryDate)';
  }
}

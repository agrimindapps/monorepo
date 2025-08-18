import 'package:hive/hive.dart';

part 'premium_status_hive.g.dart';

@HiveType(typeId: 111)
class PremiumStatusHive extends HiveObject {
  @HiveField(0)
  String? objectId;

  @HiveField(1)
  int? createdAt;

  @HiveField(2)
  int? updatedAt;

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
  int? lastSyncTimestamp;

  @HiveField(11)
  bool needsOnlineSync;

  PremiumStatusHive({
    this.objectId,
    this.createdAt,
    this.updatedAt,
    required this.userId,
    required this.isActive,
    this.isTestSubscription = false,
    this.expiryDateTimestamp,
    this.planType,
    this.subscriptionId,
    this.productId,
    this.lastSyncTimestamp,
    this.needsOnlineSync = true,
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
  DateTime? get lastSync => lastSyncTimestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp!)
      : null;

  /// Define data da última sincronização  
  set lastSync(DateTime? date) {
    lastSyncTimestamp = date?.millisecondsSinceEpoch;
  }

  /// Verifica se o premium está válido (não expirado)
  bool get isValidPremium {
    if (!isActive) return false;
    if (expiryDate == null) return true; // Premium sem expiração
    return DateTime.now().isBefore(expiryDate!);
  }

  /// Verifica se precisa sincronizar (dados antigos > 1 hora)
  bool get shouldSyncOnline {
    if (needsOnlineSync) return true;
    if (lastSync == null) return true;
    
    final hoursSinceSync = DateTime.now().difference(lastSync!).inHours;
    return hoursSinceSync >= 1; // Sincronizar a cada hora
  }

  /// Marca como sincronizado
  void markAsSynced() {
    lastSync = DateTime.now();
    needsOnlineSync = false;
  }

  /// Marca como necessitando sincronização
  void markNeedsSync() {
    needsOnlineSync = true;
  }

  /// Factory para criar a partir de dados do RevenueCat/Core
  factory PremiumStatusHive.fromSubscriptionEntity(
    String userId,
    dynamic subscriptionEntity,
  ) {
    // Adaptar conforme estrutura real do SubscriptionEntity
    return PremiumStatusHive(
      userId: userId,
      isActive: subscriptionEntity?.isActive ?? false,
      expiryDateTimestamp: subscriptionEntity?.expiryDate?.millisecondsSinceEpoch,
      planType: subscriptionEntity?.planType,
      subscriptionId: subscriptionEntity?.id,
      productId: subscriptionEntity?.productId,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Copia com novos valores
  PremiumStatusHive copyWith({
    String? objectId,
    int? createdAt,
    int? updatedAt,
    String? userId,
    bool? isActive,
    bool? isTestSubscription,
    int? expiryDateTimestamp,
    String? planType,
    String? subscriptionId,
    String? productId,
    int? lastSyncTimestamp,
    bool? needsOnlineSync,
  }) {
    return PremiumStatusHive(
      objectId: objectId ?? this.objectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      isTestSubscription: isTestSubscription ?? this.isTestSubscription,
      expiryDateTimestamp: expiryDateTimestamp ?? this.expiryDateTimestamp,
      planType: planType ?? this.planType,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      productId: productId ?? this.productId,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      needsOnlineSync: needsOnlineSync ?? this.needsOnlineSync,
    );
  }

  @override
  String toString() {
    return 'PremiumStatusHive(userId: $userId, isActive: $isActive, isValidPremium: $isValidPremium, planType: $planType, expiryDate: $expiryDate)';
  }
}
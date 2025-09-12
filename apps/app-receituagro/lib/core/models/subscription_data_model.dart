import 'package:hive/hive.dart';

part 'subscription_data_model.g.dart';

@HiveType(typeId: 21)
class SubscriptionDataModel extends HiveObject {
  @HiveField(0)
  final String status; // 'active', 'expired', 'trial', 'cancelled'
  
  @HiveField(1)
  final String? productId;
  
  @HiveField(2)
  final String platform; // 'ios', 'android', 'web'
  
  @HiveField(3)
  final DateTime? purchasedAt;
  
  @HiveField(4)
  final DateTime? expiresAt;
  
  @HiveField(5)
  final List<String> features; // ['unlimited_favorites', 'sync_data', etc]
  
  @HiveField(6)
  final Map<String, dynamic> metadata;
  
  @HiveField(7)
  final String? userId;
  
  @HiveField(8)
  final bool synchronized;
  
  @HiveField(9)
  final DateTime? syncedAt;
  
  @HiveField(10)
  final DateTime createdAt;
  
  @HiveField(11)
  final DateTime? updatedAt;

  SubscriptionDataModel({
    this.status = 'expired',
    this.productId,
    this.platform = 'unknown',
    this.purchasedAt,
    this.expiresAt,
    this.features = const [],
    this.metadata = const {},
    this.userId,
    this.synchronized = false,
    this.syncedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionDataModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionDataModel(
      status: map['status']?.toString() ?? 'expired',
      productId: map['productId']?.toString(),
      platform: map['platform']?.toString() ?? 'unknown',
      purchasedAt: map['purchasedAt'] != null
          ? DateTime.tryParse(map['purchasedAt'].toString())
          : null,
      expiresAt: map['expiresAt'] != null
          ? DateTime.tryParse(map['expiresAt'].toString())
          : null,
      features: map['features'] != null 
          ? List<String>.from(map['features'] as List)
          : const [],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : const {},
      userId: map['userId']?.toString(),
      synchronized: map['synchronized'] == true,
      syncedAt: map['syncedAt'] != null
          ? DateTime.tryParse(map['syncedAt'].toString())
          : null,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'productId': productId,
      'platform': platform,
      'purchasedAt': purchasedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'features': features,
      'metadata': metadata,
      'userId': userId,
      'synchronized': synchronized,
      'syncedAt': syncedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get isActive {
    if (status != 'active') return false;
    if (expiresAt == null) return false;
    return expiresAt!.isAfter(DateTime.now());
  }

  bool get isTrial {
    return status == 'trial' && (expiresAt?.isAfter(DateTime.now()) ?? false);
  }

  bool get isExpired {
    return status == 'expired' || 
           (expiresAt != null && expiresAt!.isBefore(DateTime.now()));
  }

  bool hasFeature(String feature) {
    return (isActive || isTrial) && features.contains(feature);
  }

  Duration? get timeRemaining {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (expiresAt!.isBefore(now)) return null;
    return expiresAt!.difference(now);
  }

  SubscriptionDataModel copyWith({
    String? status,
    String? productId,
    String? platform,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    List<String>? features,
    Map<String, dynamic>? metadata,
    String? userId,
    bool? synchronized,
    DateTime? syncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionDataModel(
      status: status ?? this.status,
      productId: productId ?? this.productId,
      platform: platform ?? this.platform,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      features: features ?? this.features,
      metadata: metadata ?? this.metadata,
      userId: userId ?? this.userId,
      synchronized: synchronized ?? this.synchronized,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  SubscriptionDataModel markAsUnsynchronized() {
    return copyWith(
      synchronized: false,
      updatedAt: DateTime.now(),
    );
  }

  SubscriptionDataModel markAsSynchronized() {
    return copyWith(
      synchronized: true,
      syncedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionDataModel &&
        other.userId == userId &&
        other.status == status &&
        other.productId == productId &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return Object.hash(userId, status, productId, expiresAt);
  }

  @override
  String toString() {
    return 'SubscriptionDataModel('
        'userId: $userId, '
        'status: $status, '
        'productId: $productId, '
        'expires: ${expiresAt?.toIso8601String()}, '
        'synchronized: $synchronized'
        ')';
  }
}
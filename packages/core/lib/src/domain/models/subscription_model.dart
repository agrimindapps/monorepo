// TEMPORARY STUB FILE TO RESOLVE BUILD ERRORS
// This is a stub version of the subscription model
// Will be replaced with proper implementation later

import '../entities/base_sync_entity.dart';

/// Stub implementation of the subscription model
/// This prevents compilation errors while the full model is being developed
class SubscriptionModel extends BaseSyncEntity {
  final String userId;
  final String productId;
  final String status;
  final DateTime? expiresAt;

  const SubscriptionModel({
    required super.id,
    required this.userId,
    required this.productId,
    required this.status,
    this.expiresAt,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDeleted,
  });

  /// Check if subscription is active
  bool get isActive {
    if (status != 'active') return false;
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Convert to map - stub implementation
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'status': status,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// Create from map - stub implementation
  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      productId: map['productId'] as String,
      status: map['status'] as String,
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      lastSyncAt: map['lastSyncAt'] != null
          ? DateTime.parse(map['lastSyncAt'] as String)
          : null,
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  /// Copy with new values
  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? productId,
    String? status,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDeleted,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
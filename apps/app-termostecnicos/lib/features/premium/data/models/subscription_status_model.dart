import '../../domain/entities/subscription_status.dart';

/// Data model for SubscriptionStatus
/// Extends domain entity and adds serialization capabilities
class SubscriptionStatusModel extends SubscriptionStatus {
  const SubscriptionStatusModel({
    super.isPremium,
    super.subscriptionType,
    super.expirationDate,
    super.startDate,
    super.isActive,
  });

  /// Create from domain entity
  factory SubscriptionStatusModel.fromEntity(SubscriptionStatus status) {
    return SubscriptionStatusModel(
      isPremium: status.isPremium,
      subscriptionType: status.subscriptionType,
      expirationDate: status.expirationDate,
      startDate: status.startDate,
      isActive: status.isActive,
    );
  }

  /// Create from JSON map
  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatusModel(
      isPremium: json['isPremium'] as bool? ?? false,
      subscriptionType: json['subscriptionType'] as String?,
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'isPremium': isPremium,
      'subscriptionType': subscriptionType,
      'expirationDate': expirationDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Convert to domain entity
  SubscriptionStatus toEntity() {
    return SubscriptionStatus(
      isPremium: isPremium,
      subscriptionType: subscriptionType,
      expirationDate: expirationDate,
      startDate: startDate,
      isActive: isActive,
    );
  }

  @override
  SubscriptionStatusModel copyWith({
    bool? isPremium,
    String? subscriptionType,
    DateTime? expirationDate,
    DateTime? startDate,
    bool? isActive,
  }) {
    return SubscriptionStatusModel(
      isPremium: isPremium ?? this.isPremium,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      expirationDate: expirationDate ?? this.expirationDate,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

import 'package:equatable/equatable.dart';

/// Domain entity representing subscription status
/// Immutable and contains only business logic
class SubscriptionStatus extends Equatable {
  final bool isPremium;
  final String? subscriptionType;
  final DateTime? expirationDate;
  final DateTime? startDate;
  final bool isActive;

  const SubscriptionStatus({
    this.isPremium = false,
    this.subscriptionType,
    this.expirationDate,
    this.startDate,
    this.isActive = false,
  });

  /// Calculate days remaining until expiration
  int? get daysRemaining {
    if (expirationDate == null) return null;
    final now = DateTime.now();
    return expirationDate!.difference(now).inDays;
  }

  /// Calculate percentage of subscription period elapsed
  double get percentElapsed {
    if (startDate == null || expirationDate == null) return 0.0;
    final now = DateTime.now();
    final total = expirationDate!.difference(startDate!).inDays;
    final elapsed = now.difference(startDate!).inDays;
    if (total == 0) return 100.0;
    return (elapsed / total * 100).clamp(0.0, 100.0);
  }

  /// Check if subscription is about to expire (less than 7 days)
  bool get isAboutToExpire {
    final days = daysRemaining;
    return days != null && days > 0 && days <= 7;
  }

  /// Create a copy of this SubscriptionStatus with modified fields
  SubscriptionStatus copyWith({
    bool? isPremium,
    String? subscriptionType,
    DateTime? expirationDate,
    DateTime? startDate,
    bool? isActive,
  }) {
    return SubscriptionStatus(
      isPremium: isPremium ?? this.isPremium,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      expirationDate: expirationDate ?? this.expirationDate,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        isPremium,
        subscriptionType,
        expirationDate,
        startDate,
        isActive,
      ];

  @override
  bool get stringify => true;
}

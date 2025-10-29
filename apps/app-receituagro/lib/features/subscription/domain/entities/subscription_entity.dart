import 'enums/store.dart';
import 'enums/subscription_status.dart';
import 'enums/subscription_tier.dart';

/// Base subscription entity
/// Represents the core subscription information for a user
class SubscriptionEntity {
  final String id;
  final String productId;
  final SubscriptionStatus status;
  final SubscriptionTier tier;
  final DateTime? expirationDate;
  final DateTime? renewalDate;
  final Store store;
  final bool isAutoRenewing;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionEntity({
    required this.id,
    required this.productId,
    required this.status,
    required this.tier,
    this.expirationDate,
    this.renewalDate,
    required this.store,
    required this.isAutoRenewing,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor for default/initial state
  factory SubscriptionEntity.initial() {
    final now = DateTime.now();
    return SubscriptionEntity(
      id: 'subscription-${now.millisecondsSinceEpoch}',
      productId: '',
      status: SubscriptionStatus.unknown,
      tier: SubscriptionTier.free,
      expirationDate: null,
      renewalDate: null,
      store: Store.unknown,
      isAutoRenewing: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy with modified fields
  SubscriptionEntity copyWith({
    String? id,
    String? productId,
    SubscriptionStatus? status,
    SubscriptionTier? tier,
    DateTime? expirationDate,
    DateTime? renewalDate,
    Store? store,
    bool? isAutoRenewing,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      expirationDate: expirationDate ?? this.expirationDate,
      renewalDate: renewalDate ?? this.renewalDate,
      store: store ?? this.store,
      isAutoRenewing: isAutoRenewing ?? this.isAutoRenewing,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if subscription is currently active
  bool get isActive => status == SubscriptionStatus.active;

  /// Check if subscription has expired
  bool get isExpired => status == SubscriptionStatus.expired;

  /// Check if subscription is cancelled
  bool get isCancelled => status == SubscriptionStatus.cancelled;

  /// Get time remaining until expiration
  Duration? get timeUntilExpiry {
    if (expirationDate == null) return null;
    final remaining = expirationDate!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  /// Check if subscription is expiring soon (within 7 days)
  bool get isExpiringSoon {
    final remaining = timeUntilExpiry;
    if (remaining == null) return false;
    return remaining.inDays <= 7 && remaining.inDays > 0;
  }

  /// Check if subscription is expiring very soon (within 3 days)
  bool get isExpiredSoon {
    final remaining = timeUntilExpiry;
    if (remaining == null) return false;
    return remaining.inDays <= 3 && remaining.inDays > 0;
  }

  /// Get percentage of subscription used (0-100)
  double get percentageExpired {
    if (expirationDate == null) return 0.0;
    final total = expirationDate!.difference(createdAt).inDays;
    if (total <= 0) return 0.0;
    final used = DateTime.now().difference(createdAt).inDays;
    return ((used / total) * 100).clamp(0.0, 100.0);
  }

  /// Check if subscription can be renewed
  bool get isRenewable {
    return isActive && isAutoRenewing && expirationDate != null;
  }

  /// Check if subscription is in grace period
  bool get isInGracePeriod {
    if (!isExpired || expirationDate == null) return false;
    final gracePeriod = expirationDate!.add(const Duration(days: 14));
    return DateTime.now().isBefore(gracePeriod);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productId == other.productId &&
          status == other.status &&
          tier == other.tier &&
          expirationDate == other.expirationDate &&
          renewalDate == other.renewalDate &&
          store == other.store &&
          isAutoRenewing == other.isAutoRenewing &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      productId.hashCode ^
      status.hashCode ^
      tier.hashCode ^
      expirationDate.hashCode ^
      renewalDate.hashCode ^
      store.hashCode ^
      isAutoRenewing.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return '''SubscriptionEntity(
      id: $id,
      productId: $productId,
      status: ${status.displayName},
      tier: ${tier.displayName},
      expirationDate: $expirationDate,
      renewalDate: $renewalDate,
      store: ${store.displayName},
      isAutoRenewing: $isAutoRenewing,
      isActive: $isActive,
      isExpiringSoon: $isExpiringSoon,
      timeUntilExpiry: $timeUntilExpiry,
    )''';
  }
}

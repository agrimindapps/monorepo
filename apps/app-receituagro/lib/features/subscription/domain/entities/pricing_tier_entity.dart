import 'enums/subscription_tier.dart';

/// Pricing tier entity
/// Represents available subscription plans and their pricing
class PricingTierEntity {
  final String id;
  final SubscriptionTier tier;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final int trialDays;
  final bool isCurrentTier;
  final String currency;
  final DateTime lastUpdated;

  const PricingTierEntity({
    required this.id,
    required this.tier,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.trialDays,
    required this.isCurrentTier,
    required this.currency,
    required this.lastUpdated,
  });

  /// Factory constructor for default/initial state
  factory PricingTierEntity.initial(SubscriptionTier tier) {
    return PricingTierEntity(
      id: 'tier-${tier.name}',
      tier: tier,
      name: tier.displayName,
      description: '',
      monthlyPrice: 0.0,
      yearlyPrice: 0.0,
      features: const [],
      trialDays: 0,
      isCurrentTier: false,
      currency: 'BRL',
      lastUpdated: DateTime.now(),
    );
  }

  /// Create a copy with modified fields
  PricingTierEntity copyWith({
    String? id,
    SubscriptionTier? tier,
    String? name,
    String? description,
    double? monthlyPrice,
    double? yearlyPrice,
    List<String>? features,
    int? trialDays,
    bool? isCurrentTier,
    String? currency,
    DateTime? lastUpdated,
  }) {
    return PricingTierEntity(
      id: id ?? this.id,
      tier: tier ?? this.tier,
      name: name ?? this.name,
      description: description ?? this.description,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      features: features ?? this.features,
      trialDays: trialDays ?? this.trialDays,
      isCurrentTier: isCurrentTier ?? this.isCurrentTier,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if tier has monthly option
  bool get hasMonthlyOption => monthlyPrice > 0;

  /// Check if tier has yearly option
  bool get hasYearlyOption => yearlyPrice > 0;

  /// Get monthly price formatted
  String get formattedMonthlyPrice {
    if (!hasMonthlyOption) return 'N/A';
    return 'R\$ ${monthlyPrice.toStringAsFixed(2)}/mês';
  }

  /// Get yearly price formatted
  String get formattedYearlyPrice {
    if (!hasYearlyOption) return 'N/A';
    return 'R\$ ${yearlyPrice.toStringAsFixed(2)}/ano';
  }

  /// Get annual savings if buying yearly
  double get annualSavings {
    if (!hasMonthlyOption || !hasYearlyOption) return 0.0;
    final monthlyTotal = monthlyPrice * 12;
    return (monthlyTotal - yearlyPrice).clamp(0.0, double.infinity);
  }

  /// Get annual savings percentage
  double get annualSavingsPercentage {
    if (annualSavings <= 0) return 0.0;
    final monthlyTotal = monthlyPrice * 12;
    return ((annualSavings / monthlyTotal) * 100).clamp(0.0, 100.0);
  }

  /// Check if this tier is better value than another
  bool isBetterValueThan(PricingTierEntity other) {
    if (!hasYearlyOption || !other.hasYearlyOption) return false;
    return (yearlyPrice / 12) < (other.yearlyPrice / 12);
  }

  /// Check if tier has a specific feature
  bool hasFeature(String featureName) {
    return features.any((f) => f.toLowerCase() == featureName.toLowerCase());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PricingTierEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tier == other.tier &&
          name == other.name &&
          monthlyPrice == other.monthlyPrice &&
          yearlyPrice == other.yearlyPrice &&
          features == other.features &&
          isCurrentTier == other.isCurrentTier;

  @override
  int get hashCode =>
      id.hashCode ^
      tier.hashCode ^
      name.hashCode ^
      monthlyPrice.hashCode ^
      yearlyPrice.hashCode ^
      features.hashCode ^
      isCurrentTier.hashCode;

  @override
  String toString() {
    return '''PricingTierEntity(
      id: $id,
      tier: ${tier.displayName},
      name: $name,
      monthlyPrice: R\$ $monthlyPrice,
      yearlyPrice: R\$ $yearlyPrice,
      features: ${features.length},
      annualSavings: R\$ ${annualSavings.toStringAsFixed(2)} (${annualSavingsPercentage.toStringAsFixed(0)}%),
      isCurrentTier: $isCurrentTier,
    )''';
  }
}

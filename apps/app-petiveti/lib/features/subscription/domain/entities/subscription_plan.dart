import 'package:equatable/equatable.dart';

enum PlanType {
  free,
  monthly,
  yearly,
  lifetime,
}

extension PlanTypeExtension on PlanType {
  String get displayName {
    switch (this) {
      case PlanType.free:
        return 'Gratuito';
      case PlanType.monthly:
        return 'Mensal';
      case PlanType.yearly:
        return 'Anual';
      case PlanType.lifetime:
        return 'Vitalício';
    }
  }
}

enum PlanStatus {
  active,
  expired,
  cancelled,
  paused,
  pending,
}

// Alias for backward compatibility
typedef SubscriptionStatus = PlanStatus;

enum PlanDuration {
  weekly,
  monthly,
  yearly,
  lifetime,
}

class SubscriptionPlan extends Equatable {
  final String id;
  final String productId;
  final String title;
  final String description;
  final double price;
  final String currency;
  final PlanType type;
  final int? durationInDays;
  final List<String> features;
  final bool isPopular;
  final double? originalPrice;
  final int? trialDays;
  final Map<String, dynamic>? metadata;

  const SubscriptionPlan({
    required this.id,
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.type,
    this.durationInDays,
    required this.features,
    this.isPopular = false,
    this.originalPrice,
    this.trialDays,
    this.metadata,
  });

  SubscriptionPlan copyWith({
    String? id,
    String? productId,
    String? title,
    String? description,
    double? price,
    String? currency,
    PlanType? type,
    int? durationInDays,
    List<String>? features,
    bool? isPopular,
    double? originalPrice,
    int? trialDays,
    Map<String, dynamic>? metadata,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      durationInDays: durationInDays ?? this.durationInDays,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
      originalPrice: originalPrice ?? this.originalPrice,
      trialDays: trialDays ?? this.trialDays,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isFree => type == PlanType.free;
  bool get hasTrial => trialDays != null && trialDays! > 0;
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  String get formattedPrice {
    if (isFree) return 'Grátis';
    return '$currency ${price.toStringAsFixed(2)}';
  }

  String get billingPeriod {
    switch (type) {
      case PlanType.free:
        return 'Grátis';
      case PlanType.monthly:
        return 'por mês';
      case PlanType.yearly:
        return 'por ano';
      case PlanType.lifetime:
        return 'pagamento único';
    }
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        title,
        description,
        price,
        currency,
        type,
        durationInDays,
        features,
        isPopular,
        originalPrice,
        trialDays,
        metadata,
      ];
}
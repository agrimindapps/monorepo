import '../../domain/entities/subscription_plan.dart';

class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.productId,
    required super.title,
    required super.description,
    required super.price,
    required super.currency,
    required super.type,
    super.durationInDays,
    required super.features,
    super.isPopular,
    super.originalPrice,
    super.trialDays,
    super.metadata,
  });

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlanModel(
      id: map['id']?.toString() ?? '',
      productId: map['productId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: ((map['price'] ?? 0) as num).toDouble(),
      currency: map['currency']?.toString() ?? 'R\$',
      type: PlanType.values.firstWhere(
        (e) => e.toString() == 'PlanType.${map['type']}',
        orElse: () => PlanType.free,
      ),
      durationInDays: (map['durationInDays'] as int?),
      features: map['features'] != null 
          ? List<String>.from(map['features'] as Iterable)
          : [],
      isPopular: (map['isPopular'] as bool?) ?? false,
      originalPrice: ((map['originalPrice']) as num?)?.toDouble(),
      trialDays: (map['trialDays'] as int?),
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'type': type.toString().split('.').last,
      'durationInDays': durationInDays,
      'features': features,
      'isPopular': isPopular,
      'originalPrice': originalPrice,
      'trialDays': trialDays,
      'metadata': metadata,
    };
  }

  factory SubscriptionPlanModel.fromEntity(SubscriptionPlan plan) {
    return SubscriptionPlanModel(
      id: plan.id,
      productId: plan.productId,
      title: plan.title,
      description: plan.description,
      price: plan.price,
      currency: plan.currency,
      type: plan.type,
      durationInDays: plan.durationInDays,
      features: plan.features,
      isPopular: plan.isPopular,
      originalPrice: plan.originalPrice,
      trialDays: plan.trialDays,
      metadata: plan.metadata,
    );
  }

  @override
  SubscriptionPlanModel copyWith({
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
    return SubscriptionPlanModel(
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
}
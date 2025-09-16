import 'package:app_agrihurbi/features/subscription/domain/entities/subscription_entity.dart';
import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

/// Subscription Model with Hive Serialization
/// 
/// Represents user subscription status and premium features access
@HiveType(typeId: 16)
class SubscriptionModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final SubscriptionTierModel tier;
  
  @HiveField(3)
  final SubscriptionStatusModel status;
  
  @HiveField(4)
  final DateTime startDate;
  
  @HiveField(5)
  final DateTime? endDate;
  
  @HiveField(6)
  final DateTime? nextBillingDate;
  
  @HiveField(7)
  final double price;
  
  @HiveField(8)
  final String currency;
  
  @HiveField(9)
  final BillingPeriodModel billingPeriod;
  
  @HiveField(10)
  final List<PremiumFeatureModel> features;
  
  @HiveField(11)
  final PaymentMethodModel? paymentMethod;
  
  @HiveField(12)
  final bool autoRenew;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.tier,
    required this.status,
    required this.startDate,
    this.endDate,
    this.nextBillingDate,
    required this.price,
    required this.currency,
    required this.billingPeriod,
    required this.features,
    this.paymentMethod,
    this.autoRenew = true,
  });
  
  /// Convert to domain entity
  SubscriptionEntity toEntity() {
    return SubscriptionEntity(
      id: id,
      userId: userId,
      tier: tier.toEntity(),
      status: status.toEntity(),
      startDate: startDate,
      endDate: endDate,
      nextBillingDate: nextBillingDate,
      price: price,
      currency: currency,
      billingPeriod: billingPeriod.toEntity(),
      features: features.map((f) => f.toEntity()).toList(),
      paymentMethod: paymentMethod?.toEntity(),
      autoRenew: autoRenew,
    );
  }

  /// Create from Entity
  factory SubscriptionModel.fromEntity(SubscriptionEntity entity) {
    return SubscriptionModel(
      id: entity.id,
      userId: entity.userId,
      tier: SubscriptionTierModel.fromEntity(entity.tier),
      status: SubscriptionStatusModel.fromEntity(entity.status),
      startDate: entity.startDate,
      endDate: entity.endDate,
      nextBillingDate: entity.nextBillingDate,
      price: entity.price,
      currency: entity.currency,
      billingPeriod: BillingPeriodModel.fromEntity(entity.billingPeriod),
      features: entity.features.map((f) => PremiumFeatureModel.fromEntity(f)).toList(),
      paymentMethod: entity.paymentMethod != null 
          ? PaymentMethodModel.fromEntity(entity.paymentMethod!)
          : null,
      autoRenew: entity.autoRenew,
    );
  }

  /// Create from JSON
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      tier: SubscriptionTierModel.fromString(json['tier'] as String? ?? 'free'),
      status: SubscriptionStatusModel.fromString(json['status'] as String? ?? 'inactive'),
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String? ?? '') : null,
      nextBillingDate: json['nextBillingDate'] != null 
          ? DateTime.tryParse(json['nextBillingDate'] as String? ?? '') : null,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'BRL',
      billingPeriod: BillingPeriodModel.fromString(json['billingPeriod'] as String? ?? 'monthly'),
      features: (json['features'] as List<dynamic>?)
              ?.map((f) => PremiumFeatureModel.fromString(f as String))
              .toList() ?? [],
      paymentMethod: json['paymentMethod'] != null 
          ? PaymentMethodModel.fromJson(json['paymentMethod'] as Map<String, dynamic>) 
          : null,
      autoRenew: json['autoRenew'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tier': tier.name,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'price': price,
      'currency': currency,
      'billingPeriod': billingPeriod.name,
      'features': features.map((f) => f.name).toList(),
      'paymentMethod': paymentMethod?.toJson(),
      'autoRenew': autoRenew,
    };
  }
}

/// Subscription Tier Model with Hive Serialization
@HiveType(typeId: 17)
enum SubscriptionTierModel {
  @HiveField(0)
  free,
  
  @HiveField(1)
  basic,
  
  @HiveField(2)
  premium,
  
  @HiveField(3)
  professional;

  /// Convert to domain entity
  SubscriptionTier toEntity() {
    switch (this) {
      case SubscriptionTierModel.free:
        return SubscriptionTier.free;
      case SubscriptionTierModel.basic:
        return SubscriptionTier.basic;
      case SubscriptionTierModel.premium:
        return SubscriptionTier.premium;
      case SubscriptionTierModel.professional:
        return SubscriptionTier.professional;
    }
  }

  /// Create from domain entity
  static SubscriptionTierModel fromEntity(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return SubscriptionTierModel.free;
      case SubscriptionTier.basic:
        return SubscriptionTierModel.basic;
      case SubscriptionTier.premium:
        return SubscriptionTierModel.premium;
      case SubscriptionTier.professional:
        return SubscriptionTierModel.professional;
    }
  }

  /// Create from string
  static SubscriptionTierModel fromString(String tierStr) {
    switch (tierStr.toLowerCase()) {
      case 'free':
        return SubscriptionTierModel.free;
      case 'basic':
        return SubscriptionTierModel.basic;
      case 'premium':
        return SubscriptionTierModel.premium;
      case 'professional':
        return SubscriptionTierModel.professional;
      default:
        return SubscriptionTierModel.free;
    }
  }
}

/// Subscription Status Model with Hive Serialization
@HiveType(typeId: 18)
enum SubscriptionStatusModel {
  @HiveField(0)
  active,
  
  @HiveField(1)
  inactive,
  
  @HiveField(2)
  trial,
  
  @HiveField(3)
  expired,
  
  @HiveField(4)
  canceled,
  
  @HiveField(5)
  suspended;

  /// Convert to domain entity
  SubscriptionStatus toEntity() {
    switch (this) {
      case SubscriptionStatusModel.active:
        return SubscriptionStatus.active;
      case SubscriptionStatusModel.inactive:
        return SubscriptionStatus.inactive;
      case SubscriptionStatusModel.trial:
        return SubscriptionStatus.trial;
      case SubscriptionStatusModel.expired:
        return SubscriptionStatus.expired;
      case SubscriptionStatusModel.canceled:
        return SubscriptionStatus.canceled;
      case SubscriptionStatusModel.suspended:
        return SubscriptionStatus.suspended;
    }
  }

  /// Create from domain entity
  static SubscriptionStatusModel fromEntity(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return SubscriptionStatusModel.active;
      case SubscriptionStatus.inactive:
        return SubscriptionStatusModel.inactive;
      case SubscriptionStatus.trial:
        return SubscriptionStatusModel.trial;
      case SubscriptionStatus.expired:
        return SubscriptionStatusModel.expired;
      case SubscriptionStatus.canceled:
        return SubscriptionStatusModel.canceled;
      case SubscriptionStatus.suspended:
        return SubscriptionStatusModel.suspended;
    }
  }

  /// Create from string
  static SubscriptionStatusModel fromString(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'active':
        return SubscriptionStatusModel.active;
      case 'inactive':
        return SubscriptionStatusModel.inactive;
      case 'trial':
        return SubscriptionStatusModel.trial;
      case 'expired':
        return SubscriptionStatusModel.expired;
      case 'canceled':
        return SubscriptionStatusModel.canceled;
      case 'suspended':
        return SubscriptionStatusModel.suspended;
      default:
        return SubscriptionStatusModel.inactive;
    }
  }
}

/// Billing Period Model with Hive Serialization
@HiveType(typeId: 19)
enum BillingPeriodModel {
  @HiveField(0)
  monthly,
  
  @HiveField(1)
  quarterly,
  
  @HiveField(2)
  yearly;

  /// Convert to domain entity
  BillingPeriod toEntity() {
    switch (this) {
      case BillingPeriodModel.monthly:
        return BillingPeriod.monthly;
      case BillingPeriodModel.quarterly:
        return BillingPeriod.quarterly;
      case BillingPeriodModel.yearly:
        return BillingPeriod.yearly;
    }
  }

  /// Create from domain entity
  static BillingPeriodModel fromEntity(BillingPeriod period) {
    switch (period) {
      case BillingPeriod.monthly:
        return BillingPeriodModel.monthly;
      case BillingPeriod.quarterly:
        return BillingPeriodModel.quarterly;
      case BillingPeriod.yearly:
        return BillingPeriodModel.yearly;
    }
  }

  /// Create from string
  static BillingPeriodModel fromString(String periodStr) {
    switch (periodStr.toLowerCase()) {
      case 'monthly':
        return BillingPeriodModel.monthly;
      case 'quarterly':
        return BillingPeriodModel.quarterly;
      case 'yearly':
        return BillingPeriodModel.yearly;
      default:
        return BillingPeriodModel.monthly;
    }
  }
}

/// Premium Feature Model with Hive Serialization
@HiveType(typeId: 20)
enum PremiumFeatureModel {
  @HiveField(0)
  advancedCalculators,
  
  @HiveField(1)
  premiumNews,
  
  @HiveField(2)
  exportData,
  
  @HiveField(3)
  cloudSync,
  
  @HiveField(4)
  prioritySupport,
  
  @HiveField(5)
  customReports,
  
  @HiveField(6)
  apiAccess,
  
  @HiveField(7)
  unlimitedAnimals;

  /// Convert to domain entity
  PremiumFeature toEntity() {
    switch (this) {
      case PremiumFeatureModel.advancedCalculators:
        return PremiumFeature.advancedCalculators;
      case PremiumFeatureModel.premiumNews:
        return PremiumFeature.premiumNews;
      case PremiumFeatureModel.exportData:
        return PremiumFeature.exportData;
      case PremiumFeatureModel.cloudSync:
        return PremiumFeature.cloudSync;
      case PremiumFeatureModel.prioritySupport:
        return PremiumFeature.prioritySupport;
      case PremiumFeatureModel.customReports:
        return PremiumFeature.customReports;
      case PremiumFeatureModel.apiAccess:
        return PremiumFeature.apiAccess;
      case PremiumFeatureModel.unlimitedAnimals:
        return PremiumFeature.unlimitedAnimals;
    }
  }

  /// Create from domain entity
  static PremiumFeatureModel fromEntity(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.advancedCalculators:
        return PremiumFeatureModel.advancedCalculators;
      case PremiumFeature.premiumNews:
        return PremiumFeatureModel.premiumNews;
      case PremiumFeature.exportData:
        return PremiumFeatureModel.exportData;
      case PremiumFeature.cloudSync:
        return PremiumFeatureModel.cloudSync;
      case PremiumFeature.prioritySupport:
        return PremiumFeatureModel.prioritySupport;
      case PremiumFeature.customReports:
        return PremiumFeatureModel.customReports;
      case PremiumFeature.apiAccess:
        return PremiumFeatureModel.apiAccess;
      case PremiumFeature.unlimitedAnimals:
        return PremiumFeatureModel.unlimitedAnimals;
    }
  }

  /// Create from string
  static PremiumFeatureModel fromString(String featureStr) {
    switch (featureStr.toLowerCase().replaceAll('_', '').replaceAll(' ', '')) {
      case 'advancedcalculators':
        return PremiumFeatureModel.advancedCalculators;
      case 'premiumnews':
        return PremiumFeatureModel.premiumNews;
      case 'exportdata':
        return PremiumFeatureModel.exportData;
      case 'cloudsync':
        return PremiumFeatureModel.cloudSync;
      case 'prioritysupport':
        return PremiumFeatureModel.prioritySupport;
      case 'customreports':
        return PremiumFeatureModel.customReports;
      case 'apiaccess':
        return PremiumFeatureModel.apiAccess;
      case 'unlimitedanimals':
        return PremiumFeatureModel.unlimitedAnimals;
      default:
        return PremiumFeatureModel.advancedCalculators;
    }
  }
}

/// Payment Method Model with Hive Serialization
@HiveType(typeId: 21)
class PaymentMethodModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final PaymentTypeModel type;
  
  @HiveField(2)
  final String lastFourDigits;
  
  @HiveField(3)
  final String brand;
  
  @HiveField(4)
  final DateTime expiryDate;
  
  @HiveField(5)
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.lastFourDigits,
    required this.brand,
    required this.expiryDate,
    this.isDefault = false,
  });
  
  /// Convert to domain entity
  PaymentMethod toEntity() {
    return PaymentMethod(
      id: id,
      type: type.toEntity(),
      lastFourDigits: lastFourDigits,
      brand: brand,
      expiryDate: expiryDate,
      isDefault: isDefault,
    );
  }

  /// Create from Entity
  factory PaymentMethodModel.fromEntity(PaymentMethod entity) {
    return PaymentMethodModel(
      id: entity.id,
      type: PaymentTypeModel.fromEntity(entity.type),
      lastFourDigits: entity.lastFourDigits,
      brand: entity.brand,
      expiryDate: entity.expiryDate,
      isDefault: entity.isDefault,
    );
  }

  /// Create from JSON
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String? ?? '',
      type: PaymentTypeModel.fromString(json['type'] as String? ?? 'creditCard'),
      lastFourDigits: json['lastFourDigits'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      expiryDate: DateTime.tryParse(json['expiryDate'] as String? ?? '') ?? DateTime.now(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'lastFourDigits': lastFourDigits,
      'brand': brand,
      'expiryDate': expiryDate.toIso8601String(),
      'isDefault': isDefault,
    };
  }
}

/// Payment Type Model with Hive Serialization
@HiveType(typeId: 22)
enum PaymentTypeModel {
  @HiveField(0)
  creditCard,
  
  @HiveField(1)
  debitCard,
  
  @HiveField(2)
  pix,
  
  @HiveField(3)
  paypal,
  
  @HiveField(4)
  applePay,
  
  @HiveField(5)
  googlePay;

  /// Convert to domain entity
  PaymentType toEntity() {
    switch (this) {
      case PaymentTypeModel.creditCard:
        return PaymentType.creditCard;
      case PaymentTypeModel.debitCard:
        return PaymentType.debitCard;
      case PaymentTypeModel.pix:
        return PaymentType.pix;
      case PaymentTypeModel.paypal:
        return PaymentType.paypal;
      case PaymentTypeModel.applePay:
        return PaymentType.applePay;
      case PaymentTypeModel.googlePay:
        return PaymentType.googlePay;
    }
  }

  /// Create from domain entity
  static PaymentTypeModel fromEntity(PaymentType type) {
    switch (type) {
      case PaymentType.creditCard:
        return PaymentTypeModel.creditCard;
      case PaymentType.debitCard:
        return PaymentTypeModel.debitCard;
      case PaymentType.pix:
        return PaymentTypeModel.pix;
      case PaymentType.paypal:
        return PaymentTypeModel.paypal;
      case PaymentType.applePay:
        return PaymentTypeModel.applePay;
      case PaymentType.googlePay:
        return PaymentTypeModel.googlePay;
    }
  }

  /// Create from string
  static PaymentTypeModel fromString(String typeStr) {
    switch (typeStr.toLowerCase().replaceAll('_', '').replaceAll(' ', '')) {
      case 'creditcard':
        return PaymentTypeModel.creditCard;
      case 'debitcard':
        return PaymentTypeModel.debitCard;
      case 'pix':
        return PaymentTypeModel.pix;
      case 'paypal':
        return PaymentTypeModel.paypal;
      case 'applepay':
        return PaymentTypeModel.applePay;
      case 'googlepay':
        return PaymentTypeModel.googlePay;
      default:
        return PaymentTypeModel.creditCard;
    }
  }
}
import 'package:equatable/equatable.dart';

/// Entity para assinatura seguindo princípios Clean Architecture
class SubscriptionEntity extends Equatable {
  final String id;
  final String productId;
  final String title;
  final String description;
  final String price;
  final String formattedPrice;
  final SubscriptionPeriod period;
  final SubscriptionStatus status;
  final DateTime? purchaseDate;
  final DateTime? expirationDate;
  final DateTime? trialEndDate;
  final bool isActive;
  final bool isTrialPeriod;
  final List<String> features;
  final Map<String, dynamic> metadata;

  const SubscriptionEntity({
    required this.id,
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.formattedPrice,
    required this.period,
    required this.status,
    this.purchaseDate,
    this.expirationDate,
    this.trialEndDate,
    this.isActive = false,
    this.isTrialPeriod = false,
    this.features = const [],
    this.metadata = const {},
  });

  bool get isPremium => isActive && status == SubscriptionStatus.active;
  bool get isExpired => expirationDate != null && DateTime.now().isAfter(expirationDate!);
  bool get willRenew => status == SubscriptionStatus.active && !isTrialPeriod;

  int get daysUntilExpiration {
    if (expirationDate == null) return -1;
    return expirationDate!.difference(DateTime.now()).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        title,
        description,
        price,
        formattedPrice,
        period,
        status,
        purchaseDate,
        expirationDate,
        trialEndDate,
        isActive,
        isTrialPeriod,
        features,
        metadata,
      ];
}

/// Enum para status da assinatura
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  pending,
  paused,
  unknown,
}

/// Enum para período da assinatura
enum SubscriptionPeriod {
  monthly,
  yearly,
  weekly,
  lifetime,
  unknown,
}

/// Entity para produto de assinatura disponível
class SubscriptionProductEntity extends Equatable {
  final String id;
  final String identifier;
  final String title;
  final String description;
  final String price;
  final String formattedPrice;
  final SubscriptionPeriod period;
  final String? trialPeriod;
  final List<String> features;
  final bool isPopular;
  final String? discount;
  final Map<String, dynamic> metadata;

  const SubscriptionProductEntity({
    required this.id,
    required this.identifier,
    required this.title,
    required this.description,
    required this.price,
    required this.formattedPrice,
    required this.period,
    this.trialPeriod,
    this.features = const [],
    this.isPopular = false,
    this.discount,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        identifier,
        title,
        description,
        price,
        formattedPrice,
        period,
        trialPeriod,
        features,
        isPopular,
        discount,
        metadata,
      ];
}

/// Entity para informações de usuário premium
class PremiumUserEntity extends Equatable {
  final String userId;
  final bool isPremium;
  final List<SubscriptionEntity> activeSubscriptions;
  final DateTime? lastSubscriptionCheck;
  final Map<String, bool> features;

  const PremiumUserEntity({
    required this.userId,
    this.isPremium = false,
    this.activeSubscriptions = const [],
    this.lastSubscriptionCheck,
    this.features = const {},
  });

  bool hasFeature(String featureKey) => features[featureKey] == true;
  
  SubscriptionEntity? get primarySubscription => 
      activeSubscriptions.isNotEmpty ? activeSubscriptions.first : null;

  @override
  List<Object?> get props => [
        userId,
        isPremium,
        activeSubscriptions,
        lastSubscriptionCheck,
        features,
      ];
}
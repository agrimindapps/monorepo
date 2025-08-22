import 'package:equatable/equatable.dart';

/// Subscription Entity for Premium Features Management
/// 
/// Represents user subscription status and premium features access
class SubscriptionEntity extends Equatable {
  final String id;
  final String userId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextBillingDate;
  final double price;
  final String currency;
  final BillingPeriod billingPeriod;
  final List<PremiumFeature> features;
  final PaymentMethod? paymentMethod;
  final bool autoRenew;

  const SubscriptionEntity({
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

  /// Check if subscription is currently active
  bool get isActive => status == SubscriptionStatus.active;

  /// Check if subscription is expired
  bool get isExpired => status == SubscriptionStatus.expired;

  /// Check if subscription is in trial period
  bool get isTrial => status == SubscriptionStatus.trial;

  /// Check if user has access to specific feature
  bool hasFeature(PremiumFeature feature) => features.contains(feature);

  /// Days until subscription expires
  int? get daysUntilExpiry {
    if (endDate == null) return null;
    final now = DateTime.now();
    if (endDate!.isBefore(now)) return 0;
    return endDate!.difference(now).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        tier,
        status,
        startDate,
        endDate,
        nextBillingDate,
        price,
        currency,
        billingPeriod,
        features,
        paymentMethod,
        autoRenew,
      ];
}

/// Subscription Tiers
enum SubscriptionTier {
  free('Free', 0.0),
  basic('Basic', 9.99),
  premium('Premium', 19.99),
  professional('Professional', 39.99);

  const SubscriptionTier(this.displayName, this.monthlyPrice);
  final String displayName;
  final double monthlyPrice;
}

/// Subscription Status
enum SubscriptionStatus {
  active('Ativo'),
  inactive('Inativo'),
  trial('Período de Teste'),
  expired('Expirado'),
  canceled('Cancelado'),
  suspended('Suspenso');

  const SubscriptionStatus(this.displayName);
  final String displayName;
}

/// Billing Periods
enum BillingPeriod {
  monthly('Mensal', 1),
  quarterly('Trimestral', 3),
  yearly('Anual', 12);

  const BillingPeriod(this.displayName, this.months);
  final String displayName;
  final int months;
}

/// Premium Features
enum PremiumFeature {
  advancedCalculators('Calculadoras Avançadas'),
  premiumNews('Notícias Premium'),
  exportData('Exportação de Dados'),
  cloudSync('Sincronização na Nuvem'),
  prioritySupport('Suporte Prioritário'),
  customReports('Relatórios Personalizados'),
  apiAccess('Acesso à API'),
  unlimitedAnimals('Animais Ilimitados');

  const PremiumFeature(this.displayName);
  final String displayName;
}

/// Payment Method Information
class PaymentMethod extends Equatable {
  final String id;
  final PaymentType type;
  final String lastFourDigits;
  final String brand; // Visa, Mastercard, etc.
  final DateTime expiryDate;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFourDigits,
    required this.brand,
    required this.expiryDate,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        lastFourDigits,
        brand,
        expiryDate,
        isDefault,
      ];
}

/// Payment Types
enum PaymentType {
  creditCard('Cartão de Crédito'),
  debitCard('Cartão de Débito'),
  pix('PIX'),
  paypal('PayPal'),
  applePay('Apple Pay'),
  googlePay('Google Pay');

  const PaymentType(this.displayName);
  final String displayName;
}
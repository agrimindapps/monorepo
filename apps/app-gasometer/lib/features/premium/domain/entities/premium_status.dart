import 'package:equatable/equatable.dart';
import 'package:core/core.dart' as core;
import 'premium_features.dart';

/// Status premium específico do GasOMeter
class PremiumStatus extends Equatable {
  const PremiumStatus({
    required this.isPremium,
    required this.features,
    required this.limits,
    this.subscription,
    this.expirationDate,
    this.isInTrial = false,
    this.trialDaysRemaining,
    this.localLicenseExpiration,
  });

  /// Se o usuário tem acesso premium
  final bool isPremium;

  /// Features premium disponíveis
  final PremiumFeatures features;

  /// Limites de uso baseados no status
  final UsageLimits limits;

  /// Dados da assinatura (se houver)
  final core.SubscriptionEntity? subscription;

  /// Data de expiração do premium
  final DateTime? expirationDate;

  /// Se está em período de trial
  final bool isInTrial;

  /// Dias restantes do trial (se aplicável)
  final int? trialDaysRemaining;

  /// Expiração da licença local de desenvolvimento
  final DateTime? localLicenseExpiration;

  /// Status premium completo
  static PremiumStatus premium({
    core.SubscriptionEntity? subscription,
    DateTime? expirationDate,
    bool isInTrial = false,
    int? trialDaysRemaining,
  }) {
    return PremiumStatus(
      isPremium: true,
      features: PremiumFeatures.all,
      limits: UsageLimits.premium,
      subscription: subscription,
      expirationDate: expirationDate,
      isInTrial: isInTrial,
      trialDaysRemaining: trialDaysRemaining,
    );
  }

  /// Status gratuito
  static const PremiumStatus free = PremiumStatus(
    isPremium: false,
    features: PremiumFeatures.none,
    limits: UsageLimits.free,
  );

  /// Status com licença local de desenvolvimento
  static PremiumStatus localLicense({
    required DateTime expiration,
  }) {
    return PremiumStatus(
      isPremium: true,
      features: PremiumFeatures.all,
      limits: UsageLimits.premium,
      localLicenseExpiration: expiration,
    );
  }

  /// Se está expirado
  bool get isExpired {
    if (expirationDate != null) {
      return DateTime.now().isAfter(expirationDate!);
    }
    if (localLicenseExpiration != null) {
      return DateTime.now().isAfter(localLicenseExpiration!);
    }
    return false;
  }

  /// Se é trial ativo
  bool get isActiveTrialUser {
    return isInTrial && trialDaysRemaining != null && trialDaysRemaining! > 0;
  }

  /// Se tem licença local ativa
  bool get hasActiveLocalLicense {
    return localLicenseExpiration != null && 
           DateTime.now().isBefore(localLicenseExpiration!);
  }

  /// Se tem assinatura ativa
  bool get hasActiveSubscription {
    return subscription?.isActive == true;
  }

  /// Fonte do premium (trial, subscription, local license)
  String get premiumSource {
    if (hasActiveLocalLicense) return 'Licença Local';
    if (isActiveTrialUser) return 'Trial Gratuito';
    if (hasActiveSubscription) return 'Assinatura';
    return isPremium ? 'Premium' : 'Gratuito';
  }

  /// Dias restantes até expiração
  int? get daysUntilExpiration {
    DateTime? expirationToCheck;
    
    if (localLicenseExpiration != null) {
      expirationToCheck = localLicenseExpiration;
    } else if (expirationDate != null) {
      expirationToCheck = expirationDate;
    }
    
    if (expirationToCheck == null) return null;
    
    final now = DateTime.now();
    if (now.isAfter(expirationToCheck)) return 0;
    
    return expirationToCheck.difference(now).inDays;
  }

  /// Se pode usar uma feature específica
  bool canUseFeature(String featureId) {
    if (!isPremium) return false;
    return features.hasFeature(featureId);
  }

  /// Se pode adicionar veículo
  bool canAddVehicle(int currentCount) {
    return limits.canAddVehicle(currentCount);
  }

  /// Se pode adicionar registro de combustível
  bool canAddFuelRecord(int currentCount) {
    return limits.canAddFuelRecord(currentCount);
  }

  /// Se pode adicionar registro de manutenção
  bool canAddMaintenanceRecord(int currentCount) {
    return limits.canAddMaintenanceRecord(currentCount);
  }

  /// Copia o status com novos valores
  PremiumStatus copyWith({
    bool? isPremium,
    PremiumFeatures? features,
    UsageLimits? limits,
    core.SubscriptionEntity? subscription,
    DateTime? expirationDate,
    bool? isInTrial,
    int? trialDaysRemaining,
    DateTime? localLicenseExpiration,
  }) {
    return PremiumStatus(
      isPremium: isPremium ?? this.isPremium,
      features: features ?? this.features,
      limits: limits ?? this.limits,
      subscription: subscription ?? this.subscription,
      expirationDate: expirationDate ?? this.expirationDate,
      isInTrial: isInTrial ?? this.isInTrial,
      trialDaysRemaining: trialDaysRemaining ?? this.trialDaysRemaining,
      localLicenseExpiration: localLicenseExpiration ?? this.localLicenseExpiration,
    );
  }

  @override
  List<Object?> get props => [
        isPremium,
        features,
        limits,
        subscription,
        expirationDate,
        isInTrial,
        trialDaysRemaining,
        localLicenseExpiration,
      ];

  @override
  String toString() {
    return 'PremiumStatus(isPremium: $isPremium, source: $premiumSource, daysRemaining: $daysUntilExpiration)';
  }
}
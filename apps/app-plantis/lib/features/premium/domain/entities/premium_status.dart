import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Equatable;

import 'premium_features.dart';

/// Status premium específico do Plantis
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
  static PremiumStatus localLicense({required DateTime expiration}) {
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
    } else if (subscription?.expirationDate != null) {
      expirationToCheck = subscription!.expirationDate;
    }

    if (expirationToCheck == null) return null;

    final now = DateTime.now();
    final difference = expirationToCheck.difference(now);
    return difference.inDays;
  }

  /// Se está próximo de expirar (menos de 7 dias)
  bool get isAboutToExpire {
    final days = daysUntilExpiration;
    return days != null && days > 0 && days <= 7;
  }

  /// Verifica se pode usar uma feature específica
  bool canUseFeature(String featureName) {
    if (!isPremium) return false;

    switch (featureName) {
      case 'unlimited_plants':
        return features.unlimitedPlants;
      case 'advanced_care_reminders':
        return features.advancedCareReminders;
      case 'plant_identification':
        return features.plantIdentification;
      case 'expert_advice':
        return features.expertAdvice;
      case 'weather_integration':
        return features.weatherIntegration;
      case 'unlimited_photo_storage':
        return features.unlimitedPhotoStorage;
      case 'custom_spaces':
        return features.customSpaces;
      case 'advanced_analytics':
        return features.advancedAnalytics;
      case 'export_data':
        return features.exportData;
      case 'cloud_backup':
        return features.cloudBackup;
      case 'disease_detection':
        return features.diseaseDetection;
      case 'growth_tracking':
        return features.growthTracking;
      case 'community_features':
        return features.communityFeatures;
      case 'premium_support':
        return features.premiumSupport;
      default:
        return false;
    }
  }

  /// Verifica se atingiu o limite de uso
  bool hasReachedLimit({required String limitType, required int currentCount}) {
    if (limits.isUnlimited) return false;

    switch (limitType) {
      case 'plants':
        return currentCount >= limits.maxPlants;
      case 'photos_per_plant':
        return currentCount >= limits.maxPhotosPerPlant;
      case 'spaces':
        return currentCount >= limits.maxSpaces;
      case 'comments':
        return currentCount >= limits.maxComments;
      default:
        return false;
    }
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
      localLicenseExpiration:
          localLicenseExpiration ?? this.localLicenseExpiration,
    );
  }
}

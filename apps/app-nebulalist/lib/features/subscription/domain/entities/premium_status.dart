import 'package:core/core.dart' as core;
import 'package:equatable/equatable.dart';

import 'premium_features.dart';

/// Status premium específico do Nebulalist
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
      case 'unlimited_lists':
        return features.unlimitedLists;
      case 'unlimited_tasks':
        return features.unlimitedTasks;
      case 'cloud_sync':
        return features.cloudSync;
      case 'shared_lists':
        return features.sharedLists;
      case 'smart_reminders':
        return features.smartReminders;
      case 'advanced_categories':
        return features.advancedCategories;
      case 'detailed_statistics':
        return features.detailedStatistics;
      case 'premium_themes':
        return features.premiumThemes;
      case 'data_export':
        return features.dataExport;
      case 'priority_support':
        return features.prioritySupport;
      case 'offline_mode':
        return features.offlineMode;
      case 'recurring_tasks':
        return features.recurringTasks;
      default:
        return false;
    }
  }

  /// Verifica se atingiu o limite de uso
  bool hasReachedLimit({required String limitType, required int currentCount}) {
    if (limits.isUnlimited) return false;

    switch (limitType) {
      case 'lists':
        return currentCount >= limits.maxLists;
      case 'tasks_per_list':
        return currentCount >= limits.maxTasksPerList;
      case 'categories':
        return currentCount >= limits.maxCategories;
      case 'shared_users':
        return currentCount >= limits.maxSharedUsers;
      case 'reminders':
        return currentCount >= limits.maxReminders;
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

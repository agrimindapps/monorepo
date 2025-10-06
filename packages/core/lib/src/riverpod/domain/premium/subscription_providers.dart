import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../infrastructure/services/revenue_cat_service.dart';

/// Providers unificados para gerenciamento de assinaturas Premium
/// Consolida RevenueCat integration entre todos os apps do monorepo

// ========== CORE SUBSCRIPTION PROVIDERS ==========

/// Provider principal para estado de assinatura
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
      return SubscriptionNotifier();
    });

/// Provider para verificar se usuário tem premium ativo
final isPremiumProvider = Provider<bool>((ref) {
  final subscription = ref.watch(subscriptionProvider);
  return subscription.maybeWhen(
    active: (info) => info.isPremium,
    orElse: () => false,
  );
});

/// Provider para informações da assinatura atual
final subscriptionInfoProvider = Provider<SubscriptionInfo?>((ref) {
  final subscription = ref.watch(subscriptionProvider);
  return subscription.maybeWhen(
    active: (info) => info,
    expired: (info) => info,
    orElse: () => null,
  );
});

/// Provider para produtos disponíveis (SKUs)
final availableProductsProvider = FutureProvider<List<StoreProduct>>((
  ref,
) async {
  // REVIEW (converted TODO 2025-10-06): Implementar getOfferings no RevenueCatService
  // Por enquanto, retornar lista vazia
  return <StoreProduct>[];
});

/// Provider para ofertas atuais do RevenueCat
final currentOfferingsProvider = FutureProvider<Offerings?>((ref) async {
  // REVIEW (converted TODO 2025-10-06): Implementar getOfferings no RevenueCatService
  // Por enquanto, retornar null
  return null;
});

// ========== FEATURE GATE PROVIDERS ==========

/// Provider para verificar acesso a features específicas por app
final featureGateProvider = Provider.family<bool, String>((ref, featureName) {
  final isPremium = ref.watch(isPremiumProvider);
  final appId = ref.watch(currentAppIdProvider); // Será criado

  return _hasFeatureAccess(appId, featureName, isPremium);
});

/// Provider para limitações específicas por app
final featureLimitsProvider = Provider.family<FeatureLimits, String>((
  ref,
  appId,
) {
  final isPremium = ref.watch(isPremiumProvider);
  return FeatureLimits.forApp(appId, isPremium);
});

/// Provider para contagem de uso de features
final featureUsageProvider = StateProvider.family<int, String>(
  (ref, feature) => 0,
);

/// Provider para verificar se atingiu limite de uso
final hasReachedLimitProvider = Provider.family<bool, String>((ref, feature) {
  final usage = ref.watch(featureUsageProvider(feature));
  final limits = ref.watch(
    featureLimitsProvider(feature.split(':').first),
  ); // app:feature

  return limits.hasReachedLimit(feature, usage);
});

// ========== APP-SPECIFIC PROVIDERS ==========

/// Provider para features premium específicas do Gasometer
final gasometerPremiumFeaturesProvider = Provider<GasometerPremiumFeatures>((
  ref,
) {
  final isPremium = ref.watch(isPremiumProvider);
  return GasometerPremiumFeatures(isPremium);
});

/// Provider para features premium específicas do Plantis
final plantisPremiumFeaturesProvider = Provider<PlantisPremiumFeatures>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  return PlantisPremiumFeatures(isPremium);
});

/// Provider para features premium específicas do ReceitaAgro
final receitaagroPremiumFeaturesProvider = Provider<ReceitaagroPremiumFeatures>(
  (ref) {
    final isPremium = ref.watch(isPremiumProvider);
    return ReceitaagroPremiumFeatures(isPremium);
  },
);

// ========== PURCHASE PROVIDERS ==========

/// Provider para ações de compra
final purchaseActionsProvider = Provider<PurchaseActions>((ref) {
  final notifier = ref.read(subscriptionProvider.notifier);

  return PurchaseActions(
    purchasePackage: notifier.purchasePackage,
    restorePurchases: notifier.restorePurchases,
    checkSubscriptionStatus: notifier.checkSubscriptionStatus,
  );
});

/// Provider para histórico de compras
final purchaseHistoryProvider = FutureProvider<List<StoreTransaction>>((
  ref,
) async {
  // REVIEW (converted TODO 2025-10-06): Implementar getCustomerInfo no RevenueCatService
  // Por enquanto, retornar lista vazia
  return <StoreTransaction>[];
});

// ========== UTILITY PROVIDERS ==========

/// Provider para informações do cliente RevenueCat
final customerInfoProvider = FutureProvider<CustomerInfo?>((ref) async {
  // REVIEW (converted TODO 2025-10-06): Implementar getCustomerInfo no RevenueCatService
  // Por enquanto, retornar null
  return null;
});

/// Provider para data de expiração da assinatura
final subscriptionExpirationProvider = Provider<DateTime?>((ref) {
  final info = ref.watch(subscriptionInfoProvider);
  return info?.expirationDate;
});

/// Provider para verificar se assinatura vai expirar em breve
final subscriptionExpiringSoonProvider = Provider<bool>((ref) {
  final expiration = ref.watch(subscriptionExpirationProvider);
  if (expiration == null) return false;

  final daysUntilExpiration = expiration.difference(DateTime.now()).inDays;
  return daysUntilExpiration <= 7; // Avisa 7 dias antes
});

/// Provider para status de trial
final trialStatusProvider = Provider<TrialStatus>((ref) {
  final info = ref.watch(subscriptionInfoProvider);

  if (info == null) return TrialStatus.notStarted;
  if (info.isTrialPeriod) return TrialStatus.active;
  if (info.hasUsedTrial) return TrialStatus.expired;

  return TrialStatus.notEligible;
});

// ========== MODELS ==========

/// Estados da assinatura
abstract class SubscriptionState {
  const SubscriptionState();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionActive extends SubscriptionState {
  final SubscriptionInfo info;
  const SubscriptionActive(this.info);
}

class SubscriptionExpired extends SubscriptionState {
  final SubscriptionInfo info;
  const SubscriptionExpired(this.info);
}

class SubscriptionInactive extends SubscriptionState {
  const SubscriptionInactive();
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);
}

extension SubscriptionStateExtension on SubscriptionState {
  T when<T>({
    required T Function() loading,
    required T Function(SubscriptionInfo info) active,
    required T Function(SubscriptionInfo info) expired,
    required T Function() inactive,
    required T Function(String message) error,
  }) {
    if (this is SubscriptionLoading) return loading();
    if (this is SubscriptionActive) {
      return active((this as SubscriptionActive).info);
    }
    if (this is SubscriptionExpired) {
      return expired((this as SubscriptionExpired).info);
    }
    if (this is SubscriptionInactive) return inactive();
    if (this is SubscriptionError) {
      return error((this as SubscriptionError).message);
    }
    throw StateError('Unknown state: $this');
  }

  T maybeWhen<T>({
    T Function()? loading,
    T Function(SubscriptionInfo info)? active,
    T Function(SubscriptionInfo info)? expired,
    T Function()? inactive,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is SubscriptionLoading && loading != null) return loading();
    if (this is SubscriptionActive && active != null) {
      return active((this as SubscriptionActive).info);
    }
    if (this is SubscriptionExpired && expired != null) {
      return expired((this as SubscriptionExpired).info);
    }
    if (this is SubscriptionInactive && inactive != null) return inactive();
    if (this is SubscriptionError && error != null) {
      return error((this as SubscriptionError).message);
    }
    return orElse();
  }
}

/// Informações da assinatura
class SubscriptionInfo {
  final String productId;
  final bool isPremium;
  final bool isTrialPeriod;
  final bool hasUsedTrial;
  final DateTime? purchaseDate;
  final DateTime? expirationDate;
  final String? originalTransactionId;
  final EntitlementInfo? entitlementInfo;

  const SubscriptionInfo({
    required this.productId,
    required this.isPremium,
    this.isTrialPeriod = false,
    this.hasUsedTrial = false,
    this.purchaseDate,
    this.expirationDate,
    this.originalTransactionId,
    this.entitlementInfo,
  });

  bool get isActive =>
      isPremium && (expirationDate?.isAfter(DateTime.now()) ?? false);
  bool get isExpired => !isActive && expirationDate != null;

  int get daysUntilExpiration {
    if (expirationDate == null) return -1;
    return expirationDate!.difference(DateTime.now()).inDays;
  }
}

/// Status do trial
enum TrialStatus { notStarted, active, expired, notEligible }

/// Limitações de features por app
class FeatureLimits {
  final String appId;
  final bool isPremium;
  final Map<String, int> limits; // feature -> limit count (-1 = unlimited)

  const FeatureLimits({
    required this.appId,
    required this.isPremium,
    required this.limits,
  });

  factory FeatureLimits.forApp(String appId, bool isPremium) {
    if (isPremium) {
      // Premium users have no limits
      return FeatureLimits(appId: appId, isPremium: true, limits: const {});
    }

    // Free users have app-specific limits
    switch (appId) {
      case 'gasometer':
        return FeatureLimits(
          appId: appId,
          isPremium: false,
          limits: const {
            'vehicles': 2,
            'fuel_records': 50,
            'expenses': 30,
            'data_export': 0, // Premium only
            'advanced_analytics': 0,
          },
        );
      case 'plantis':
        return FeatureLimits(
          appId: appId,
          isPremium: false,
          limits: const {
            'plants': 5,
            'care_reminders': 10,
            'photo_storage': 20,
            'advanced_care_tips': 0,
            'plant_identification': 3,
          },
        );
      case 'receituagro':
        return FeatureLimits(
          appId: appId,
          isPremium: false,
          limits: const {
            'diagnostics': 10,
            'offline_access': 0,
            'expert_consultation': 0,
            'detailed_reports': 0,
          },
        );
      default:
        return FeatureLimits(appId: appId, isPremium: false, limits: const {});
    }
  }

  int getLimitFor(String feature) => limits[feature] ?? -1;
  bool hasReachedLimit(String feature, int currentUsage) {
    final limit = getLimitFor(feature);
    return limit != -1 && currentUsage >= limit;
  }

  bool isFeatureUnlimited(String feature) => getLimitFor(feature) == -1;
}

/// Features premium específicas do Gasometer
class GasometerPremiumFeatures {
  final bool isPremium;

  const GasometerPremiumFeatures(this.isPremium);

  bool get unlimitedVehicles => isPremium;
  bool get advancedAnalytics => isPremium;
  bool get dataExport => isPremium;
  bool get cloudBackup => isPremium;
  bool get multipleUsers => isPremium;
  bool get customCategories => isPremium;
}

/// Features premium específicas do Plantis
class PlantisPremiumFeatures {
  final bool isPremium;

  const PlantisPremiumFeatures(this.isPremium);

  bool get unlimitedPlants => isPremium;
  bool get advancedCareReminders => isPremium;
  bool get plantIdentification => isPremium;
  bool get expertAdvice => isPremium;
  bool get weatherIntegration => isPremium;
  bool get unlimitedPhotoStorage => isPremium;
}

/// Features premium específicas do ReceitaAgro
class ReceitaagroPremiumFeatures {
  final bool isPremium;

  const ReceitaagroPremiumFeatures(this.isPremium);

  bool get unlimitedDiagnostics => isPremium;
  bool get offlineAccess => isPremium;
  bool get expertConsultation => isPremium;
  bool get detailedReports => isPremium;
  bool get customTreatments => isPremium;
  bool get prioritySupport => isPremium;
}

/// Ações de compra disponíveis
class PurchaseActions {
  final Future<bool> Function(Package package) purchasePackage;
  final Future<bool> Function() restorePurchases;
  final Future<void> Function() checkSubscriptionStatus;

  const PurchaseActions({
    required this.purchasePackage,
    required this.restorePurchases,
    required this.checkSubscriptionStatus,
  });
}

// ========== NOTIFIER IMPLEMENTATION ==========

/// Notifier para gerenciamento de assinaturas
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionLoading()) {
    _initialize();
  }

  late final RevenueCatService _revenueCatService;

  Future<void> _initialize() async {
    try {
      _revenueCatService = RevenueCatService();
      await checkSubscriptionStatus();
    } catch (e) {
      state = SubscriptionError('Erro na inicialização: $e');
    }
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      state = const SubscriptionLoading();

      // REVIEW (converted TODO 2025-10-06): Implementar getCustomerInfo no RevenueCatService
      // Por enquanto, simular usuário sem premium
      final entitlements = <String, EntitlementInfo>{};

      if (entitlements.isNotEmpty) {
        // REVIEW (converted TODO 2025-10-06): Implementar parsing real do EntitlementInfo quando service estiver pronto
        final info = SubscriptionInfo(
          productId: 'premium_monthly',
          isPremium: true,
          isTrialPeriod: false,
          purchaseDate: DateTime.now().subtract(const Duration(days: 15)),
          expirationDate: DateTime.now().add(const Duration(days: 15)),
          originalTransactionId: 'mock_transaction_id',
        );

        if (info.isActive) {
          state = SubscriptionActive(info);
        } else {
          state = SubscriptionExpired(info);
        }
      } else {
        state = const SubscriptionInactive();
      }
    } catch (e) {
      state = SubscriptionError('Erro ao verificar assinatura: $e');
    }
  }

  Future<bool> purchasePackage(dynamic package) async {
    try {
      state = const SubscriptionLoading();

      // REVIEW (converted TODO 2025-10-06): Implementar purchasePackage no RevenueCatService
      // Por enquanto, simular compra bem-sucedida
      await Future.delayed(const Duration(seconds: 2));

      // Simular ativação de premium após compra
      final info = SubscriptionInfo(
        productId: 'premium_monthly',
        isPremium: true,
        isTrialPeriod: false,
        purchaseDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 30)),
        originalTransactionId:
            'mock_transaction_${DateTime.now().millisecondsSinceEpoch}',
      );

      state = SubscriptionActive(info);
      return true;
    } catch (e) {
      state = SubscriptionError('Erro na compra: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      state = const SubscriptionLoading();

      final result = await _revenueCatService.restorePurchases();

      result.fold(
        (failure) {
          state = SubscriptionError(failure.message);
          return false;
        },
        (customerInfo) {
          checkSubscriptionStatus();
          return true;
        },
      );

      return false;
    } catch (e) {
      state = SubscriptionError('Erro ao restaurar compras: $e');
      return false;
    }
  }
}

// ========== UTILITY FUNCTIONS ==========

/// Verifica se tem acesso a uma feature específica
bool _hasFeatureAccess(String appId, String featureName, bool isPremium) {
  if (isPremium) return true;

  // Features sempre gratuitas por app
  const freeFeatures = {
    'gasometer': {'basic_tracking', 'simple_reports'},
    'plantis': {'basic_plant_care', 'reminders'},
    'receituagro': {'basic_diagnostics', 'simple_search'},
  };

  return freeFeatures[appId]?.contains(featureName) ?? false;
}

// ========== TEMPORARY PROVIDER ==========
/// Provider temporário para app atual - será substituído por router integration
final currentAppIdProvider = Provider<String>((ref) {
  // Temporário - será detectado automaticamente
  return 'plantis';
});

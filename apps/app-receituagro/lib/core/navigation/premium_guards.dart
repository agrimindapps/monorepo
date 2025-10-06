import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/analytics/analytics_service.dart';
import '../data/adapters/subscription_adapter.dart';
import '../services/premium_service.dart';

/// Enum para diferentes features premium
enum PremiumFeature {
  unlimitedFavorites('unlimited_favorites'),
  syncData('sync_data'),
  premiumContent('premium_content'),
  prioritySupport('priority_support'),
  advancedSearch('advanced_search'),
  exportData('export_data'),
  offlineMode('offline_mode');

  const PremiumFeature(this.key);
  final String key;
}

/// Resultado da verificação de acesso premium
class PremiumAccessResult {
  final bool hasAccess;
  final String reason;
  final PremiumFeature feature;
  final SubscriptionEntity? subscription;

  const PremiumAccessResult({
    required this.hasAccess,
    required this.reason,
    required this.feature,
    this.subscription,
  });

  factory PremiumAccessResult.granted(PremiumFeature feature, SubscriptionEntity subscription) {
    return PremiumAccessResult(
      hasAccess: true,
      reason: 'Access granted - premium subscription active',
      feature: feature,
      subscription: subscription,
    );
  }

  factory PremiumAccessResult.denied(PremiumFeature feature, String reason) {
    return PremiumAccessResult(
      hasAccess: false,
      reason: reason,
      feature: feature,
    );
  }
}

/// Guards para controle de acesso a features premium
class PremiumGuards {
  final PremiumService _premiumService;
  final ReceitaAgroAnalyticsService _analyticsService;
  static const int maxFavoritesForFreeUser = 10;
  static const int maxCommentsForFreeUser = 5;
  static const int maxSearchResultsForFreeUser = 20;

  PremiumGuards(this._premiumService, this._analyticsService);

  /// Verifica se o usuário tem acesso a uma feature premium
  Future<PremiumAccessResult> checkFeatureAccess(PremiumFeature feature) async {
    try {
      final subscriptionData = _premiumService.getCurrentSubscription();
      if (subscriptionData == null) {
        await _trackAccessDenied(feature, 'No subscription found');
        return PremiumAccessResult.denied(
          feature,
          'Premium subscription required to access ${feature.key}',
        );
      }
      final subscription = SubscriptionEntity.fromFirebaseMap(
        Map<String, dynamic>.from(subscriptionData),
      );
      if (!subscription.isActive) {
        await _trackAccessDenied(feature, 'Subscription not active: ${subscription.status.name}');
        return PremiumAccessResult.denied(
          feature,
          'Premium subscription expired or inactive',
        );
      }
      if (!SubscriptionAdapter.hasFeature(subscription, feature.key)) {
        await _trackAccessDenied(feature, 'Feature not included in subscription');
        return PremiumAccessResult.denied(
          feature,
          'Feature ${feature.key} not included in your subscription plan',
        );
      }
      await _trackAccessGranted(feature, subscription);
      return PremiumAccessResult.granted(feature, subscription);

    } catch (e) {
      await _trackAccessError(feature, e.toString());
      return PremiumAccessResult.denied(
        feature,
        'Error checking premium access: $e',
      );
    }
  }

  /// Guard específico para favoritos ilimitados
  Future<PremiumAccessResult> checkUnlimitedFavorites(int currentCount) async {
    final accessResult = await checkFeatureAccess(PremiumFeature.unlimitedFavorites);
    
    if (!accessResult.hasAccess && currentCount >= maxFavoritesForFreeUser) {
      await _analyticsService.logEvent(
        ReceitaAgroAnalyticsEvent.premiumFeatureAttempted.eventName,
        {
          'feature_name': 'unlimited_favorites',
          'current_count': currentCount.toString(),
          'max_free_limit': maxFavoritesForFreeUser.toString(),
        },
      );
      
      return PremiumAccessResult.denied(
        PremiumFeature.unlimitedFavorites,
        'Free users can save up to $maxFavoritesForFreeUser favorites. Upgrade to Premium for unlimited favorites.',
      );
    }

    return accessResult;
  }

  /// Guard específico para sincronização de dados
  Future<PremiumAccessResult> checkDataSync() async {
    return await checkFeatureAccess(PremiumFeature.syncData);
  }

  /// Guard específico para conteúdo premium
  Future<PremiumAccessResult> checkPremiumContent() async {
    return await checkFeatureAccess(PremiumFeature.premiumContent);
  }

  /// Guard específico para comentários (com limite para usuários gratuitos)
  Future<PremiumAccessResult> checkUnlimitedComments(int currentCount) async {
    final subscriptionData = _premiumService.getCurrentSubscription();
    if (subscriptionData != null) {
      final subscription = SubscriptionEntity.fromFirebaseMap(
        Map<String, dynamic>.from(subscriptionData),
      );
      if (subscription.isActive) {
        return PremiumAccessResult.granted(PremiumFeature.premiumContent, subscription);
      }
    }
    if (currentCount >= maxCommentsForFreeUser) {
      await _analyticsService.logEvent(
        ReceitaAgroAnalyticsEvent.premiumFeatureAttempted.eventName,
        {
          'feature_name': 'unlimited_comments',
          'current_count': currentCount.toString(),
          'max_free_limit': maxCommentsForFreeUser.toString(),
        },
      );
      
      return PremiumAccessResult.denied(
        PremiumFeature.premiumContent,
        'Free users can create up to $maxCommentsForFreeUser comments. Upgrade to Premium for unlimited comments.',
      );
    }

    return const PremiumAccessResult(
      hasAccess: true,
      reason: 'Within free user limits',
      feature: PremiumFeature.premiumContent,
    );
  }

  /// Guard para busca avançada
  Future<PremiumAccessResult> checkAdvancedSearch() async {
    return await checkFeatureAccess(PremiumFeature.advancedSearch);
  }

  /// Guard para exportação de dados
  Future<PremiumAccessResult> checkDataExport() async {
    return await checkFeatureAccess(PremiumFeature.exportData);
  }

  /// Guard para modo offline
  Future<PremiumAccessResult> checkOfflineMode() async {
    return await checkFeatureAccess(PremiumFeature.offlineMode);
  }

  /// Verifica múltiplas features de uma vez
  Future<Map<PremiumFeature, PremiumAccessResult>> checkMultipleFeatures(
    List<PremiumFeature> features,
  ) async {
    final results = <PremiumFeature, PremiumAccessResult>{};
    
    for (final feature in features) {
      results[feature] = await checkFeatureAccess(feature);
    }
    
    return results;
  }

  /// Obtém lista de features disponíveis para o usuário atual
  Future<List<PremiumFeature>> getAvailableFeatures() async {
    final subscriptionData = _premiumService.getCurrentSubscription();
    
    if (subscriptionData == null) {
      return []; // Nenhuma feature premium disponível
    }
    
    final subscription = SubscriptionEntity.fromFirebaseMap(
      Map<String, dynamic>.from(subscriptionData),
    );
    if (!subscription.isActive) {
      return []; // Subscription inativa
    }
    
    return PremiumFeature.values
        .where((feature) => SubscriptionAdapter.hasFeature(subscription, feature.key))
        .toList();
  }

  /// Obtém informações sobre limites de uso para usuário gratuito
  Map<String, int> getFreeTierLimits() {
    return {
      'max_favorites': maxFavoritesForFreeUser,
      'max_comments': maxCommentsForFreeUser,
      'max_search_results': maxSearchResultsForFreeUser,
    };
  }

  /// Verifica se o usuário está próximo dos limites gratuitos
  Future<Map<String, dynamic>> checkUsageLimits({
    required int currentFavorites,
    required int currentComments,
  }) async {
    final subscriptionData = _premiumService.getCurrentSubscription();
    bool isPremium = false;
    
    if (subscriptionData != null) {
      final subscription = SubscriptionEntity.fromFirebaseMap(
        Map<String, dynamic>.from(subscriptionData),
      );
      isPremium = subscription.isActive;
    }
    
    if (isPremium) {
      return {
        'is_premium': true,
        'warnings': <String>[],
      };
    }

    final warnings = <String>[];
    final favoriteUsagePercent = (currentFavorites / maxFavoritesForFreeUser * 100).round();
    if (favoriteUsagePercent >= 80) {
      warnings.add('You have used $favoriteUsagePercent% of your free favorites ($currentFavorites/$maxFavoritesForFreeUser)');
    }
    final commentUsagePercent = (currentComments / maxCommentsForFreeUser * 100).round();
    if (commentUsagePercent >= 80) {
      warnings.add('You have used $commentUsagePercent% of your free comments ($currentComments/$maxCommentsForFreeUser)');
    }

    await _analyticsService.logEvent(
      ReceitaAgroAnalyticsEvent.featureUsed.eventName,
      {
        'feature_name': 'usage_limits_check',
        'favorite_usage_percent': favoriteUsagePercent.toString(),
        'comment_usage_percent': commentUsagePercent.toString(),
        'warnings_count': warnings.length.toString(),
      },
    );

    return {
      'is_premium': false,
      'warnings': warnings,
      'limits': {
        'favorites': {'current': currentFavorites, 'max': maxFavoritesForFreeUser},
        'comments': {'current': currentComments, 'max': maxCommentsForFreeUser},
      },
    };
  }

  /// Tracks quando acesso é negado
  Future<void> _trackAccessDenied(PremiumFeature feature, String reason) async {
    await _analyticsService.logEvent(
      ReceitaAgroAnalyticsEvent.premiumFeatureAttempted.eventName,
      {
        'feature_name': feature.key,
        'access_denied_reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Tracks quando acesso é permitido
  Future<void> _trackAccessGranted(PremiumFeature feature, SubscriptionEntity subscription) async {
    await _analyticsService.logEvent(
      ReceitaAgroAnalyticsEvent.featureUsed.eventName,
      {
        'feature_name': feature.key,
        'subscription_status': subscription.status.name,
        'subscription_product_id': subscription.productId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Tracks erros de verificação de acesso
  Future<void> _trackAccessError(PremiumFeature feature, String error) async {
    await _analyticsService.logEvent(
      ReceitaAgroAnalyticsEvent.errorOccurred.eventName,
      {
        'error_type': 'premium_access_check',
        'feature_name': feature.key,
        'error': error,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}

/// Widget helper para verificação de acesso premium
abstract class PremiumAccessWidget {
  static Future<T> guardedAction<T>({
    required PremiumGuards guards,
    required PremiumFeature feature,
    required Future<T> Function() premiumAction,
    required T Function() fallbackAction,
    VoidCallback? onAccessDenied,
  }) async {
    final accessResult = await guards.checkFeatureAccess(feature);
    
    if (accessResult.hasAccess) {
      return await premiumAction();
    } else {
      onAccessDenied?.call();
      return fallbackAction();
    }
  }
}

/// Exceção lançada quando acesso premium é negado
class PremiumAccessDeniedException implements Exception {
  final PremiumFeature feature;
  final String message;
  
  const PremiumAccessDeniedException(this.feature, this.message);
  
  @override
  String toString() => 'PremiumAccessDeniedException: $message (${feature.key})';
}
import 'dart:async';

import 'package:core/core.dart';

import '../../features/auth/domain/user_limits.dart';
import 'analytics_service.dart';
import 'crashlytics_service.dart';

/// Subscription service específico do app Task Manager
@lazySingleton
class TaskManagerSubscriptionService {
  final ISubscriptionRepository _subscriptionRepository;
  final TaskManagerAnalyticsService _analyticsService;
  final TaskManagerCrashlyticsService _crashlyticsService;

  TaskManagerSubscriptionService(
    this._subscriptionRepository,
    this._analyticsService,
    this._crashlyticsService,
  );
  static const String taskManagerMonthly = 'task_manager_premium_monthly';
  static const String taskManagerYearly = 'task_manager_premium_yearly';
  static const String taskManagerLifetime = 'task_manager_premium_lifetime';
  static const Map<String, List<String>> premiumFeatures = {
    'premium_monthly': [
      'unlimited_tasks',
      'unlimited_subtasks',
      'advanced_filtering',
      'custom_tags',
      'time_tracking',
      'productivity_analytics',
      'cloud_sync',
      'export_data',
    ],
    'premium_yearly': [
      'unlimited_tasks',
      'unlimited_subtasks',
      'advanced_filtering',
      'custom_tags',
      'time_tracking',
      'productivity_analytics',
      'cloud_sync',
      'export_data',
      'priority_support',
      'early_access_features',
    ],
    'premium_lifetime': [
      'unlimited_tasks',
      'unlimited_subtasks',
      'advanced_filtering',
      'custom_tags',
      'time_tracking',
      'productivity_analytics',
      'cloud_sync',
      'export_data',
      'priority_support',
      'early_access_features',
      'custom_themes',
      'api_access',
    ],
  };
  static const int maxFreeTasks = 50;
  static const int maxFreeSubtasks = 10;
  static const int maxFreeTags = 5;

  /// Stream do status da assinatura
  Stream<SubscriptionEntity?> get subscriptionStatus => 
      _subscriptionRepository.subscriptionStatus;

  /// Verifica se tem assinatura premium ativa
  Future<bool> hasPremiumSubscription() async {
    try {
      final result = await _subscriptionRepository.hasActiveSubscription();
      return result.fold(
        (failure) {
          _crashlyticsService.recordError(
            exception: failure,
            stackTrace: StackTrace.current,
            reason: 'Error checking premium subscription',
          );
          return false;
        },
        (hasActive) => hasActive,
      );
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Unexpected error checking premium subscription',
      );
      return false;
    }
  }

  /// Verifica se tem uma feature específica disponível
  Future<bool> hasFeature(String featureName) async {
    final hasPremium = await hasPremiumSubscription();
    
    if (!hasPremium) {
      const basicFeatures = [
        'create_tasks',
        'edit_tasks',
        'mark_complete',
        'basic_filtering',
        'simple_search',
      ];
      
      return basicFeatures.contains(featureName);
    }
    return true;
  }

  /// Verifica se pode criar mais tarefas
  Future<bool> canCreateMoreTasks(int currentTaskCount) async {
    final hasPremium = await hasPremiumSubscription();
    
    if (hasPremium) return true;
    
    return currentTaskCount < maxFreeTasks;
  }

  /// Verifica se pode criar mais subtarefas
  Future<bool> canCreateMoreSubtasks(int currentSubtaskCount) async {
    final hasPremium = await hasPremiumSubscription();
    
    if (hasPremium) return true;
    
    return currentSubtaskCount < maxFreeSubtasks;
  }

  /// Verifica se pode criar mais tags
  Future<bool> canCreateMoreTags(int currentTagCount) async {
    final hasPremium = await hasPremiumSubscription();
    
    if (hasPremium) return true;
    
    return currentTagCount < maxFreeTags;
  }

  /// Obtém produtos disponíveis do Task Manager
  Future<List<ProductInfo>> getTaskManagerProducts() async {
    try {
      final result = await _subscriptionRepository.getAvailableProducts(
        productIds: [
          taskManagerMonthly,
          taskManagerYearly,
          taskManagerLifetime,
        ],
      );

      return result.fold(
        (failure) {
          _crashlyticsService.recordError(
            exception: failure,
            stackTrace: StackTrace.current,
            reason: 'Error getting Task Manager products',
          );
          return <ProductInfo>[];
        },
        (products) {
          _analyticsService.logEvent('products_loaded', parameters: {
            'product_count': products.length,
            'available_products': products.map((p) => p.productId).join(','),
          });
          return products;
        },
      );
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Unexpected error getting products',
      );
      return <ProductInfo>[];
    }
  }

  /// Compra um produto
  Future<bool> purchaseProduct(String productId) async {
    try {
      await _analyticsService.logEvent('purchase_initiated', parameters: {
        'product_id': productId,
        'app': 'task_manager',
      });

      final result = await _subscriptionRepository.purchaseProduct(
        productId: productId,
      );

      return result.fold(
        (failure) {
          _crashlyticsService.recordError(
            exception: failure,
            stackTrace: StackTrace.current,
            reason: 'Purchase failed',
            additionalInfo: {'product_id': productId},
          );

          _analyticsService.logEvent('purchase_failed', parameters: {
            'product_id': productId,
            'error': failure.toString(),
          });

          return false;
        },
        (subscription) {
          _analyticsService.logPurchase(
            productId: productId,
            price: _getPriceFromProductId(productId),
            currency: 'BRL',
          );

          _analyticsService.logEvent('premium_activated', parameters: {
            'product_id': productId,
            'tier': subscription.tier.toString(),
            'is_trial': subscription.isInTrial,
          });

          return true;
        },
      );
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Unexpected error during purchase',
        additionalInfo: {'product_id': productId},
      );

      await _analyticsService.logError(
        error: 'Purchase error: $e',
        additionalInfo: {'product_id': productId},
      );

      return false;
    }
  }

  /// Restaura compras
  Future<bool> restorePurchases() async {
    try {
      await _analyticsService.logEvent('restore_purchases_initiated');

      final result = await _subscriptionRepository.restorePurchases();

      return result.fold(
        (failure) {
          _crashlyticsService.recordError(
            exception: failure,
            stackTrace: StackTrace.current,
            reason: 'Restore purchases failed',
          );

          _analyticsService.logEvent('restore_purchases_failed', parameters: {
            'error': failure.toString(),
          });

          return false;
        },
        (subscriptions) {
          _analyticsService.logEvent('restore_purchases_success', parameters: {
            'restored_count': subscriptions.length,
            'has_active': subscriptions.any((s) => s.isActive),
          });

          return subscriptions.isNotEmpty;
        },
      );
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Unexpected error during restore',
      );

      return false;
    }
  }

  /// Configura usuário no RevenueCat
  Future<void> setUser(String userId, {Map<String, String>? attributes}) async {
    try {
      final userAttributes = {
        'app': 'task_manager',
        'platform': 'flutter',
        ...?attributes,
      };

      final result = await _subscriptionRepository.setUser(
        userId: userId,
        attributes: userAttributes,
      );

      result.fold(
        (failure) {
          _crashlyticsService.recordError(
            exception: failure,
            stackTrace: StackTrace.current,
            reason: 'Error setting user in RevenueCat',
            additionalInfo: {'user_id': userId},
          );
        },
        (_) {
          _analyticsService.setUserId(userId);
          _analyticsService.logEvent('revenue_cat_user_set', parameters: {
            'user_id': userId,
          });
        },
      );
    } catch (e, stackTrace) {
      await _crashlyticsService.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Unexpected error setting user',
        additionalInfo: {'user_id': userId},
      );
    }
  }

  /// Obtém informações sobre limites atuais do usuário
  Future<UserLimits> getUserLimits({
    required int currentTasks,
    required int currentSubtasks,
    required int currentTags,
    int completedTasks = 0,
    int completedSubtasks = 0,
  }) async {
    final hasPremium = await hasPremiumSubscription();

    if (hasPremium) {
      return UserLimits.premium(
        currentTasks: currentTasks,
        currentSubtasks: currentSubtasks,
        currentTags: currentTags,
      );
    }

    return UserLimits.free(
      currentTasks: currentTasks,
      currentSubtasks: currentSubtasks,
      currentTags: currentTags,
    );
  }

  /// Obtém features disponíveis para o usuário atual
  Future<List<String>> getAvailableFeatures() async {
    final hasPremium = await hasPremiumSubscription();
    
    if (!hasPremium) {
      return const [
        'create_tasks',
        'edit_tasks',
        'mark_complete',
        'basic_filtering',
        'simple_search',
        'local_storage',
      ];
    }

    final subscription = await _subscriptionRepository.getCurrentSubscription();
    return subscription.fold(
      (failure) => <String>[],
      (subscription) {
        if (subscription == null) return <String>[];
        
        final productId = subscription.productId.toLowerCase();
        
        if (productId.contains('lifetime')) {
          return premiumFeatures['premium_lifetime'] ?? <String>[];
        } else if (productId.contains('yearly')) {
          return premiumFeatures['premium_yearly'] ?? <String>[];
        } else {
          return premiumFeatures['premium_monthly'] ?? <String>[];
        }
      },
    );
  }

  /// Verifica se está elegível para trial
  Future<bool> isEligibleForTrial() async {
    try {
      final result = await _subscriptionRepository.isEligibleForTrial(
        productId: taskManagerMonthly,
      );

      return result.fold(
        (failure) => false,
        (eligible) => eligible,
      );
    } catch (e) {
      return false;
    }
  }

  /// Obtém URL de gerenciamento da assinatura
  Future<String?> getManagementUrl() async {
    try {
      final result = await _subscriptionRepository.getManagementUrl();
      return result.fold(
        (failure) => null,
        (url) => url,
      );
    } catch (e) {
      return null;
    }
  }

  /// Helper para obter preço baseado no produto ID
  double _getPriceFromProductId(String productId) {
    switch (productId) {
      case taskManagerMonthly:
        return 9.90;
      case taskManagerYearly:
        return 89.90;
      case taskManagerLifetime:
        return 199.90;
      default:
        return 0.0;
    }
  }
  Future<SubscriptionEntity?> getCurrentSubscription() async {
    final result = await _subscriptionRepository.getCurrentSubscription();
    return result.fold(
      (failure) => null,
      (subscription) => subscription,
    );
  }

  Future<List<SubscriptionEntity>> getUserSubscriptions() async {
    final result = await _subscriptionRepository.getUserSubscriptions();
    return result.fold(
      (failure) => <SubscriptionEntity>[],
      (subscriptions) => subscriptions,
    );
  }
}


import 'package:core/core.dart';
import 'package:core/src/services/optimized_analytics_wrapper.dart';
import 'package:injectable/injectable.dart';

/// Service for tracking analytics events in NebulaList
/// Uses OptimizedAnalyticsWrapper from core package for efficient event logging
@lazySingleton
class AnalyticsService {
  final OptimizedAnalyticsWrapper _analytics;

  AnalyticsService(this._analytics);

  // ==================== Lists Events ====================

  /// Tracks when a new list is created
  Future<void> logListCreated({
    required String listId,
    String? category,
  }) async {
    await _analytics.logEvent('list_created', parameters: {
      'list_id': listId,
      'category': category ?? 'outros',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Tracks when a list is updated
  Future<void> logListUpdated({required String listId}) async {
    await _analytics.logEvent('list_updated', parameters: {
      'list_id': listId,
    });
  }

  /// Tracks when a list is deleted
  Future<void> logListDeleted({
    required String listId,
    required bool hardDelete,
  }) async {
    await _analytics.logEvent('list_deleted', parameters: {
      'list_id': listId,
      'hard_delete': hardDelete,
    });
  }

  /// Tracks when a list favorite status changes
  Future<void> logListFavorited({
    required String listId,
    required bool isFavorite,
  }) async {
    await _analytics.logEvent('list_favorited', parameters: {
      'list_id': listId,
      'is_favorite': isFavorite,
    });
  }

  /// Tracks when a list is shared (critical event)
  Future<void> logListShared({required String listId}) async {
    await _analytics.logEvent(
      'list_shared',
      parameters: {
        'list_id': listId,
        'timestamp': DateTime.now().toIso8601String(),
      },
      forceCritical: true, // Don't debounce sharing events
    );
  }

  // ==================== Items Events ====================

  /// Tracks when a new ItemMaster is created
  Future<void> logItemMasterCreated({
    required String itemId,
    String? category,
  }) async {
    await _analytics.logEvent('item_master_created', parameters: {
      'item_id': itemId,
      'category': category ?? 'outros',
    });
  }

  /// Tracks when an ItemMaster is updated
  Future<void> logItemMasterUpdated({required String itemId}) async {
    await _analytics.logEvent('item_master_updated', parameters: {
      'item_id': itemId,
    });
  }

  /// Tracks when an ItemMaster is deleted
  Future<void> logItemMasterDeleted({required String itemId}) async {
    await _analytics.logEvent('item_master_deleted', parameters: {
      'item_id': itemId,
    });
  }

  /// Tracks when an item is added to a list
  Future<void> logItemAddedToList({
    required String itemId,
    required String listId,
  }) async {
    await _analytics.logEvent('item_added_to_list', parameters: {
      'item_id': itemId,
      'list_id': listId,
    });
  }

  /// Tracks when an item is marked as completed
  Future<void> logItemCompleted({
    required String itemId,
    required String listId,
  }) async {
    await _analytics.logEvent('item_completed', parameters: {
      'item_id': itemId,
      'list_id': listId,
    });
  }

  /// Tracks when an item is removed from a list
  Future<void> logItemRemovedFromList({
    required String itemId,
    required String listId,
  }) async {
    await _analytics.logEvent('item_removed_from_list', parameters: {
      'item_id': itemId,
      'list_id': listId,
    });
  }

  // ==================== User Engagement ====================

  /// Tracks screen views
  Future<void> logScreenView(String screenName) async {
    await _analytics.logEvent('screen_view', parameters: {
      'screen_name': screenName,
    });
  }

  /// Tracks search queries
  Future<void> logSearch({
    required String query,
    required String context,
  }) async {
    await _analytics.logEvent('search', parameters: {
      'query': query,
      'context': context, // 'lists' or 'items'
    });
  }

  /// Tracks when user views premium features
  Future<void> logPremiumFeatureViewed({required String feature}) async {
    await _analytics.logEvent('premium_feature_viewed', parameters: {
      'feature': feature,
    });
  }

  /// Tracks when user hits free tier limits
  Future<void> logFreeTierLimitReached({required String limitType}) async {
    await _analytics.logEvent('free_tier_limit_reached', parameters: {
      'limit_type': limitType, // 'lists' or 'items'
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ==================== App Lifecycle ====================

  /// Tracks app opened
  Future<void> logAppOpened() async {
    await _analytics.logEvent('app_opened', parameters: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Tracks app closed
  Future<void> logAppClosed() async {
    await _analytics.logEvent('app_closed', parameters: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ==================== Generic Events ====================

  /// Generic event logging method for custom events
  /// Use specific methods above when available for better type safety
  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
    bool forceCritical = false,
  }) async {
    await _analytics.logEvent(
      eventName,
      parameters: parameters,
      forceCritical: forceCritical,
    );
  }

  /// Flush pending events (call on app close or important moments)
  Future<void> flush() async {
    await _analytics.flush();
  }
}

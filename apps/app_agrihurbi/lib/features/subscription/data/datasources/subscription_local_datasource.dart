import 'package:injectable/injectable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_agrihurbi/core/error/exceptions.dart';
import 'package:app_agrihurbi/features/subscription/data/models/subscription_model.dart';

/// Subscription Local Data Source
@injectable
class SubscriptionLocalDataSource {
  static const String _subscriptionBoxName = 'user_subscription';
  static const String _featureUsageBoxName = 'feature_usage';

  Box<SubscriptionModel> get _subscriptionBox => Hive.box<SubscriptionModel>(_subscriptionBoxName);
  Box<Map<String, dynamic>> get _featureUsageBox => Hive.box<Map<String, dynamic>>(_featureUsageBoxName);

  static Future<void> initialize() async {
    await Hive.openBox<SubscriptionModel>(_subscriptionBoxName);
    await Hive.openBox<Map<String, dynamic>>(_featureUsageBoxName);
  }

  /// Cache subscription
  Future<void> cacheSubscription(SubscriptionModel subscription) async {
    try {
      await _subscriptionBox.put('current', subscription);
    } catch (e) {
      throw CacheException('Failed to cache subscription: $e');
    }
  }

  /// Get cached subscription
  Future<SubscriptionModel?> getCachedSubscription() async {
    try {
      return _subscriptionBox.get('current');
    } catch (e) {
      throw CacheException('Failed to get cached subscription: $e');
    }
  }

  /// Record feature usage
  Future<void> recordFeatureUsage(PremiumFeatureModel feature, int usage) async {
    try {
      final key = feature.name;
      final existing = _featureUsageBox.get(key) ?? {'usage': 0, 'resetDate': DateTime.now().toIso8601String()};
      existing['usage'] = (existing['usage'] ?? 0) + usage;
      await _featureUsageBox.put(key, existing);
    } catch (e) {
      throw CacheException('Failed to record feature usage: $e');
    }
  }

  /// Get feature usage
  Future<Map<String, dynamic>?> getFeatureUsage(PremiumFeatureModel feature) async {
    try {
      return _featureUsageBox.get(feature.name);
    } catch (e) {
      throw CacheException('Failed to get feature usage: $e');
    }
  }

  /// Clear subscription cache
  Future<void> clearSubscriptionCache() async {
    try {
      await _subscriptionBox.clear();
      await _featureUsageBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear subscription cache: $e');
    }
  }
}
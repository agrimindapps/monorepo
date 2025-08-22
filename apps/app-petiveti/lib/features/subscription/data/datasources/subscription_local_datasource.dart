import '../models/subscription_plan_model.dart';
import '../models/user_subscription_model.dart';

abstract class SubscriptionLocalDataSource {
  Future<List<SubscriptionPlanModel>> getAvailablePlans();
  Future<UserSubscriptionModel?> getCurrentSubscription(String userId);
  Future<void> cacheSubscription(UserSubscriptionModel subscription);
  Future<void> clearSubscription(String userId);
  Future<void> cachePlans(List<SubscriptionPlanModel> plans);
}

class SubscriptionLocalDataSourceImpl implements SubscriptionLocalDataSource {
  final Map<String, UserSubscriptionModel> _subscriptionsCache = {};
  List<SubscriptionPlanModel> _plansCache = [];

  @override
  Future<List<SubscriptionPlanModel>> getAvailablePlans() async {
    return _plansCache;
  }

  @override
  Future<UserSubscriptionModel?> getCurrentSubscription(String userId) async {
    return _subscriptionsCache[userId];
  }

  @override
  Future<void> cacheSubscription(UserSubscriptionModel subscription) async {
    _subscriptionsCache[subscription.userId] = subscription;
  }

  @override
  Future<void> clearSubscription(String userId) async {
    _subscriptionsCache.remove(userId);
  }

  @override
  Future<void> cachePlans(List<SubscriptionPlanModel> plans) async {
    _plansCache = plans;
  }
}
import 'package:injectable/injectable.dart';
import 'package:app_agrihurbi/core/error/exceptions.dart';
import 'package:app_agrihurbi/core/network/dio_client.dart';
import 'package:app_agrihurbi/features/subscription/data/models/subscription_model.dart';

/// Subscription Remote Data Source
@injectable
class SubscriptionRemoteDataSource {
  final DioClient _client;

  const SubscriptionRemoteDataSource(this._client);

  /// Get current subscription
  Future<SubscriptionModel?> getCurrentSubscription(String userId) async {
    try {
      final response = await _client.get('/api/v1/subscriptions/current');
      if (response.data == null) return null;
      return SubscriptionModel.fromJson(response.data);
    } catch (e) {
      throw ServerException('Failed to get current subscription: $e');
    }
  }

  /// Create subscription
  Future<SubscriptionModel> createSubscription(Map<String, dynamic> subscriptionData) async {
    try {
      final response = await _client.post('/api/v1/subscriptions', data: subscriptionData);
      return SubscriptionModel.fromJson(response.data);
    } catch (e) {
      throw ServerException('Failed to create subscription: $e');
    }
  }

  /// Update subscription
  Future<SubscriptionModel> updateSubscription(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client.put('/api/v1/subscriptions/$id', data: data);
      return SubscriptionModel.fromJson(response.data);
    } catch (e) {
      throw ServerException('Failed to update subscription: $e');
    }
  }

  /// Cancel subscription
  Future<void> cancelSubscription(String id) async {
    try {
      await _client.delete('/api/v1/subscriptions/$id');
    } catch (e) {
      throw ServerException('Failed to cancel subscription: $e');
    }
  }

  /// Get subscription plans
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final response = await _client.get('/api/v1/subscription-plans');
      return List<Map<String, dynamic>>.from(response.data['plans'] ?? []);
    } catch (e) {
      throw ServerException('Failed to get subscription plans: $e');
    }
  }

  /// Apply promo code
  Future<Map<String, dynamic>> applyPromoCode(String code) async {
    try {
      final response = await _client.post('/api/v1/promo-codes/apply', data: {'code': code});
      return response.data;
    } catch (e) {
      throw ServerException('Failed to apply promo code: $e');
    }
  }
}
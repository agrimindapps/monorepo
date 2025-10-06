import 'dart:async';
import 'package:flutter/foundation.dart';
import '../interfaces/i_premium_service.dart';

/// Mock implementation of IPremiumService for development and testing
class MockPremiumService extends ChangeNotifier implements IPremiumService {
  PremiumStatus _status = const PremiumStatus(isActive: false);
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();

  @override
  bool get isPremium => _status.isActive;

  @override
  PremiumStatus get status => _status;

  @override
  bool get shouldShowPremiumDialogs => true; // Mock always shows dialogs

  @override
  Stream<bool> get premiumStatusStream => _statusController.stream;

  @override
  String? get upgradeUrl => 'https://example.com/premium';
  @override
  Future<void> checkPremiumStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<bool> isPremiumUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _status.isActive;
  }

  @override
  Future<String?> getSubscriptionType() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _status.planType;
  }

  @override
  Future<DateTime?> getSubscriptionExpiry() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _status.expiryDate;
  }

  @override
  Future<bool> isSubscriptionActive() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _status.isActive;
  }

  @override
  Future<int> getRemainingDays() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (_status.expiryDate == null) return 0;
    final now = DateTime.now();
    final difference = _status.expiryDate!.difference(now);
    return difference.inDays > 0 ? difference.inDays : 0;
  }

  @override
  Future<void> refreshPremiumStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    notifyListeners();
    _statusController.add(_status.isActive);
  }
  @override
  bool canUseFeature(String featureName) {
    if (_status.isActive) return true;
    const freeFeatures = ['basic_search', 'limited_results'];
    return freeFeatures.contains(featureName);
  }

  @override
  Future<bool> hasFeatureAccess(String featureId) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return canUseFeature(featureId);
  }

  @override
  int getFeatureLimit(String featureName) {
    if (_status.isActive) return -1; // Unlimited for premium
    switch (featureName) {
      case 'search_results':
        return 10;
      case 'favorites':
        return 5;
      case 'diagnostics_per_day':
        return 3;
      default:
        return 0;
    }
  }

  @override
  bool hasReachedLimit(String featureName, int currentUsage) {
    final limit = getFeatureLimit(featureName);
    if (limit == -1) return false; // No limit
    return currentUsage >= limit;
  }

  @override
  Future<List<String>> getPremiumFeatures() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [
      'unlimited_search',
      'unlimited_favorites',
      'unlimited_diagnostics',
      'premium_recommendations',
      'advanced_filters',
      'export_data',
    ];
  }
  @override
  Future<bool> isTrialAvailable() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return !_status.isActive && !_status.isTestSubscription;
  }

  @override
  Future<bool> startTrial() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    if (await isTrialAvailable()) {
      _status = PremiumStatus(
        isActive: true,
        isTestSubscription: true,
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        planType: 'Trial',
      );
      
      notifyListeners();
      _statusController.add(true);
      return true;
    }
    return false;
  }
  @override
  Future<void> generateTestSubscription() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    _status = PremiumStatus(
      isActive: true,
      isTestSubscription: true,
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      planType: 'Test Premium',
    );
    
    notifyListeners();
    _statusController.add(true);
  }

  @override
  Future<void> removeTestSubscription() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    
    if (_status.isTestSubscription) {
      _status = const PremiumStatus(isActive: false);
      notifyListeners();
      _statusController.add(false);
    }
  }
  @override
  Future<void> navigateToPremium() async {
    if (kDebugMode) print('Navigate to premium page');
  }

  @override
  void dispose() {
    _statusController.close();
    super.dispose();
  }
}

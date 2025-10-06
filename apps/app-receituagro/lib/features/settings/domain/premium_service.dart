import 'package:flutter/foundation.dart';

/// Interface for premium subscription management
abstract class IPremiumService extends ChangeNotifier {
  /// Whether the user has premium access
  bool get isPremium;
  
  /// Premium status information
  PremiumStatus get status;
  
  /// Whether should show premium dialogs (not for anonymous users)
  bool get shouldShowPremiumDialogs;
  
  /// Generate a test subscription for development
  Future<void> generateTestSubscription();
  
  /// Remove test subscription
  Future<void> removeTestSubscription();
  
  /// Navigate to premium/subscription page
  Future<void> navigateToPremium();
  
  /// Check premium status
  Future<void> checkPremiumStatus();
}

/// Premium status information
class PremiumStatus {
  final bool isActive;
  final bool isTestSubscription;
  final DateTime? expiryDate;
  final String? planType;
  
  const PremiumStatus({
    required this.isActive,
    this.isTestSubscription = false,
    this.expiryDate,
    this.planType,
  });
  
  PremiumStatus copyWith({
    bool? isActive,
    bool? isTestSubscription,
    DateTime? expiryDate,
    String? planType,
  }) {
    return PremiumStatus(
      isActive: isActive ?? this.isActive,
      isTestSubscription: isTestSubscription ?? this.isTestSubscription,
      expiryDate: expiryDate ?? this.expiryDate,
      planType: planType ?? this.planType,
    );
  }
}

/// Mock implementation for development
class MockPremiumService extends ChangeNotifier implements IPremiumService {
  PremiumStatus _status = const PremiumStatus(isActive: false);
  
  @override
  bool get isPremium => _status.isActive;
  
  @override
  PremiumStatus get status => _status;
  
  @override
  bool get shouldShowPremiumDialogs {
    return true;
  }
  
  @override
  Future<void> generateTestSubscription() async {
    await Future<void>.delayed(const Duration(milliseconds: 500)); // Simulate API call
    
    _status = PremiumStatus(
      isActive: true,
      isTestSubscription: true,
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      planType: 'Test Premium',
    );
    
    notifyListeners();
  }
  
  @override
  Future<void> removeTestSubscription() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    
    if (_status.isTestSubscription) {
      _status = const PremiumStatus(isActive: false);
      notifyListeners();
    }
  }
  
  @override
  Future<void> navigateToPremium() async {
    debugPrint('Navigate to premium page');
  }
  
  @override
  Future<void> checkPremiumStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

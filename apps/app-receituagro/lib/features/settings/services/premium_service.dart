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
    // Don't show premium dialogs for anonymous users
    // In a real implementation, this should check the auth service
    // For now, we'll return true to maintain current behavior
    // TODO: Integrate with proper auth service when available
    return true;
  }
  
  @override
  Future<void> generateTestSubscription() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    
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
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_status.isTestSubscription) {
      _status = const PremiumStatus(isActive: false);
      notifyListeners();
    }
  }
  
  @override
  Future<void> navigateToPremium() async {
    // Mock navigation - in real implementation would use Navigator/GetX
    debugPrint('Navigate to premium page');
  }
  
  @override
  Future<void> checkPremiumStatus() async {
    // Mock status check - in real implementation would check with backend
    await Future.delayed(const Duration(milliseconds: 200));
    // Status remains unchanged in mock
  }
}
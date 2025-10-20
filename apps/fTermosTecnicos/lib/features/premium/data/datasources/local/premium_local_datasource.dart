import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../models/subscription_status_model.dart';

/// Interface for premium local data source
abstract class PremiumLocalDataSource {
  Future<SubscriptionStatusModel> checkSubscriptionStatus();
  Future<SubscriptionStatusModel> restorePurchases();
  Future<List<Package>> getAvailablePackages();
  Future<bool> purchasePackage(Package package);
}

/// Implementation of premium local data source using RevenueCat
/// Note: This uses RevenueCat from core package services
@LazySingleton(as: PremiumLocalDataSource)
class PremiumLocalDataSourceImpl implements PremiumLocalDataSource {
  PremiumLocalDataSourceImpl();

  @override
  Future<SubscriptionStatusModel> checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      // Check if user has any active entitlement
      final isPremium = customerInfo.entitlements.active.isNotEmpty;

      // Get subscription info from active entitlements
      String? subscriptionType;
      DateTime? expirationDate;
      DateTime? startDate;
      bool isActive = false;

      if (isPremium) {
        final activeEntitlement = customerInfo.entitlements.active.values.first;
        subscriptionType = activeEntitlement.identifier;
        expirationDate = activeEntitlement.expirationDate != null
            ? DateTime.parse(activeEntitlement.expirationDate!)
            : null;
        startDate = activeEntitlement.latestPurchaseDate != null
            ? DateTime.parse(activeEntitlement.latestPurchaseDate!)
            : null;
        isActive = true;
      }

      return SubscriptionStatusModel(
        isPremium: isPremium,
        subscriptionType: subscriptionType,
        expirationDate: expirationDate,
        startDate: startDate,
        isActive: isActive,
      );
    } catch (e) {
      throw Exception('Failed to check subscription status: $e');
    }
  }

  @override
  Future<SubscriptionStatusModel> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();

      final isPremium = customerInfo.entitlements.active.isNotEmpty;

      String? subscriptionType;
      DateTime? expirationDate;
      DateTime? startDate;
      bool isActive = false;

      if (isPremium) {
        final activeEntitlement = customerInfo.entitlements.active.values.first;
        subscriptionType = activeEntitlement.identifier;
        expirationDate = activeEntitlement.expirationDate != null
            ? DateTime.parse(activeEntitlement.expirationDate!)
            : null;
        startDate = activeEntitlement.latestPurchaseDate != null
            ? DateTime.parse(activeEntitlement.latestPurchaseDate!)
            : null;
        isActive = true;
      }

      return SubscriptionStatusModel(
        isPremium: isPremium,
        subscriptionType: subscriptionType,
        expirationDate: expirationDate,
        startDate: startDate,
        isActive: isActive,
      );
    } catch (e) {
      throw Exception('Failed to restore purchases: $e');
    }
  }

  @override
  Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get available packages: $e');
    }
  }

  @override
  Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      return result.customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to purchase package: $e');
    }
  }
}

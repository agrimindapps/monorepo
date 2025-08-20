// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../models/subscription_model.dart';

// Helper function to safely convert dates
String? _dateToIso8601String(dynamic date) {
  if (date == null) return null;
  if (date is DateTime) return date.toIso8601String();
  if (date is String && date.isNotEmpty) return date;
  return null;
}

DateTime? _stringOrDateTimeToDateTime(dynamic date) {
  if (date == null) return null;
  if (date is DateTime) return date;
  if (date is String && date.isNotEmpty) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }
  return null;
}

// Helper extension to handle date conversion
extension DateHelper on EntitlementInfo {
  DateTime? get safeDateExpiration {
    return _stringOrDateTimeToDateTime(expirationDate);
  }
  
  DateTime? get safeDateLatestPurchase {
    return _stringOrDateTimeToDateTime(latestPurchaseDate);
  }
  
  DateTime? get safeDateOriginalPurchase {
    return _stringOrDateTimeToDateTime(originalPurchaseDate);
  }
}

class SubscriptionService {
  Future<SubscriptionData> loadSubscriptionData() async {
    try {
      // This would integrate with RevenueCat or other subscription service
      // For now, return empty data
      return SubscriptionData.empty();
    } catch (e) {
      throw Exception('Failed to load subscription data: $e');
    }
  }

  Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<DateTime?> getSubscriptionEndDate() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.active.isEmpty) return null;
      
      final entitlement = customerInfo.entitlements.active.values.first;
      return entitlement.safeDateExpiration;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getActiveProductIds() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.keys.toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getSubscriptionInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final hasActive = customerInfo.entitlements.active.isNotEmpty;
      
      DateTime? endDate;
      String? currentPlan;
      
      if (hasActive) {
        final entitlement = customerInfo.entitlements.active.values.first;
        endDate = entitlement.safeDateExpiration;
        currentPlan = entitlement.productIdentifier;
      }
      
      return {
        'hasActiveSubscription': hasActive,
        'subscriptionEndDate': endDate?.toIso8601String(),
        'currentPlan': currentPlan,
        'activeEntitlements': customerInfo.entitlements.active.keys.toList(),
        'allPurchasedProducts': customerInfo.allPurchasedProductIdentifiers.toList(),
      };
    } catch (e) {
      return {
        'hasActiveSubscription': false,
        'error': e.toString(),
      };
    }
  }

  Future<bool> isEntitlementActive(String entitlementId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(entitlementId);
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getEntitlementInfo(String entitlementId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementId];
      
      if (entitlement == null) {
        return {'exists': false};
      }
      
      return {
        'exists': true,
        'isActive': entitlement.isActive,
        'willRenew': entitlement.willRenew,
        'expirationDate': _dateToIso8601String(entitlement.expirationDate),
        'latestPurchaseDate': _dateToIso8601String(entitlement.latestPurchaseDate),
        'originalPurchaseDate': _dateToIso8601String(entitlement.originalPurchaseDate),
        'productIdentifier': entitlement.productIdentifier,
        'store': entitlement.store.name,
      };
    } catch (e) {
      return {
        'exists': false,
        'error': e.toString(),
      };
    }
  }

  String formatSubscriptionStatus(CustomerInfo customerInfo) {
    if (customerInfo.entitlements.active.isEmpty) {
      return 'Nenhuma assinatura ativa';
    }
    
    final entitlement = customerInfo.entitlements.active.values.first;
    final endDate = entitlement.safeDateExpiration;
    
    if (endDate == null) {
      return 'Assinatura ativa (vitalícia)';
    }
    
    final now = DateTime.now();
    final daysLeft = endDate.difference(now).inDays;
    
    if (daysLeft > 30) {
      return 'Assinatura ativa';
    } else if (daysLeft > 7) {
      return 'Assinatura ativa ($daysLeft dias restantes)';
    } else if (daysLeft > 0) {
      return 'Assinatura expira em $daysLeft dias';
    } else {
      return 'Assinatura expirada';
    }
  }

  Future<List<Map<String, dynamic>>> getPurchaseHistory() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final history = <Map<String, dynamic>>[];
      
      for (final transaction in customerInfo.nonSubscriptionTransactions) {
        history.add({
          'productId': transaction.productIdentifier,
          'purchaseDate': _dateToIso8601String(transaction.purchaseDate),
          'storeTransactionId': transaction.transactionIdentifier,
        });
      }
      
      // Add subscription transactions
      for (final entitlement in customerInfo.entitlements.all.values) {
        history.add({
          'productId': entitlement.productIdentifier,
          'purchaseDate': _dateToIso8601String(entitlement.latestPurchaseDate),
          'originalPurchaseDate': _dateToIso8601String(entitlement.originalPurchaseDate),
          'expirationDate': _dateToIso8601String(entitlement.expirationDate),
          'isActive': entitlement.isActive,
          'willRenew': entitlement.willRenew,
          'store': entitlement.store.name,
          'type': 'subscription',
        });
      }
      
      // Sort by purchase date (newest first)
      history.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['purchaseDate'] ?? '');
          final dateB = DateTime.parse(b['purchaseDate'] ?? '');
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0; // Keep original order if parsing fails
        }
      });
      
      return history;
    } catch (e) {
      return [];
    }
  }
}

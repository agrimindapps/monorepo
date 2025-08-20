// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../models/purchase_state_model.dart';

class RevenuecatWrapperService {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize({
    required Store store,
    required String apiKey,
  }) async {
    if (_isInitialized) return;

    try {
      await Purchases.setLogLevel(LogLevel.info);
      
      PurchasesConfiguration configuration;
      if (store == Store.appStore) {
        configuration = PurchasesConfiguration(apiKey);
      } else {
        configuration = PurchasesConfiguration(apiKey);
      }
      
      await Purchases.configure(configuration);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize RevenueCat: $e');
    }
  }

  Future<Offering?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current;
    } catch (e) {
      throw Exception('Failed to get offerings: $e');
    }
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      return null;
    }
  }

  Future<PurchaseResult> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      
      if (customerInfo.entitlements.active.isNotEmpty) {
        return PurchaseResult.successful(
          package: package,
          customerInfo: customerInfo,
        );
      } else {
        return PurchaseResult.failed('Purchase was not activated properly');
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled();
      } else {
        return PurchaseResult.failed(_getErrorMessage(e));
      }
    } catch (e) {
      return PurchaseResult.failed('Unexpected error during purchase: $e');
    }
  }

  Future<RestoreResult> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      
      if (customerInfo.entitlements.active.isNotEmpty) {
        final restoredProducts = customerInfo.entitlements.active.keys.toList();
        return RestoreResult.successful(
          restoredProducts: restoredProducts,
          customerInfo: customerInfo,
        );
      } else {
        return RestoreResult.noProducts();
      }
    } on PlatformException catch (e) {
      return RestoreResult.failed(_getErrorMessage(e));
    } catch (e) {
      return RestoreResult.failed('Unexpected error during restore: $e');
    }
  }

  Future<bool> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logOut() async {
    try {
      await Purchases.logOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setAttributes(Map<String, String> attributes) async {
    try {
      await Purchases.setAttributes(attributes);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setEmail(String email) async {
    try {
      await Purchases.setEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setPhoneNumber(String phoneNumber) async {
    try {
      await Purchases.setPhoneNumber(phoneNumber);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setDisplayName(String displayName) async {
    try {
      await Purchases.setDisplayName(displayName);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> syncPurchases() async {
    try {
      await Purchases.syncPurchases();
    } catch (e) {
      // Sync errors are not critical
    }
  }

  Future<bool> checkTrialOrIntroductoryPriceEligibility(List<String> productIds) async {
    try {
      final result = await Purchases.checkTrialOrIntroductoryPriceEligibility(productIds);
      return result.values.any((eligibility) => 
          eligibility.status == IntroEligibilityStatus.introEligibilityStatusEligible);
    } catch (e) {
      return false;
    }
  }

  Future<void> invalidateCustomerInfoCache() async {
    try {
      await Purchases.invalidateCustomerInfoCache();
    } catch (e) {
      // Cache invalidation errors are not critical
    }
  }

  String _getErrorMessage(PlatformException error) {
    final errorCode = PurchasesErrorHelper.getErrorCode(error);
    
    switch (errorCode) {
      case PurchasesErrorCode.networkError:
        return 'Network error. Check your internet connection.';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Purchases not allowed on this device.';
      case PurchasesErrorCode.purchaseInvalidError:
        return 'Product not available for purchase.';
      case PurchasesErrorCode.purchaseCancelledError:
        return 'Purchase cancelled by user.';
      case PurchasesErrorCode.storeProblemError:
        return 'Store problem. Try again later.';
      case PurchasesErrorCode.paymentPendingError:
        return 'Payment pending. Please wait for confirmation.';
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return 'Receipt already in use.';
      case PurchasesErrorCode.missingReceiptFileError:
        return 'Receipt file not found.';
      case PurchasesErrorCode.invalidReceiptError:
        return 'Invalid receipt.';
      case PurchasesErrorCode.invalidCredentialsError:
        return 'Invalid credentials.';
      case PurchasesErrorCode.unexpectedBackendResponseError:
        return 'Unexpected server response.';
      case PurchasesErrorCode.configurationError:
        return 'Configuration error.';
      case PurchasesErrorCode.unknownError:
      default:
        return error.message ?? 'Unknown error occurred.';
    }
  }

  // Debug and testing methods
  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final offerings = await Purchases.getOfferings();
      
      return {
        'isInitialized': _isInitialized,
        'customerInfo': {
          'originalAppUserId': customerInfo.originalAppUserId,
          'hasActiveEntitlements': customerInfo.entitlements.active.isNotEmpty,
          'activeEntitlements': customerInfo.entitlements.active.keys.toList(),
          'allEntitlements': customerInfo.entitlements.all.keys.toList(),
          'firstSeen': customerInfo.firstSeen,
          'requestDate': customerInfo.requestDate,
        },
        'offerings': {
          'currentOfferingId': offerings.current?.identifier,
          'availableOfferingsCount': offerings.all.length,
          'currentOfferingPackagesCount': offerings.current?.availablePackages.length ?? 0,
        },
      };
    } catch (e) {
      return {
        'isInitialized': _isInitialized,
        'error': e.toString(),
      };
    }
  }

  Future<bool> isConfigured() async {
    try {
      await Purchases.getCustomerInfo();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cleanup
  void dispose() {
    // RevenueCat doesn't require explicit disposal
    _isInitialized = false;
  }
}

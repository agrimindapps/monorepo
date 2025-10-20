import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../intermediate.dart';
import 'in_app_purchase_service.dart';

class RevenuecatService extends GetxController {
  final Store store;
  final String apiKey;
  static RevenuecatService? _instance;
  static bool entitlementIsActive = false;
  // static String appUserID = '';

  factory RevenuecatService({required Store store, required String apiKey}) {
    _instance ??= RevenuecatService._internal(store, apiKey);
    return _instance!;
  }

  RevenuecatService._internal(this.store, this.apiKey);

  static RevenuecatService get instance {
    return _instance!;
  }

  //gets
  static bool isForAppleStore() => instance.store == Store.appStore;
  static bool isForGooglePlay() => instance.store == Store.playStore;
  static bool isForAmazonAppstore() => instance.store == Store.amazon;
  static bool isEntitlementActive() => entitlementIsActive;
  // static String getAppUserID() => appUserID;

  //sets
  static void setEntitlementIsActive(bool value) {
    entitlementIsActive = value;
  }

  // static void setAppUserID(String value) {
  //   appUserID = value;
  // }

  static Future<Offering?> getOfferings() async {
    Offerings? offerings;
    try {
      offerings = await Purchases.getOfferings();
      debugPrint('Offerings: $offerings');
    } catch (e) {
      debugPrint('Error getOfferings: $e');
    }

    return offerings?.current;
  }

  static Future<bool> purchasePackage(Package package) async {
    bool success = false;
    try {
      CustomerInfo purchaserInfo = await Purchases.purchasePackage(package);

      // Verifica se a compra foi realizada com sucesso
      if (purchaserInfo
              .entitlements.all[GlobalEnvironment().entitlementID]?.isActive ==
          true) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'signature_revenuecat', jsonEncode(purchaserInfo));
        success = true;
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('Compra cancelada pelo usuário.');
      } else {
        debugPrint('Erro durante a compra: $e');
      }

      success = false;
    }

    return success;
  }

  static Future<bool> restorePurchases() async {
    bool success = false;
    try {
      CustomerInfo restore = await Purchases.restorePurchases();
      success = restore.entitlements.active.isNotEmpty;

      if (success) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('signature_revenuecat', jsonEncode(restore));
      }
    } catch (e) {
      debugPrint('Error restorePurchases: $e');
    }

    return success;
  }

  static Future<bool> checkSignature() async {
    bool success = false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? row = prefs.getString('signature_revenuecat');

    if (row == null || row.isEmpty || row == '') {
      return false;
    }

    Map<String, dynamic> signatureMap = jsonDecode(row) as Map<String, dynamic>;
    CustomerInfo signature = CustomerInfo.fromJson(signatureMap);

    if (signature.entitlements.active.isEmpty) {
      return false;
    }

    String endDate = signature.entitlements
        .active[GlobalEnvironment().entitlementID]!.latestPurchaseDate;

    if (endDate.isNotEmpty) {
      try {
        int dateNow = DateTime.now().millisecondsSinceEpoch;
        int dateEnd =
            DateTime.parse(endDate).millisecondsSinceEpoch + 172800000;
        if (dateNow < dateEnd) {
          InAppPurchaseService().isPremium.value = true;
          success = true;
        } else {
          await prefs.remove('signature_revenuecat');
        }
      } catch (e) {
        debugPrint('Erro ao converter a data: $e');
      }
    }

    return success;
  }

  static Future<void> configureSDK() async {
    await Purchases.setLogLevel(LogLevel.error);

    PurchasesConfiguration configuration;
    if (RevenuecatService.isForAmazonAppstore()) {
      configuration = AmazonConfiguration(RevenuecatService.instance.apiKey)
        ..appUserID = null
        ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();
    } else {
      configuration = PurchasesConfiguration(RevenuecatService.instance.apiKey)
        ..appUserID = null
        ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();
    }
    await Purchases.configure(configuration);
  }
}

import 'dart:io' show Platform;

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

class RevenueCatService {
  static const String apiKeyIos = 'appl_nkOoqSFIzRCGCXbILNTCGhmqKlO';
  static const String apiKeyAndroid = 'goog_nYeQHKkXrBWMjBKlmDnYbJTgZBv';

  Future<void> initialize(String userId) async {
    try {
      debugPrint('🛒 [RevenueCat] Inicializando para userId: $userId');

      PurchasesConfiguration configuration;
      if (!kIsWeb && Platform.isIOS) {
        configuration = PurchasesConfiguration(apiKeyIos)..appUserID = userId;
      } else if (!kIsWeb && Platform.isAndroid) {
        configuration = PurchasesConfiguration(apiKeyAndroid)..appUserID = userId;
      } else {
        debugPrint('🛒 [RevenueCat] Plataforma não suportada');
        return;
      }

      await Purchases.configure(configuration);
      debugPrint('✅ [RevenueCat] Configurado com sucesso');
    } catch (e, stack) {
      debugPrint('❌ [RevenueCat] Erro ao configurar: $e\n$stack');
    }
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      debugPrint('📦 [RevenueCat] CustomerInfo obtido');
      return customerInfo;
    } catch (e, stack) {
      debugPrint('❌ [RevenueCat] Erro ao obter CustomerInfo: $e\n$stack');
      return null;
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      debugPrint('🎁 [RevenueCat] Offerings obtidos: ${offerings.all.length}');
      return offerings;
    } catch (e, stack) {
      debugPrint('❌ [RevenueCat] Erro ao obter Offerings: $e\n$stack');
      return null;
    }
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      debugPrint('💰 [RevenueCat] Iniciando compra: ${package.identifier}');
      final result = await Purchases.purchasePackage(package);
      debugPrint('✅ [RevenueCat] Compra concluída com sucesso');
      return result.customerInfo;
    } catch (e, stack) {
      debugPrint('❌ [RevenueCat] Erro na compra: $e\n$stack');
      return null;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    try {
      debugPrint('🔄 [RevenueCat] Restaurando compras');
      final customerInfo = await Purchases.restorePurchases();
      debugPrint('✅ [RevenueCat] Compras restauradas');
      return customerInfo;
    } catch (e, stack) {
      debugPrint('❌ [RevenueCat] Erro ao restaurar compras: $e\n$stack');
      return null;
    }
  }

  bool isPremium(CustomerInfo? customerInfo) {
    if (customerInfo == null) return false;
    
    final entitlements = customerInfo.entitlements.active;
    final hasPremium = entitlements.containsKey('premium') || 
                       entitlements.containsKey('Premium') ||
                       entitlements.containsKey('pro');
    
    debugPrint('👑 [RevenueCat] isPremium: $hasPremium (entitlements: ${entitlements.keys.join(', ')})');
    return hasPremium;
  }

  Future<void> logout() async {
    try {
      debugPrint('🚪 [RevenueCat] Fazendo logout');
      await Purchases.logOut();
      debugPrint('✅ [RevenueCat] Logout concluído');
    } catch (e, stack) {
      debugPrint('❌ [RevenueCat] Erro ao fazer logout: $e\n$stack');
    }
  }
}

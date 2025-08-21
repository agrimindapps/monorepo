import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../constants/revenuecat_constants.dart';

/// Serviço para inicialização e configuração do RevenueCat
class RevenueCatService {
  static bool _isInitialized = false;
  
  /// Inicializa o RevenueCat com as chaves apropriadas
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('RevenueCat already initialized');
      return;
    }

    try {
      // Configura log level baseado no ambiente
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      } else {
        await Purchases.setLogLevel(LogLevel.info);
      }

      // Determina a chave API baseada na plataforma
      final apiKey = Platform.isIOS 
          ? RevenueCatConstants.appleApiKey
          : RevenueCatConstants.googleApiKey;

      // Configuração do RevenueCat
      final configuration = PurchasesConfiguration(apiKey);
      
      await Purchases.configure(configuration);

      _isInitialized = true;
      
      debugPrint('RevenueCat initialized successfully with API key: ${apiKey.substring(0, 8)}...');
      
      // Configura atributos do usuário se necessário
      await _setupUserAttributes();
      
    } catch (e) {
      debugPrint('Error initializing RevenueCat: $e');
      rethrow;
    }
  }

  /// Configura atributos específicos do usuário
  static Future<void> _setupUserAttributes() async {
    try {
      // Configura informações específicas do app
      await Purchases.setAttributes({
        'app': 'receituagro',
        'platform': Platform.isIOS ? 'ios' : 'android',
        'version': '1.0.0', // Pode ser obtido do package_info_plus
      });
      
      debugPrint('User attributes set successfully');
    } catch (e) {
      debugPrint('Error setting user attributes: $e');
    }
  }

  /// Identifica o usuário no RevenueCat
  static Future<void> identifyUser(String userId) async {
    try {
      await Purchases.logIn(userId);
      debugPrint('User identified in RevenueCat: $userId');
    } catch (e) {
      debugPrint('Error identifying user in RevenueCat: $e');
      rethrow;
    }
  }

  /// Remove identificação do usuário (logout)
  static Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
      debugPrint('User logged out from RevenueCat');
    } catch (e) {
      debugPrint('Error logging out user from RevenueCat: $e');
      rethrow;
    }
  }

  /// Verifica se o RevenueCat está inicializado
  static bool get isInitialized => _isInitialized;

  /// Obtém produtos disponíveis
  static Future<List<StoreProduct>> getAvailableProducts() async {
    try {
      final offerings = await Purchases.getOfferings();
      final currentOffering = offerings.current;
      
      if (currentOffering != null) {
        return currentOffering.availablePackages
            .map((package) => package.storeProduct)
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Error getting available products: $e');
      return [];
    }
  }

  /// Verifica informações do cliente atual
  static Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('Error getting customer info: $e');
      rethrow;
    }
  }

  /// Verifica se o usuário tem assinatura ativa
  static Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await getCustomerInfo();
      final hasActivePremium = customerInfo.entitlements.active
          .containsKey(RevenueCatConstants.entitlementId);
      
      debugPrint('User has active subscription: $hasActivePremium');
      return hasActivePremium;
    } catch (e) {
      debugPrint('Error checking active subscription: $e');
      return false;
    }
  }

  /// Obtém detalhes da assinatura ativa
  static Future<EntitlementInfo?> getActiveSubscription() async {
    try {
      final customerInfo = await getCustomerInfo();
      return customerInfo.entitlements.active[RevenueCatConstants.entitlementId];
    } catch (e) {
      debugPrint('Error getting active subscription details: $e');
      return null;
    }
  }

  /// Compra um produto específico
  static Future<CustomerInfo> purchaseProduct(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final currentOffering = offerings.current;
      
      if (currentOffering == null) {
        throw Exception('No offerings available');
      }

      // Encontra o pacote pelo productId
      final package = currentOffering.availablePackages.firstWhere(
        (pkg) => pkg.storeProduct.identifier == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );

      final purchaseResult = await Purchases.purchasePackage(package);
      debugPrint('Purchase completed successfully for product: $productId');
      
      return purchaseResult.customerInfo;
    } catch (e) {
      debugPrint('Error purchasing product $productId: $e');
      rethrow;
    }
  }

  /// Restaura compras anteriores
  static Future<CustomerInfo> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      debugPrint('Purchases restored successfully');
      return customerInfo;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      rethrow;
    }
  }

  /// Obtém URL para gerenciar assinatura
  static Future<String?> getManagementURL() async {
    try {
      final customerInfo = await getCustomerInfo();
      return customerInfo.managementURL;
    } catch (e) {
      debugPrint('Error getting management URL: $e');
      return null;
    }
  }

  /// Configura listener para mudanças na assinatura
  static void setUpdatedCustomerInfoListener(Function(CustomerInfo) listener) {
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  /// Remove listener
  static void removeUpdatedCustomerInfoListener(Function(CustomerInfo) listener) {
    Purchases.removeCustomerInfoUpdateListener(listener);
  }
}
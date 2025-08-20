// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../models/purchase_state_model.dart';

// Helper function to safely convert dates
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

class PurchaseService {
  Future<PurchaseResult> makePurchase(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);

      if (purchaserInfo.entitlements.active.isNotEmpty) {
        return PurchaseResult.successful(
          package: package,
          customerInfo: purchaserInfo,
        );
      } else {
        return PurchaseResult.failed('Compra não foi ativada corretamente');
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled();
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        return PurchaseResult.failed(
            'Compras não permitidas neste dispositivo');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        return PurchaseResult.failed(
            'Pagamento pendente. Aguarde a confirmação.');
      } else if (errorCode == PurchasesErrorCode.purchaseInvalidError) {
        return PurchaseResult.failed('Produto não disponível para compra');
      } else if (errorCode == PurchasesErrorCode.storeProblemError) {
        return PurchaseResult.failed(
            'Problema com a loja. Tente novamente mais tarde.');
      } else {
        return PurchaseResult.failed(_getLocalizedErrorMessage(e));
      }
    } catch (e) {
      return PurchaseResult.failed('Erro inesperado durante a compra: $e');
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
      return RestoreResult.failed(_getLocalizedErrorMessage(e));
    } catch (e) {
      return RestoreResult.failed('Erro inesperado ao restaurar: $e');
    }
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getActiveEntitlements() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.keys.toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isProductActive(String productId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(productId);
    } catch (e) {
      return false;
    }
  }

  Future<DateTime?> getExpirationDate(String entitlementId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementId];
      return _stringOrDateTimeToDateTime(entitlement?.expirationDate);
    } catch (e) {
      return null;
    }
  }

  Future<bool> willAutoRenew(String entitlementId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[entitlementId];
      return entitlement?.willRenew ?? false;
    } catch (e) {
      return false;
    }
  }

  String _getLocalizedErrorMessage(PlatformException error) {
    final errorCode = PurchasesErrorHelper.getErrorCode(error);

    switch (errorCode) {
      case PurchasesErrorCode.networkError:
        return 'Erro de conexão. Verifique sua internet e tente novamente.';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Compras não permitidas neste dispositivo.';
      case PurchasesErrorCode.purchaseInvalidError:
        return 'Produto não está disponível para compra.';
      case PurchasesErrorCode.purchaseCancelledError:
        return 'Compra cancelada pelo usuário.';
      case PurchasesErrorCode.storeProblemError:
        return 'Problema com a loja. Tente novamente mais tarde.';
      case PurchasesErrorCode.paymentPendingError:
        return 'Pagamento pendente. Aguarde a confirmação.';
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return 'Este recibo já está sendo usado.';
      case PurchasesErrorCode.missingReceiptFileError:
        return 'Arquivo de recibo não encontrado.';
      case PurchasesErrorCode.invalidReceiptError:
        return 'Recibo inválido.';
      case PurchasesErrorCode.invalidCredentialsError:
        return 'Credenciais inválidas.';
      case PurchasesErrorCode.unexpectedBackendResponseError:
        return 'Resposta inesperada do servidor.';
      case PurchasesErrorCode.configurationError:
        return 'Erro de configuração da aplicação.';
      case PurchasesErrorCode.unknownError:
      default:
        return error.message ?? 'Erro desconhecido durante a operação.';
    }
  }

  // Validation methods
  bool isValidPackage(Package? package) {
    return package != null &&
        package.storeProduct.title.isNotEmpty &&
        package.storeProduct.price > 0;
  }

  bool isPackageAvailable(Package package, List<Package> availablePackages) {
    return availablePackages.any((p) => p.identifier == package.identifier);
  }

  // Helper methods for purchase flow
  String getPurchaseButtonText(Package package, bool isPurchasing) {
    if (isPurchasing) {
      return 'Processando...';
    }

    switch (package.packageType) {
      case PackageType.weekly:
        return 'Assinar Semanal';
      case PackageType.monthly:
        return 'Assinar Mensal';
      case PackageType.threeMonth:
        return 'Assinar Trimestral';
      case PackageType.sixMonth:
        return 'Assinar Semestral';
      case PackageType.annual:
        return 'Assinar Anual';
      case PackageType.lifetime:
        return 'Comprar Vitalício';
      default:
        return 'Assinar Premium';
    }
  }

  String getSuccessMessage(Package package, bool isRestore) {
    if (isRestore) {
      return 'Compras restauradas com sucesso!';
    }

    switch (package.packageType) {
      case PackageType.weekly:
        return 'Assinatura semanal ativada com sucesso!';
      case PackageType.monthly:
        return 'Assinatura mensal ativada com sucesso!';
      case PackageType.threeMonth:
        return 'Assinatura trimestral ativada com sucesso!';
      case PackageType.sixMonth:
        return 'Assinatura semestral ativada com sucesso!';
      case PackageType.annual:
        return 'Assinatura anual ativada com sucesso!';
      case PackageType.lifetime:
        return 'Acesso vitalício ativado com sucesso!';
      default:
        return 'Assinatura Premium ativada com sucesso!';
    }
  }

  // Analytics and tracking
  Map<String, dynamic> getPurchaseAnalyticsData(Package package) {
    return {
      'package_id': package.identifier,
      'package_type': package.packageType.name,
      'price': package.storeProduct.price,
      'currency': package.storeProduct.currencyCode,
      'product_title': package.storeProduct.title,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> getRestoreAnalyticsData(RestoreResult result) {
    return {
      'success': result.success,
      'restored_count': result.restoredCount,
      'restored_products': result.restoredProductIds,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

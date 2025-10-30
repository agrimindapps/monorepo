import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/premium_notifier.dart';

/// Manages premium purchase operations
class PremiumPurchaseManager {
  final Ref ref;

  PremiumPurchaseManager(this.ref);

  /// Purchase a specific product
  Future<bool> purchaseProduct(String productId) async {
    final notifier = ref.read(premiumNotifierProvider.notifier);
    return await notifier.purchaseProduct(productId);
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    final notifier = ref.read(premiumNotifierProvider.notifier);
    return await notifier.restorePurchases();
  }

  /// Check if purchase is in progress
  bool isPurchaseInProgress(PremiumState state) {
    return state.isLoading;
  }

  /// Get purchase error message
  String? getPurchaseErrorMessage(PremiumState state) {
    if (state.error?.type == PremiumErrorType.purchase) {
      return state.error?.message;
    }
    return null;
  }

  /// Check if purchase was successful
  bool wasPurchaseSuccessful(
    PremiumState previousState,
    PremiumState currentState,
  ) {
    return !previousState.isPremium && currentState.isPremium;
  }

  /// Get purchase success message
  String getPurchaseSuccessMessage() {
    return 'Bem-vindo ao Premium Plantis! 🌱';
  }

  /// Get restore success message
  String getRestoreSuccessMessage() {
    return 'Compras restauradas com sucesso!';
  }

  /// Get restore not found message
  String getRestoreNotFoundMessage() {
    return 'Nenhuma compra anterior encontrada.';
  }
}

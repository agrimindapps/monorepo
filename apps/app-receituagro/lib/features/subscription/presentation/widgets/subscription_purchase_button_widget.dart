import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_riverpod_provider.dart';

/// Widget responsável pelo botão de compra principal
///
/// Responsabilidades:
/// - Exibir botão de compra atrativo
/// - Mostrar loading state durante compra
/// - Adaptar texto baseado no plano selecionado
/// - Gerenciar ação de compra
/// - Estados visuais para diferentes situações
class SubscriptionPurchaseButtonWidget extends ConsumerWidget {
  const SubscriptionPurchaseButtonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final selectedPlan = subscriptionState.selectedPlan;
    final isLoading = subscriptionState.isLoading;
    final availableProducts = subscriptionState.availableProducts;

    // Encontrar produto correspondente ao plano selecionado
    final selectedProduct = _findProductForPlan(availableProducts, selectedPlan);

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade400.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading || selectedProduct == null 
            ? null 
            : () => _handlePurchase(ref, selectedProduct),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.diamond,
                    size: 24,
                  ),
                  
                  const SizedBox(width: 8),
                  
                  Text(
                    _getButtonText(selectedPlan, selectedProduct),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Encontra o produto correspondente ao plano selecionado
  ProductInfo? _findProductForPlan(List<ProductInfo> products, String planType) {
    switch (planType) {
      case 'yearly':
        return products.firstWhereOrNull((p) => p.productId.contains('yearly'));
      case 'monthly':
        return products.firstWhereOrNull((p) => p.productId.contains('monthly'));
      case 'weekly':
        return products.firstWhereOrNull((p) => p.productId.contains('weekly'));
      default:
        return products.firstWhereOrNull((p) => p.productId.contains('yearly'));
    }
  }

  /// Retorna o texto do botão baseado no plano
  String _getButtonText(String planType, ProductInfo? product) {
    if (product == null) {
      return 'Assinar Premium';
    }
    
    switch (planType) {
      case 'yearly':
        return 'Assinar Anual';
      case 'monthly':
        return 'Assinar Mensal';
      case 'weekly':
        return 'Assinar Semanal';
      default:
        return 'Obter Acesso Total';
    }
  }

  /// Manipula a ação de compra
  Future<void> _handlePurchase(WidgetRef ref, ProductInfo product) async {
    await ref.read(subscriptionProvider.notifier).purchaseProduct(product.productId);
  }
}

/// Extension helper para firstWhereOrNull
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) predicate) {
    for (T element in this) {
      if (predicate(element)) return element;
    }
    return null;
  }
}
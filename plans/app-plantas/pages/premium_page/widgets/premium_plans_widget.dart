// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';
import '../controller/premium_controller.dart';

class PremiumPlansWidget extends GetView<PremiumController> {
  const PremiumPlansWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final plantasCores = PlantasDesignTokens.cores(context);
    final plantasTextStyles = PlantasDesignTokens.textStyles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Text(
          'Escolha seu Plano',
          style: plantasTextStyles['h1']?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ) ??
              TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: plantasCores['texto'],
              ),
        ),

        const SizedBox(height: 20),

        // Lista de planos
        Obx(() => Column(
              children: controller.products
                  .map(
                    (product) => _buildPlanCard(product, context),
                  )
                  .toList(),
            )),

        const SizedBox(height: 24),

        // Botão de compra
        Obx(() => _buildPurchaseButton(context)),
      ],
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> product, BuildContext context) {
    final plantasCores = PlantasDesignTokens.cores(context);
    final productId = product['productId'] as String;
    final isSelected = controller.selectedPlan.value == productId;
    final isAnnual = productId.contains('anual');

    return GestureDetector(
      onTap: () => controller.selectPlan(productId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? plantasCores['primaria']!.withValues(alpha: 0.1)
              : plantasCores['fundoCard'],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? plantasCores['primaria']! : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: plantasCores['primaria']!.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? plantasCores['primaria']!
                      : Colors.grey.shade400,
                  width: 2,
                ),
                color:
                    isSelected ? plantasCores['primaria'] : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),

            const SizedBox(width: 16),

            // Informações do plano
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        product['desc'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? plantasCores['primaria']
                              : plantasCores['texto'],
                        ),
                      ),
                      if (isAnnual) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: PlantasDesignTokens.isDarkMode(context)
                                ? const Color(0xFFFFD700)
                                : const Color(0xFFFFB300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Economize 33%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPriceForProduct(productId),
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected
                          ? plantasCores['primaria']
                          : plantasCores['textoSecundario'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(BuildContext context) {
    final plantasCores = PlantasDesignTokens.cores(context);
    final isProcessing = controller.isProcessingPurchase.value;
    final selectedProduct = controller.selectedProduct;

    if (selectedProduct == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isProcessing
            ? null
            : () => controller.purchasePlan(selectedProduct['productId']),
        style: ElevatedButton.styleFrom(
          backgroundColor: plantasCores['primaria'],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    _getPurchaseButtonText(),
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

  String _getPriceForProduct(String productId) {
    if (productId.contains('anual')) {
      return 'R\$ 79,99/ano';
    } else {
      return 'R\$ 9,99/mês';
    }
  }

  String _getPurchaseButtonText() {
    final selectedProduct = controller.selectedProduct;
    if (selectedProduct == null) return 'Selecione um plano';

    final isAnnual = selectedProduct['productId'].toString().contains('anual');
    return isAnnual ? 'Assinar Premium - Anual' : 'Assinar Premium - Mensal';
  }
}

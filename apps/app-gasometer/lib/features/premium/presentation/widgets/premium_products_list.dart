import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/premium_notifier.dart';

class PremiumProductsList extends core.ConsumerStatefulWidget {
  const PremiumProductsList({super.key});

  @override
  core.ConsumerState<PremiumProductsList> createState() => _PremiumProductsListState();
}

class _PremiumProductsListState extends core.ConsumerState<PremiumProductsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(premiumNotifierProvider.notifier);
      notifier.loadAvailableProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final premiumAsync = ref.watch(premiumNotifierProvider);

    return premiumAsync.when(
      data: (state) {
        if (state.isLoadingProducts) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.errorMessage != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Erro ao carregar produtos',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final notifier = ref.read(premiumNotifierProvider.notifier);
                    notifier.loadAvailableProducts();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        if (state.availableProducts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.grey500,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nenhum produto disponível',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Os produtos premium não estão disponíveis no momento.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: state.availableProducts.map((product) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildProductCard(context, state, product),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Erro: $error', style: const TextStyle(color: AppColors.error)),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    PremiumNotifierState state,
    core.ProductInfo product,
  ) {
    final isMonthly = product.productId.contains('monthly');
    final isRecommended = !isMonthly; // Yearly is recommended

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecommended ? AppColors.primary : AppColors.grey200,
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: isRecommended ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Stack(
        children: [
          // Recommended badge
          if (isRecommended)
            Positioned(
              top: -1,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                child: Text(
                  'RECOMENDADO',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatPeriod(product),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.priceString,
                          style: AppTextStyles.premiumPrice.copyWith(
                            fontSize: 24,
                          ),
                        ),
                        if (!isMonthly) ...[
                          const SizedBox(height: 4),
                          Text(
                            _calculateMonthlyPrice(product.price),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  product.description.isNotEmpty 
                    ? product.description
                    : 'Acesso completo a todas as funcionalidades premium',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isProcessingPurchase
                      ? null
                      : () => _onPurchasePressed(context, product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended
                        ? AppColors.primary
                        : AppColors.grey700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: state.isProcessingPurchase
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Assinar Agora',
                          style: AppTextStyles.buttonMedium,
                        ),
                  ),
                ),
                
                if (!isMonthly) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.savings,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Economia de ${_calculateSavings()}% no plano anual',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPeriod(core.ProductInfo product) {
    if (product.productId.contains('monthly')) {
      return 'Cobrança mensal';
    } else if (product.productId.contains('yearly')) {
      return 'Cobrança anual';
    }
    return product.subscriptionPeriod ?? 'Assinatura';
  }

  String _calculateMonthlyPrice(double yearlyPrice) {
    final monthlyPrice = yearlyPrice / 12;
    return 'R\$ ${monthlyPrice.toStringAsFixed(2)}/mês';
  }

  String _calculateSavings() {
    // Assuming 16% savings on yearly plan (typical for subscription services)
    return '16';
  }

  Future<void> _onPurchasePressed(
    BuildContext context,
    core.ProductInfo product,
  ) async {
    // Show confirmation dialog
    final confirmed = await _showPurchaseConfirmation(context, product);
    if (!confirmed) return;

    // Attempt purchase
    final notifier = ref.read(premiumNotifierProvider.notifier);
    final success = await notifier.purchaseProduct(product.productId);

    if (!mounted) return;

    final state = ref.read(premiumNotifierProvider).valueOrNull;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium ativado com sucesso!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state?.errorMessage ?? 'Erro na compra. Tente novamente.',
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _showPurchaseConfirmation(
    BuildContext context,
    core.ProductInfo product,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produto: ${product.title}'),
            Text('Preço: ${product.priceString}'),
            const SizedBox(height: 16),
            const Text(
              'Ao confirmar, você será redirecionado para a loja para completar a compra.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }
}
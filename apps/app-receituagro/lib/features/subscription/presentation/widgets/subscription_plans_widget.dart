import 'package:core/core.dart' show ProductInfo;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_notifier.dart';

/// Widget responsável pela exibição e seleção de planos de subscription
///
/// Funcionalidades:
/// - Exibir opções de planos (Mensal, Anual, Semanal)
/// - Seleção visual com estado
/// - Badges para destacar melhor valor
/// - Design visual consistente com tema da aplicação
///
/// Design:
/// - Cards com seleção por radio button
/// - Destaque visual para plano selecionado
/// - Badge "MELHOR VALOR" para plano anual
/// - Cores do gradiente da aplicação
class SubscriptionPlansWidget extends ConsumerWidget {
  const SubscriptionPlansWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionManagementProvider);

    return subscriptionAsync.when(
      data: (subscriptionState) {
        final notifier = ref.read(subscriptionManagementProvider.notifier);
        final products = subscriptionState.availableProducts;

        debugPrint('🎨 [SubscriptionPlansWidget] Renderizando widget');
        debugPrint('   - Produtos disponíveis: ${products.length}');
        if (products.isNotEmpty) {
          for (final product in products) {
            debugPrint('   - ${product.productId}: ${product.priceString}');
          }
        }

        // Se não há produtos, exibe mensagem
        if (products.isEmpty) {
          debugPrint('⚠️ [SubscriptionPlansWidget] Nenhum produto para exibir');
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_off,
                  color: Colors.white70,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Carregando planos...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Mapeia produtos por período
        debugPrint('🗂️ [SubscriptionPlansWidget] Mapeando produtos por período...');

        final monthlyProduct = products.firstWhere(
          (p) => p.productId.contains('mensal'),
          orElse: () {
            debugPrint('⚠️ [SubscriptionPlansWidget] Produto mensal não encontrado, usando primeiro');
            return products.first;
          },
        );
        debugPrint('   ✓ Mensal: ${monthlyProduct.productId}');

        final semiannualProduct = products.firstWhere(
          (p) => p.productId.contains('semestral'),
          orElse: () {
            debugPrint('⚠️ [SubscriptionPlansWidget] Produto semestral não encontrado, usando primeiro');
            return products.first;
          },
        );
        debugPrint('   ✓ Semestral: ${semiannualProduct.productId}');

        final annualProduct = products.firstWhere(
          (p) => p.productId.contains('anual'),
          orElse: () {
            debugPrint('⚠️ [SubscriptionPlansWidget] Produto anual não encontrado, usando último');
            return products.last;
          },
        );
        debugPrint('   ✓ Anual: ${annualProduct.productId}');

        return Column(
          children: [
            // Plano Mensal
            _buildPlanOption(
              ref: ref,
              notifier: notifier,
              product: monthlyProduct,
              planType: 'monthly',
              isSelected: notifier.isPlanSelected('monthly'),
            ),
            const SizedBox(height: 12),

            // Plano Anual (com badge)
            _buildPlanOption(
              ref: ref,
              notifier: notifier,
              product: annualProduct,
              planType: 'yearly',
              isSelected: notifier.isPlanSelected('yearly'),
              badge: 'MELHOR VALOR',
            ),
            const SizedBox(height: 12),

            // Plano Semestral
            _buildPlanOption(
              ref: ref,
              notifier: notifier,
              product: semiannualProduct,
              planType: 'semiannual',
              isSelected: notifier.isPlanSelected('semiannual'),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Erro ao carregar planos: $error',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Constrói um card de opção de plano com produto real do RevenueCat
  Widget _buildPlanOption({
    required WidgetRef ref,
    required SubscriptionManagementNotifier notifier,
    required ProductInfo product,
    required String planType,
    required bool isSelected,
    String? badge,
  }) {
    // Extrai título do período
    String title;
    if (product.productId.contains('mensal2') || product.productId.contains('mensal')) {
      title = 'Mensal';
    } else if (product.productId.contains('semestral')) {
      title = 'Semestral';
    } else if (product.productId.contains('anual')) {
      title = 'Anual';
    } else {
      title = product.title;
    }

    // Usa o preço real do produto
    final price = product.priceString;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0x26388E3C)  // 15% opacity green for selected
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2)
            : Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => notifier.selectPlan(planType),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildRadioButton(isSelected),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlanTitle(title, badge),
                      const SizedBox(height: 4),
                      _buildPlanPrice(price),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói o radio button customizado
  Widget _buildRadioButton(bool isSelected) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
          width: isSelected ? 6 : 2,
        ),
        color: Colors.transparent,
      ),
    );
  }

  /// Constrói o título do plano com badge opcional
  Widget _buildPlanTitle(String title, String? badge) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 12),
          _buildBadge(badge),
        ],
      ],
    );
  }

  /// Constrói o badge destacado
  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF66BB6A),  // Medium green badge
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Constrói o preço do plano
  Widget _buildPlanPrice(String price) {
    return Text(
      price,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 14,
      ),
    );
  }
}

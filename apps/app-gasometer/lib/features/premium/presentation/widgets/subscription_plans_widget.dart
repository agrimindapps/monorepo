import 'package:core/core.dart' show ProductInfo;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/premium_notifier.dart';
import '../providers/subscription_ui_provider.dart';

class SubscriptionPlansWidget extends ConsumerWidget {
  const SubscriptionPlansWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumAsync = ref.watch<AsyncValue<PremiumNotifierState>>(premiumProvider);

    return premiumAsync.when(
      data: (premiumState) {
        final products = premiumState.availableProducts;
        final selectedPlan = ref.watch(selectedPlanProvider);

        if (products.isEmpty) {
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

        final monthlyProduct = products.firstWhere(
          (p) => p.productId.contains('mensal'),
          orElse: () => products.first,
        );

        final semiannualProduct = products.firstWhere(
          (p) => p.productId.contains('semestral'),
          orElse: () => products.first,
        );

        final annualProduct = products.firstWhere(
          (p) => p.productId.contains('anual'),
          orElse: () => products.last,
        );

        return Column(
          children: [
            // Plano Mensal
            _buildPlanOption(
              ref: ref,
              product: monthlyProduct,
              planType: 'monthly',
              isSelected: selectedPlan == 'monthly',
            ),
            const SizedBox(height: 16),

            // Plano Anual (com badge e destaque)
            Transform.scale(
              scale: 1.02,
              child: _buildPlanOption(
                ref: ref,
                product: annualProduct,
                planType: 'yearly',
                isSelected: selectedPlan == 'yearly',
                badge: 'MELHOR VALOR',
                isHero: true,
                savings: 'Economize 40%',
              ),
            ),
            const SizedBox(height: 16),

            // Plano Semestral
            _buildPlanOption(
              ref: ref,
              product: semiannualProduct,
              planType: 'semiannual',
              isSelected: selectedPlan == 'semiannual',
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

  Widget _buildPlanOption({
    required WidgetRef ref,
    required ProductInfo product,
    required String planType,
    required bool isSelected,
    String? badge,
    bool isHero = false,
    String? savings,
  }) {
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

    final price = product.priceString;
    
    final borderColor = isSelected
        ? (isHero ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.6))
        : Colors.white.withValues(alpha: 0.1);
        
    final backgroundColor = isSelected
        ? (isHero ? const Color(0x33FFD700) : const Color(0x262196F3)) // Blue tint
        : Colors.white.withValues(alpha: 0.05);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected && isHero
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => ref.read(selectedPlanProvider.notifier).state = planType,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _buildRadioButton(isSelected, isHero),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (savings != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    savings,
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
        ),
        
        if (badge != null)
          Positioned(
            top: -10,
            right: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRadioButton(bool isSelected, bool isHero) {
    final activeColor = isHero ? const Color(0xFFFFD700) : Colors.white;
    
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.5),
          width: isSelected ? 6 : 2,
        ),
        color: Colors.transparent,
      ),
    );
  }

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

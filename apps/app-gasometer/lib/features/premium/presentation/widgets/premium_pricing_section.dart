import 'package:flutter/material.dart';

import 'premium_pricing_card.dart';
import 'premium_strings.dart';

/// Section displaying available subscription plans.
class PremiumPricingSection extends StatelessWidget {
  const PremiumPricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PremiumStrings.choosePlan,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        const PremiumPricingCard(
          title: 'Premium Mensal',
          price: r'R$ 9,90',
          period: '/mês',
          features: [
            'Todos os recursos premium',
            'Suporte prioritário',
            'Sincronização em nuvem',
            'Relatórios avançados',
          ],
          isPopular: false,
        ),
        const SizedBox(height: 12),
        const PremiumPricingCard(
          title: 'Premium Anual',
          price: r'R$ 79,90',
          period: '/ano',
          originalPrice: r'R$ 118,80',
          discount: '32% OFF',
          features: [
            'Todos os recursos premium',
            'Suporte prioritário',
            'Sincronização em nuvem',
            'Relatórios avançados',
            '2 meses grátis',
          ],
          isPopular: true,
        ),
      ],
    );
  }
}

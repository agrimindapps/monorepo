import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/design_tokens.dart';
import 'premium_active_header.dart';
import 'premium_benefit_item.dart';

/// Card displayed when premium is active.
class PremiumActiveCard extends StatelessWidget {
  const PremiumActiveCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor:
          GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusDialog,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.05),
              GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.15),
              GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.08),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusDialog,
          ),
          border: Border.all(
            color:
                GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PremiumActiveHeader(),
              const SizedBox(height: 20),
              _buildBenefitsSection(),
              const SizedBox(height: 20),
              _buildManageButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benefícios Ativos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: GasometerDesignTokens.colorPremiumAccent,
            ),
          ),
          SizedBox(height: 12),
          PremiumBenefitItem(
            icon: Icons.auto_awesome,
            text: 'Relatórios avançados ilimitados',
          ),
          SizedBox(height: 8),
          PremiumBenefitItem(
            icon: Icons.cloud_sync,
            text: 'Sincronização em nuvem',
          ),
          SizedBox(height: 8),
          PremiumBenefitItem(
            icon: Icons.support_agent,
            text: 'Suporte prioritário 24/7',
          ),
        ],
      ),
    );
  }

  Widget _buildManageButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => context.go('/premium'),
        icon: const Icon(Icons.settings, size: 20),
        label: const Text(
          'Gerenciar Assinatura',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GasometerDesignTokens.colorPremiumAccent,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor:
              GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

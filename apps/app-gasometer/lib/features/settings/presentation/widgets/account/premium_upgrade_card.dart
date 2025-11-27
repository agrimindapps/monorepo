import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/design_tokens.dart';

/// Card displayed when premium is not active (upgrade prompt).
class PremiumUpgradeCard extends StatelessWidget {
  const PremiumUpgradeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/premium'),
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusDialog,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GasometerDesignTokens.colorPrimary.withValues(alpha: 0.9),
                  GasometerDesignTokens.colorPrimary,
                  GasometerDesignTokens.colorPremiumAccent
                      .withValues(alpha: 0.8),
                ],
              ),
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusDialog,
              ),
              border: Border.all(
                color: GasometerDesignTokens.colorPremiumAccent
                    .withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildIcon(),
                const SizedBox(width: 16),
                Expanded(child: _buildContent()),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GasometerDesignTokens.colorPremiumAccent,
            GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.8),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.workspace_premium,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              'GasOMeter Premium',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Desbloqueie recursos avançados',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

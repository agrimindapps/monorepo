import 'package:flutter/material.dart';

import '../../../../../core/theme/design_tokens.dart';

/// Header widget for the premium active card.
class PremiumActiveHeader extends StatelessWidget {
  const PremiumActiveHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIcon(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Premium Ativo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: GasometerDesignTokens.colorPremiumAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildActiveBadge(),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Todos os recursos premium desbloqueados',
                style: TextStyle(
                  fontSize: 14,
                  color: GasometerDesignTokens.colorPremiumAccent
                      .withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GasometerDesignTokens.colorPremiumAccent,
            GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.8),
            GasometerDesignTokens.colorPrimary,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color:
                GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.verified, color: Colors.white, size: 32),
    );
  }

  Widget _buildActiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            GasometerDesignTokens.colorPremiumAccent,
            GasometerDesignTokens.colorPrimary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'ATIVO',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}

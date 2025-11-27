import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import 'premium_strings.dart';

/// Status card showing whether premium is active or not.
class PremiumStatusSection extends StatelessWidget {
  const PremiumStatusSection({super.key, required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _buildDecoration(),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 16),
          Expanded(child: _buildTextContent(context)),
          if (isPremium) _buildActiveLabel(),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isPremium
            ? [
                GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.1),
                GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.05),
              ]
            : [
                GasometerDesignTokens.colorPrimary.withValues(alpha: 0.1),
                GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.05),
              ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isPremium
            ? GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.3)
            : GasometerDesignTokens.colorPrimary.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: (isPremium
                  ? GasometerDesignTokens.colorPremiumAccent
                  : GasometerDesignTokens.colorPrimary)
              .withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPremium
            ? GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.2)
            : GasometerDesignTokens.colorPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isPremium ? Icons.verified : Icons.workspace_premium,
        color: isPremium
            ? GasometerDesignTokens.colorPremiumAccent
            : GasometerDesignTokens.colorPrimary,
        size: 32,
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPremium
              ? PremiumStrings.premiumActive
              : PremiumStrings.unlockPremium,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isPremium
              ? PremiumStrings.premiumUnlocked
              : PremiumStrings.premiumDescription,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: GasometerDesignTokens.colorPremiumAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        PremiumStrings.activeLabel,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

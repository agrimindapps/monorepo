import 'package:flutter/material.dart';

import '../../../../core/widgets/semantic_widgets.dart';
import '../../../../core/theme/design_tokens.dart';

/// Reusable fuel statistics card widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of displaying a statistic card
/// Follows OCP: Open for extension via styling options
class FuelStatCard extends StatelessWidget {
  const FuelStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SemanticCard(
      semanticLabel: 'Estatística de $title: $value',
      semanticHint: 'Informação sobre $title dos abastecimentos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: GasometerDesignTokens.paddingAll(
                  GasometerDesignTokens.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: GasometerDesignTokens.borderRadius(
                    GasometerDesignTokens.radiusMd,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: GasometerDesignTokens.iconSizeButton,
                ),
              ),
              const SizedBox(width: GasometerDesignTokens.spacingMd),
              SemanticText.label(
                title,
                style: TextStyle(
                  fontSize: GasometerDesignTokens.fontSizeMd,
                  color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: GasometerDesignTokens.opacitySecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          SemanticText(
            value,
            style: TextStyle(
              fontSize: GasometerDesignTokens.fontSizeXxxl,
              fontWeight: GasometerDesignTokens.fontWeightBold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
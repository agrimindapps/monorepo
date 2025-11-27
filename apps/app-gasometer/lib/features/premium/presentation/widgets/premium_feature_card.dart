import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import 'premium_feature_model.dart';

/// Card that displays a single premium feature.
class PremiumFeatureCard extends StatelessWidget {
  const PremiumFeatureCard({super.key, required this.feature});

  final PremiumFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: feature.isEnabled
            ? GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.05)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: feature.isEnabled
              ? GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          _buildIconContainer(context),
          const SizedBox(width: 16),
          Expanded(child: _buildTextContent(context)),
          _buildStatusIcon(context),
        ],
      ),
    );
  }

  Widget _buildIconContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: feature.isEnabled
            ? GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        feature.icon,
        color: feature.isEnabled
            ? GasometerDesignTokens.colorPremiumAccent
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        size: 24,
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          feature.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: feature.isEnabled
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          feature.description,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    return Icon(
      feature.isEnabled ? Icons.check_circle : Icons.lock_outline,
      color: feature.isEnabled
          ? Colors.green
          : Theme.of(context).colorScheme.outline,
      size: 20,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Header widget for settings page with title and optional actions
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard).bottomLeft,
          bottomRight: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard).bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 32,
              ),
              SizedBox(width: GasometerDesignTokens.spacingMd),
              Text(
                'Configurações',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
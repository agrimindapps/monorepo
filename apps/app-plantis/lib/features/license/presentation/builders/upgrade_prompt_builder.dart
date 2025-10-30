import 'package:flutter/material.dart';

import '../../widgets/premium_feature_gate.dart';

/// Builder estático para o diálogo de upgrade premium
/// SRP: Isolates upgrade prompt UI construction
class UpgradePromptBuilder {
  static Widget buildUpgradePrompt({
    required BuildContext context,
    required PremiumFeature feature,
    required String? customMessage,
    required VoidCallback? onUpgradePressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withValues(alpha: 0.1),
            const Color(0xFF81C784).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium,
            color: Color(0xFF4CAF50),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Recurso Premium',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            customMessage ?? _getDefaultMessage(feature),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onUpgradePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Assinar Premium'),
          ),
        ],
      ),
    );
  }

  static String _getDefaultMessage(PremiumFeature feature) {
    return switch (feature) {
      PremiumFeature.cloudSync => 'Sincronize seus dados na nuvem com Premium',
      PremiumFeature.unlimitedPlants =>
        'Adicione plantas ilimitadas com Premium',
      PremiumFeature.premiumSupport => 'Acesse suporte prioritário com Premium',
      PremiumFeature.advancedNotifications =>
        'Receba notificações avançadas com Premium',
      PremiumFeature.exportData => 'Exporte seus dados com Premium',
      PremiumFeature.customThemes => 'Personalize o tema com Premium',
    };
  }
}

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/plantis_colors.dart';

/// Features que requerem premium
enum PremiumFeature {
  cloudSync,
  unlimitedPlants,
  premiumSupport,
  advancedNotifications,
  exportData,
  customThemes,
}

/// Widget that gates premium features behind license validation
class PremiumFeatureGate extends ConsumerWidget {
  /// The feature to check access for
  final PremiumFeature feature;

  /// Widget to show when access is granted
  final Widget child;

  /// Widget to show when access is denied (optional)
  final Widget? fallback;

  /// Callback when user tries to access locked feature
  final VoidCallback? onAccessDenied;

  /// Whether to show upgrade prompt when access is denied
  final bool showUpgradePrompt;

  /// Custom upgrade message
  final String? upgradeMessage;

  const PremiumFeatureGate({
    super.key,
    required this.feature,
    required this.child,
    this.fallback,
    this.onAccessDenied,
    this.showUpgradePrompt = true,
    this.upgradeMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Simulação de verificação de premium por enquanto
    // TODO: Implementar verificação real via provider
    final hasAccess = _checkFeatureAccess(feature);

    if (hasAccess) {
      return child;
    }

    // Access denied - show fallback or upgrade prompt
    if (fallback != null) {
      return fallback!;
    }

    if (showUpgradePrompt) {
      return _buildUpgradePrompt(context);
    }

    return const SizedBox.shrink();
  }

  /// Simula verificação de acesso a features premium
  bool _checkFeatureAccess(PremiumFeature feature) {
    // Por enquanto, todas as features retornam false (não premium)
    // TODO: Integrar com provider de premium real
    return false;
  }

  Widget _buildUpgradePrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PlantisColors.primary.withOpacity(0.1),
            PlantisColors.primaryLight.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PlantisColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium,
            color: PlantisColors.primary,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Recurso Premium',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PlantisColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            upgradeMessage ?? _getDefaultMessage(feature),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              onAccessDenied?.call();
              Navigator.of(context).pushNamed('/premium');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PlantisColors.primary,
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

  String _getDefaultMessage(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.cloudSync:
        return 'Sincronize seus dados na nuvem com Premium';
      case PremiumFeature.unlimitedPlants:
        return 'Adicione plantas ilimitadas com Premium';
      case PremiumFeature.premiumSupport:
        return 'Acesse suporte prioritário com Premium';
      case PremiumFeature.advancedNotifications:
        return 'Receba notificações avançadas com Premium';
      case PremiumFeature.exportData:
        return 'Exporte seus dados com Premium';
      case PremiumFeature.customThemes:
        return 'Personalize o tema com Premium';
    }
  }
}

/// Loading state widget for feature gate
class _LoadingGate extends StatelessWidget {
  const _LoadingGate();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Simplified version for basic premium checks
class SimplePremiumGate extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const SimplePremiumGate({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Simulação simples de verificação premium
    const isPremium = false; // TODO: Implementar verificação real

    if (isPremium) {
      return child;
    }

    return fallback ?? 
        PremiumFeatureGate(
          feature: PremiumFeature.cloudSync,
          child: child,
        );
  }
}

/// Widget para mostrar status de expiração
class LicenseExpirationWarning extends ConsumerWidget {
  const LicenseExpirationWarning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implementar verificação de expiração real
    const shouldShowWarning = false;
    const remainingDays = 0;

    if (!shouldShowWarning) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sua licença Premium expira em $remainingDays dias',
              style: TextStyle(color: Colors.orange[800]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/premium'),
            child: const Text('Renovar'),
          ),
        ],
      ),
    );
  }
}
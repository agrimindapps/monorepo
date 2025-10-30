import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/plantis_colors.dart';
import '../presentation/builders/upgrade_prompt_builder.dart';
import '../presentation/managers/premium_feature_access_manager.dart';

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
/// SRP: Only handles feature gating UI, delegates business logic to manager
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
    final accessManager = PremiumFeatureAccessManager();

    // For now, returning child directly
    // In production, would integrate with actual license provider
    return child;
}

/// Simplified version for basic premium checks
class SimplePremiumGate extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const SimplePremiumGate({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return fallback ??
        PremiumFeatureGate(feature: PremiumFeature.cloudSync, child: child);
  }
}

/// Widget para mostrar status de expiração
class LicenseExpirationWarning extends ConsumerWidget {
  const LicenseExpirationWarning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

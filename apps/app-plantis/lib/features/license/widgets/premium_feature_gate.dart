import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/core.dart';

import '../../../core/theme/plantis_colors.dart';
import '../providers/license_provider.dart';

/// Widget that gates premium features behind license validation
class PremiumFeatureGate extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Consumer<LicenseProvider>(
      builder: (context, licenseProvider, _) {
        return FutureBuilder<bool>(
          future: licenseProvider.canAccessFeature(feature),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingGate();
            }

            // Check if access is granted
            final hasAccess = snapshot.data ?? false;

            if (hasAccess) {
              return child;
            }

            // Access denied - show fallback or upgrade prompt
            if (fallback != null) {
              return fallback!;
            }

            if (showUpgradePrompt) {
              return _UpgradePrompt(
                feature: feature,
                onTap: onAccessDenied ?? () => _showUpgradeDialog(context),
                message: upgradeMessage,
              );
            }

            // Default fallback - empty container
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _PremiumUpgradeDialog(feature: feature),
    );
  }
}

/// Widget for gated buttons that require premium access
class PremiumGatedButton extends StatelessWidget {
  /// The feature this button requires
  final PremiumFeature feature;

  /// Button text
  final String text;

  /// Button icon (optional)
  final IconData? icon;

  /// Callback when button is pressed (only called if access is granted)
  final VoidCallback onPressed;

  /// Button style
  final ButtonStyle? style;

  /// Whether button is enabled
  final bool enabled;

  const PremiumGatedButton({
    super.key,
    required this.feature,
    required this.text,
    required this.onPressed,
    this.icon,
    this.style,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LicenseProvider>(
      builder: (context, licenseProvider, _) {
        return FutureBuilder<bool>(
          future: licenseProvider.canAccessFeature(feature),
          builder: (context, snapshot) {
            final hasAccess = snapshot.data ?? false;
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            return ElevatedButton.icon(
              onPressed: (!enabled || isLoading)
                  ? null
                  : hasAccess
                      ? onPressed
                      : () => _showUpgradeDialog(context),
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      hasAccess
                          ? (icon ?? Icons.star)
                          : Icons.lock,
                    ),
              label: Text(hasAccess ? text : '$text (Premium)'),
              style: style ??
                  ElevatedButton.styleFrom(
                    backgroundColor: hasAccess
                        ? PlantisColors.primary
                        : Colors.orange,
                    foregroundColor: Colors.white,
                  ),
            );
          },
        );
      },
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _PremiumUpgradeDialog(feature: feature),
    );
  }
}

/// Widget to display premium badge on features
class PremiumBadge extends StatelessWidget {
  /// Size of the badge
  final double size;

  /// Whether to show text
  final bool showText;

  const PremiumBadge({
    super.key,
    this.size = 20,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showText ? 8 : 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.amber],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium,
            size: size,
            color: Colors.white,
          ),
          if (showText) ...[
            const SizedBox(width: 4),
            const Text(
              'PRO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget to check license status and show warnings
class LicenseStatusIndicator extends StatelessWidget {
  /// Whether to show detailed status
  final bool showDetails;

  /// Custom callback when tapped
  final VoidCallback? onTap;

  const LicenseStatusIndicator({
    super.key,
    this.showDetails = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LicenseProvider>(
      builder: (context, licenseProvider, _) {
        if (!licenseProvider.hasValidLicense) {
          return const SizedBox.shrink();
        }

        if (!licenseProvider.shouldShowExpirationWarning) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onTap ?? () => _showLicenseStatus(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getWarningColor(licenseProvider.warningLevel),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                if (showDetails)
                  Flexible(
                    child: Text(
                      'Trial expira em ${licenseProvider.remainingDays} ${licenseProvider.remainingDays == 1 ? 'dia' : 'dias'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Text(
                    '${licenseProvider.remainingDays}d',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getWarningColor(String warningLevel) {
    switch (warningLevel) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showLicenseStatus(BuildContext context) {
    // Navigate to license status page
    Navigator.of(context).pushNamed('/license-status');
  }
}

/// Loading state for feature gates
class _LoadingGate extends StatelessWidget {
  const _LoadingGate();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: PlantisColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Upgrade prompt widget
class _UpgradePrompt extends StatelessWidget {
  final PremiumFeature feature;
  final VoidCallback onTap;
  final String? message;

  const _UpgradePrompt({
    required this.feature,
    required this.onTap,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium,
              color: Colors.orange,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Recurso Premium',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              feature.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.upgrade),
              label: const Text('Fazer Upgrade'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium upgrade dialog
class _PremiumUpgradeDialog extends StatelessWidget {
  final PremiumFeature feature;

  const _PremiumUpgradeDialog({required this.feature});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.amber],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Recurso Premium'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Para acessar "${feature.displayName}", você precisa fazer upgrade para o plano premium.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PlantisColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: PlantisColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature.description,
                    style: const TextStyle(
                      color: PlantisColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Mais tarde'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            // Navigate to premium page
            Navigator.of(context).pushNamed('/premium');
          },
          icon: const Icon(Icons.upgrade),
          label: const Text('Fazer Upgrade'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
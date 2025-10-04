import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/feature_flags_notifier.dart';
import '../../constants/settings_design_tokens.dart';
import '../dialogs/feature_flags_admin_dialog.dart';

/// Feature Flags Section for Settings Page
///
/// Features:
/// - Feature flags status overview
/// - A/B testing indicators
/// - Admin panel access (debug mode)
/// - Remote config sync status
/// - Dynamic UI based on flags
class FeatureFlagsSection extends ConsumerWidget {
  const FeatureFlagsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureFlagsAsync = ref.watch(featureFlagsNotifierProvider);

    return featureFlagsAsync.when(
      data: (featureFlagsState) {
        final notifier = ref.read(featureFlagsNotifierProvider.notifier);

        // Only show if feature flags indicate production display
        if (!_shouldShowInProduction(notifier)) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: SettingsDesignTokens.sectionMargin,
          elevation: SettingsDesignTokens.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SettingsDesignTokens.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              _buildSectionHeader(context, featureFlagsState),

              // Feature Flags Overview
              _buildFeatureFlagsOverview(context, notifier),

              // A/B Testing Status
              _buildABTestingStatus(context, notifier),

              // Admin Actions (show for development builds)
              if (EnvironmentConfig.isDebugMode)
                _buildAdminActions(context, ref, featureFlagsState),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Determine if section should show in production
  bool _shouldShowInProduction(FeatureFlagsNotifier notifier) {
    // Show if any user-visible A/B tests are active
    return notifier.isNewUiDesignEnabled ||
           notifier.isImprovedOnboardingEnabled ||
           notifier.isGamificationEnabled;
  }

  /// Section Header
  Widget _buildSectionHeader(BuildContext context, FeatureFlagsState featureFlagsState) {
    final theme = Theme.of(context);
    final isInitialized = featureFlagsState.isInitialized;

    return Padding(
      padding: SettingsDesignTokens.sectionHeaderPadding,
      child: Row(
        children: [
          Icon(
            Icons.tune,
            size: SettingsDesignTokens.sectionIconSize,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feature Flags & A/B Testing',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isInitialized ? 'Sistema ativo e sincronizado' : 'Carregando configurações...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Status Indicator
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isInitialized 
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isInitialized ? Icons.check : Icons.sync,
              size: 12,
              color: isInitialized ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  /// Feature Flags Overview
  Widget _buildFeatureFlagsOverview(BuildContext context, FeatureFlagsNotifier notifier) {
    final theme = Theme.of(context);

    final coreFeatures = [
      _FeatureFlagItem('Premium Features', notifier.isPremiumFeaturesEnabled, Icons.workspace_premium),
      _FeatureFlagItem('Advanced Diagnostics', notifier.isAdvancedDiagnosticsEnabled, Icons.science),
      _FeatureFlagItem('Offline Mode', notifier.isOfflineModeEnabled, Icons.cloud_off),
      _FeatureFlagItem('Push Notifications', notifier.isPushNotificationsEnabled, Icons.notifications),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recursos Principais',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Core Features Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: coreFeatures.map((feature) {
              return _buildFeatureFlagChip(context, feature);
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// A/B Testing Status
  Widget _buildABTestingStatus(BuildContext context, FeatureFlagsNotifier notifier) {
    final theme = Theme.of(context);

    final abTests = [
      _ABTestItem('New UI Design', notifier.isNewUiDesignEnabled, 'Variant B'),
      _ABTestItem('Improved Onboarding', notifier.isImprovedOnboardingEnabled, 'Test Group'),
      _ABTestItem('Gamification', notifier.isGamificationEnabled, 'Experimental'),
    ];

    // Only show if any A/B tests are active
    final activeTests = abTests.where((test) => test.isActive).toList();
    if (activeTests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Testes A/B Ativos',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 8),
          
          // A/B Tests
          ...activeTests.map((test) {
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.science,
                    size: 14,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      test.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      test.variant,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Admin Actions (Development Mode Only)
  Widget _buildAdminActions(BuildContext context, WidgetRef ref, FeatureFlagsState featureFlagsState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 8),

          // Admin Panel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openFeatureFlagsAdminPanel(context),
              icon: const Icon(Icons.admin_panel_settings, size: 16),
              label: const Text('Admin Panel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Refresh Remote Config Button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _refreshRemoteConfig(context, ref),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Atualizar Remote Config'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Feature Flag Chip
  Widget _buildFeatureFlagChip(BuildContext context, _FeatureFlagItem feature) {
    final theme = Theme.of(context);
    final isEnabled = feature.isEnabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEnabled 
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isEnabled 
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            feature.icon,
            size: 12,
            color: isEnabled ? Colors.green : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            feature.name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isEnabled ? Colors.green.shade700 : Colors.grey.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Open Feature Flags Admin Panel
  Future<void> _openFeatureFlagsAdminPanel(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const FeatureFlagsAdminDialog(),
    );
  }

  /// Refresh Remote Config
  Future<void> _refreshRemoteConfig(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(featureFlagsNotifierProvider.notifier).refresh();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remote Config atualizado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar Remote Config: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Feature Flag Item Data Model
class _FeatureFlagItem {
  final String name;
  final bool isEnabled;
  final IconData icon;

  const _FeatureFlagItem(this.name, this.isEnabled, this.icon);
}

/// A/B Test Item Data Model
class _ABTestItem {
  final String name;
  final bool isActive;
  final String variant;

  const _ABTestItem(this.name, this.isActive, this.variant);
}
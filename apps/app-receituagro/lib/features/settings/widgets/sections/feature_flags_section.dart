import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_lib;

import '../../../../core/providers/feature_flags_provider.dart';
import '../../constants/settings_design_tokens.dart';
import '../../presentation/providers/settings_provider.dart';
import '../dialogs/feature_flags_admin_dialog.dart';

/// Feature Flags Section for Settings Page
/// 
/// Features:
/// - Feature flags status overview
/// - A/B testing indicators  
/// - Admin panel access (debug mode)
/// - Remote config sync status
/// - Dynamic UI based on flags
class FeatureFlagsSection extends StatelessWidget {
  const FeatureFlagsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return provider_lib.Consumer2<SettingsProvider, FeatureFlagsProvider>(
      builder: (context, settingsProvider, featureFlagsProvider, child) {
        // Only show in development mode or if explicitly enabled
        if (!settingsProvider.isDevelopmentMode && !_shouldShowInProduction(featureFlagsProvider)) {
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
              _buildSectionHeader(context, featureFlagsProvider),
              
              // Feature Flags Overview
              _buildFeatureFlagsOverview(context, featureFlagsProvider),
              
              // A/B Testing Status
              _buildABTestingStatus(context, featureFlagsProvider),
              
              // Admin Actions
              if (settingsProvider.isDevelopmentMode)
                _buildAdminActions(context, featureFlagsProvider),
            ],
          ),
        );
      },
    );
  }

  /// Determine if section should show in production
  bool _shouldShowInProduction(FeatureFlagsProvider featureFlagsProvider) {
    // Show if any user-visible A/B tests are active
    return featureFlagsProvider.isNewUiDesignEnabled ||
           featureFlagsProvider.isImprovedOnboardingEnabled ||
           featureFlagsProvider.isGamificationEnabled;
  }

  /// Section Header
  Widget _buildSectionHeader(BuildContext context, FeatureFlagsProvider featureFlagsProvider) {
    final theme = Theme.of(context);
    final isInitialized = featureFlagsProvider.isInitialized;

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
  Widget _buildFeatureFlagsOverview(BuildContext context, FeatureFlagsProvider featureFlagsProvider) {
    final theme = Theme.of(context);
    
    final coreFeatures = [
      _FeatureFlagItem('Premium Features', featureFlagsProvider.isPremiumFeaturesEnabled, Icons.workspace_premium),
      _FeatureFlagItem('Advanced Diagnostics', featureFlagsProvider.isAdvancedDiagnosticsEnabled, Icons.science),
      _FeatureFlagItem('Offline Mode', featureFlagsProvider.isOfflineModeEnabled, Icons.cloud_off),
      _FeatureFlagItem('Push Notifications', featureFlagsProvider.isPushNotificationsEnabled, Icons.notifications),
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
  Widget _buildABTestingStatus(BuildContext context, FeatureFlagsProvider featureFlagsProvider) {
    final theme = Theme.of(context);
    
    final abTests = [
      _ABTestItem('New UI Design', featureFlagsProvider.isNewUiDesignEnabled, 'Variant B'),
      _ABTestItem('Improved Onboarding', featureFlagsProvider.isImprovedOnboardingEnabled, 'Test Group'),
      _ABTestItem('Gamification', featureFlagsProvider.isGamificationEnabled, 'Experimental'),
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
  Widget _buildAdminActions(BuildContext context, FeatureFlagsProvider featureFlagsProvider) {
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
              onPressed: () => _openFeatureFlagsAdminPanel(context, featureFlagsProvider),
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
              onPressed: () => _refreshRemoteConfig(context, featureFlagsProvider),
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
  Future<void> _openFeatureFlagsAdminPanel(BuildContext context, FeatureFlagsProvider featureFlagsProvider) async {
    await showDialog<void>(
      context: context,
      builder: (context) => FeatureFlagsAdminDialog(provider: featureFlagsProvider),
    );
  }

  /// Refresh Remote Config
  Future<void> _refreshRemoteConfig(BuildContext context, FeatureFlagsProvider featureFlagsProvider) async {
    try {
      await featureFlagsProvider.refresh();
      
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
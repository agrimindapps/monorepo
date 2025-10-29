import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../presentation/providers/index.dart';
import '../shared/settings_card.dart';
import '../shared/section_header.dart';

/// Premium Settings Section
/// Allows users to view premium features and settings
class NewPremiumSection extends ConsumerWidget {
  const NewPremiumSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumNotifierProvider);

    return Column(
      children: [
        SectionHeader(
          title: premiumState.settings.hasPremiumFeatures
              ? 'Premium ✨'
              : 'Plano Atual',
        ),
        SettingsCard(
          child: Column(
            children: [
              _buildStatusCard(context, premiumState),
              const Divider(height: 1),
              _buildFeaturesSection(context, premiumState),
              if (premiumState.settings.isDevelopmentMode)
                const Divider(height: 1),
              if (premiumState.settings.isDevelopmentMode)
                _buildDevModeToggle(context, ref, premiumState),
              if (premiumState.settings.isDevelopmentMode)
                const Divider(height: 1),
              if (premiumState.settings.isDevelopmentMode)
                _buildAnalyticsToggle(context, ref, premiumState),
              if (premiumState.isLoading || premiumState.error != null)
                const Divider(height: 1),
              if (premiumState.isLoading) _buildLoadingIndicator(),
              if (premiumState.error != null)
                _buildErrorMessage(context, premiumState),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, PremiumState premiumState) {
    final hasPremium = premiumState.settings.hasPremiumFeatures;
    final isDev = premiumState.settings.isDevelopmentMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: hasPremium
                ? [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ]
                : [
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                    Theme.of(context).colorScheme.surface,
                  ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hasPremium ? 'Plano Premium' : 'Plano Gratuito',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasPremium
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                ),
                if (isDev)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'DEV',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              premiumState.settings.statusDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: hasPremium
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    PremiumState premiumState,
  ) {
    final features = premiumState.settings.availableFeatures;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Funcionalidades Disponíveis',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getFeatureDisplayName(feature),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevModeToggle(
    BuildContext context,
    WidgetRef ref,
    PremiumState premiumState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modo Desenvolvimento',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Unlocks debug features (⚠️ não salvar)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Switch(
            value: premiumState.settings.isDevelopmentMode,
            onChanged: (value) {
              ref
                  .read(premiumNotifierProvider.notifier)
                  .setDevelopmentMode(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsToggle(
    BuildContext context,
    WidgetRef ref,
    PremiumState premiumState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics Debug',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Log analytics events to console',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Switch(
            value: premiumState.settings.analyticsEnabled,
            onChanged: (value) {
              ref.read(premiumNotifierProvider.notifier).toggleAnalytics();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: SizedBox(
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, PremiumState premiumState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              premiumState.error ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getFeatureDisplayName(String feature) {
    const featureNames = {
      'recipes_unlimited': 'Receitas Ilimitadas',
      'advanced_search': 'Busca Avançada',
      'sync_unlimited': 'Sincronização Sem Limite',
      'offline_mode': 'Modo Offline',
      'export_pdf': 'Exportar para PDF',
    };

    return featureNames[feature] ?? feature;
  }
}

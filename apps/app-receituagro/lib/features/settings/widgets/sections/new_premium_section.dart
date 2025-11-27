import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/premium_notifier.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';

/// Premium Settings Section
/// Allows users to view premium features and settings
class NewPremiumSection extends ConsumerWidget {
  const NewPremiumSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumAsync = ref.watch(premiumProvider);

    return premiumAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorWidget(context, error.toString()),
      data: (premiumState) => Column(
        children: [
          SectionHeader(
            title: premiumState.isPremium ? 'Premium ✨' : 'Plano Atual',
          ),
          SettingsCard(
            child: Column(
              children: [
                _buildStatusCard(context, premiumState),
                const Divider(height: 1),
                _buildFeaturesSection(context, premiumState),
                if (premiumState.isLoading) const Divider(height: 1),
                if (premiumState.isLoading) _buildLoadingIndicator(),
                if (premiumState.lastError != null)
                  _buildErrorMessage(context, premiumState.lastError!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return SettingsCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Erro ao carregar status premium: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, PremiumState premiumState) {
    final hasPremium = premiumState.isPremium;
    final isTrialActive = premiumState.isTrialActive;

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
                if (isTrialActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'TRIAL',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusDescription(premiumState),
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

  String _getStatusDescription(PremiumState state) {
    if (state.isPremium && state.isActive) {
      if (state.isTrialActive) {
        return 'Período de teste ativo';
      }
      final expDate = state.currentSubscription?.expirationDate;
      if (expDate != null) {
        final daysLeft = expDate.difference(DateTime.now()).inDays;
        return 'Ativo - $daysLeft dias restantes';
      }
      return 'Assinatura ativa';
    }
    return 'Atualize para Premium para desbloquear todas as funcionalidades';
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    PremiumState premiumState,
  ) {
    final hasPremium = premiumState.isPremium;
    final features = hasPremium
        ? [
            'Diagnósticos avançados',
            'Busca ilimitada',
            'Modo offline',
            'Exportar relatórios',
            'Suporte prioritário',
          ]
        : [
            'Diagnósticos básicos',
            '5 buscas por dia',
          ];

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
                      feature,
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

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: SizedBox(
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String error) {
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
              error,
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
}

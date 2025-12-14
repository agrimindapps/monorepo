import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../constants/settings_design_tokens.dart';
import '../../../../subscription/presentation/providers/subscription_providers.dart';
import '../shared/new_settings_card.dart';

/// Premium Settings Section
/// Allows users to view premium features and navigate to subscription page
class PremiumSection extends ConsumerWidget {
  const PremiumSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(hasPremiumSubscriptionProvider);

    return isPremiumAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorWidget(context, error.toString()),
      data: (isPremium) => _buildStatusCard(context, isPremium),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Erro ao carregar status premium: $error',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isPremium) {
    if (isPremium) {
      return _buildPremiumActiveCard(context);
    }
    return _buildFreeUserCard(context);
  }

  Widget _buildPremiumActiveCard(BuildContext context) {
    return NewSettingsCard(
      showBorder: true,
      borderColor: SettingsDesignTokens.premiumColor,
      child: InkWell(
        onTap: () => context.push('/subscription'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SettingsDesignTokens.premiumColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: SettingsDesignTokens.premiumColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✨ PetiVeti Premium ✨',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: SettingsDesignTokens.premiumColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Você tem acesso a todos os recursos!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: SettingsDesignTokens.premiumColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreeUserCard(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SettingsDesignTokens.primaryColor,
            SettingsDesignTokens.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: SettingsDesignTokens.primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/subscription'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🐾 PetiVeti Premium 🐾',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Desbloqueie recursos avançados para seus pets',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

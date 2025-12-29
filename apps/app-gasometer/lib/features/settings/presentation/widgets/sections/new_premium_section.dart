import 'package:core/core.dart' hide Column, SubscriptionState;
import 'package:flutter/material.dart';

import '../../../../../core/theme/gasometer_colors.dart';
import '../../../../premium/presentation/providers/premium_notifier.dart';
import '../../../../premium/presentation/widgets/subscription_info_card.dart';

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
      data: (state) {
        return _buildStatusCard(context, state);
      },
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

  Widget _buildStatusCard(
    BuildContext context,
    PremiumNotifierState state,
  ) {
    final isPremium = state.isPremium;
    final subscription = state.premiumStatus.subscription;

    if (isPremium && subscription != null) {
      return SubscriptionInfoCard(
        subscription: subscription,
        onManageTap: () => context.push('/premium'),
      );
    }

    // Card gratuito com visual estilo Plantis (Banner)
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GasometerColors.primary,
            GasometerColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/premium'),
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
                    Icons.workspace_premium,
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
                        '✨ GasOMeter Premium ✨',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Desbloqueie recursos avançados',
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

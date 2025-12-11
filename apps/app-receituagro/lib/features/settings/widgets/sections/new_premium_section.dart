import 'package:core/core.dart' hide Column, SubscriptionState;
import 'package:flutter/material.dart';

import '../../../../core/theme/receituagro_colors.dart';
import '../../../subscription/presentation/providers/subscription_notifier.dart';
import '../../../subscription/presentation/widgets/subscription_info_card.dart';
import '../shared/section_header.dart';

/// Premium Settings Section
/// Allows users to view premium features and settings
class NewPremiumSection extends ConsumerWidget {
  const NewPremiumSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Usa o mesmo provider que o profile usa (subscriptionManagementProvider)
    final subscriptionAsync = ref.watch(subscriptionManagementProvider);

    return subscriptionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorWidget(context, error.toString()),
      data: (subscriptionState) {
        final isPremium = subscriptionState.hasActiveSubscription;

        return _buildStatusCard(context, subscriptionState);
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
    SubscriptionState subscriptionState,
  ) {
    final hasPremium = subscriptionState.hasActiveSubscription;
    final subscription = subscriptionState.currentSubscription;

    if (hasPremium &&
        subscription != null &&
        subscription.expirationDate != null) {
      // ✅ Usa o card bonito com gradiente verde
      return SubscriptionInfoCard(
        subscription: subscription,
        showDetailsButton: true,
        onDetailsPressed: () {
          Navigator.pushNamed(context, '/subscription');
        },
      );
    }

    // Card gratuito com visual estilo Plantis (Banner)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ReceitaAgroColors.primary,
            ReceitaAgroColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/subscription'),
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
                        '✨ Premium ✨',
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../subscription/presentation/providers/subscription_notifier.dart';
import '../../../subscription/presentation/widgets/subscription_progress_widget.dart';

/// Widget para exibir status de assinatura premium
/// Responsabilidade: Display de assinatura, botão de upgrade
class ProfileSubscriptionSection extends ConsumerWidget {
  const ProfileSubscriptionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
          child: Text(
            'Assinatura Premium',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        DecoratedBox(
          decoration: _getCardDecoration(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer(
              builder: (context, ref, child) {
                final subscriptionAsync = ref.watch(
                  subscriptionManagementProvider,
                );

                return subscriptionAsync.when(
                  data: (subscriptionState) {
                    if (!subscriptionState.hasActiveSubscription ||
                        subscriptionState.currentSubscription == null) {
                      return _buildNoPremiumWidget(context);
                    }

                    final subscription = subscriptionState.currentSubscription;
                    if (subscription?.expirationDate == null) {
                      return _buildNoPremiumWidget(context);
                    }

                    return SubscriptionProgressWidget(
                      expirationDate: subscription!.expirationDate!,
                      purchaseDate: subscription.purchaseDate,
                      isSandbox: subscription.isSandbox,
                      isCompact: true,
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => _buildNoPremiumWidget(context),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Widget para quando não tem premium
  Widget _buildNoPremiumWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              color: Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Assinatura Gratuita',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            // Navegar para página de planos
            Navigator.pushNamed(context, '/subscription');
          },
          icon: const Icon(Icons.upgrade, size: 18),
          label: const Text('Assinar Premium'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
      ],
    );
  }

  /// Helper: Decoração de card
  BoxDecoration _getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

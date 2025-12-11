import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../premium/presentation/providers/premium_notifier.dart';
import '../../../premium/presentation/widgets/subscription_info_card.dart';

/// Widget para exibir status de assinatura premium no perfil
class ProfilePremiumSection extends ConsumerWidget {
  const ProfilePremiumSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final premiumAsync = ref.watch(premiumProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
          child: Text(
            'Assinatura Premium',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: GasometerDesignTokens.colorPrimary,
            ),
          ),
        ),
        premiumAsync.when(
          data: (state) {
            if (state.isPremium && state.premiumStatus.subscription != null) {
              return SubscriptionInfoCard(
                subscription: state.premiumStatus.subscription!,
                onManageTap: () => context.push('/premium'),
              );
            }

            return DecoratedBox(
              decoration: _getCardDecoration(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildNoPremiumWidget(context),
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) {
            return DecoratedBox(
              decoration: _getCardDecoration(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildNoPremiumWidget(context),
              ),
            );
          },
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
            context.push('/premium');
          },
          icon: const Icon(Icons.upgrade, size: 18),
          label: const Text('Assinar Premium'),
          style: ElevatedButton.styleFrom(
            backgroundColor: GasometerDesignTokens.colorPrimary,
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

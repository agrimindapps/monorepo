import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../premium/presentation/providers/premium_notifier.dart';
import '../../../premium/presentation/widgets/premium_status_card.dart';
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

            return InkWell(
              onTap: () => context.push('/premium'),
              borderRadius: BorderRadius.circular(16),
              child: const PremiumStatusCard(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) {
            // Fallback to basic card on error, or show nothing if critical
            return InkWell(
              onTap: () => context.push('/premium'),
              borderRadius: BorderRadius.circular(16),
              child: const PremiumStatusCard(),
            );
          },
        ),
      ],
    );
  }
}

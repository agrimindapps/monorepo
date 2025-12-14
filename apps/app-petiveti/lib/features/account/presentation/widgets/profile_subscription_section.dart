import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../subscription/domain/entities/user_subscription.dart';
import '../../../subscription/domain/entities/subscription_plan.dart';
import '../../../subscription/presentation/widgets/subscription_info_card.dart';

/// Widget para exibir status de assinatura premium
class ProfileSubscriptionSection extends ConsumerWidget {
  const ProfileSubscriptionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
          child: Text(
            'Assinatura Premium',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            final isPremium = ref.watch(isPremiumProvider);

            if (isPremium) {
              // Usuário premium - mostrar card de assinatura ativa
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.stars, color: AppColors.primary),
                  title: const Text('Premium Ativo'),
                  subtitle: const Text('Você tem acesso a todos os recursos premium'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                  onTap: () => context.push('/subscription'),
                ),
              );
            } else {
              // Usuário gratuito - mostrar CTA para upgrade
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.workspace_premium, color: Colors.orange),
                  title: const Text('Faça Upgrade para Premium'),
                  subtitle: const Text('Desbloqueie recursos exclusivos'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/subscription'),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

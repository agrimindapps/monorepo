import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SubscriptionSection extends StatelessWidget {
  const SubscriptionSection({
    super.key,
    required this.isPremium,
    this.onUpgrade,
    this.onManageSubscription,
  });

  final bool isPremium;
  final VoidCallback? onUpgrade;
  final VoidCallback? onManageSubscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isPremium
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.shade600,
                    Colors.orange.shade700,
                  ],
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? Colors.white.withAlpha(51)
                          : AppColors.primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isPremium ? Icons.workspace_premium : Icons.star_outline,
                      color: isPremium ? Colors.white : AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPremium ? 'Taskolist Premium' : 'Plano Gratuito',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isPremium ? Colors.white : null,
                          ),
                        ),
                        Text(
                          isPremium
                              ? 'Você tem acesso a todos os recursos!'
                              : 'Desbloqueie recursos avançados',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isPremium
                                ? Colors.white.withAlpha(204)
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (isPremium) ...[
                const SizedBox(height: 16),
                _buildPremiumFeature(
                  icon: Icons.cloud_sync,
                  text: 'Sincronização ilimitada',
                ),
                const SizedBox(height: 8),
                _buildPremiumFeature(
                  icon: Icons.backup,
                  text: 'Backup automático',
                ),
                const SizedBox(height: 8),
                _buildPremiumFeature(
                  icon: Icons.block,
                  text: 'Sem anúncios',
                ),
                if (onManageSubscription != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onManageSubscription,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Gerenciar Assinatura'),
                    ),
                  ),
                ],
              ] else ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildFreeFeatureLimit(
                  context,
                  icon: Icons.list_alt,
                  text: 'Listas limitadas',
                ),
                const SizedBox(height: 8),
                _buildFreeFeatureLimit(
                  context,
                  icon: Icons.cloud_off,
                  text: 'Sincronização básica',
                ),
                if (onUpgrade != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onUpgrade,
                      icon: const Icon(Icons.rocket_launch),
                      label: const Text('Fazer Upgrade'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumFeature({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withAlpha(204)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withAlpha(230),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFreeFeatureLimit(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

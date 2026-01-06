import 'package:core/core.dart' hide Column, SubscriptionState, SubscriptionInfo, subscriptionProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../state/subscription_notifier.dart';

/// Widget de controles de desenvolvimento para testar funcionalidades Premium
/// Só é exibido em modo debug (kDebugMode)
class PremiumDevControls extends ConsumerWidget {
  const PremiumDevControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Só exibe em modo debug
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    final subscriptionState = ref.watch(subscriptionProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.developer_mode,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Controles de Desenvolvimento',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Licença Local',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Use para testar funcionalidades premium durante desenvolvimento.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // License generation buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: subscriptionState.isLoading
                          ? null
                          : () => _generateLicense(context, ref, 7),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('7 dias'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: subscriptionState.isLoading
                          ? null
                          : () => _generateLicense(context, ref, 30),
                        icon: const Icon(Icons.calendar_month, size: 18),
                        label: const Text('30 dias'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Revoke button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: subscriptionState.isLoading
                      ? null
                      : () => _revokeLicense(context, ref),
                    icon: const Icon(
                      Icons.block,
                      size: 18,
                      color: AppColors.error,
                    ),
                    label: const Text(
                      'Revogar Licença',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Divider(),
                
                const SizedBox(height: 16),
                
                // Other actions
                Text(
                  'Outras Ações',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: subscriptionState.isLoading
                          ? null
                          : () => _refreshStatus(context, ref),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Atualizar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: subscriptionState.isLoading
                          ? null
                          : () => _restorePurchases(context, ref),
                        icon: const Icon(Icons.restore, size: 18),
                        label: const Text('Restaurar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Current status card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Atual',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _StatusRow(
                        label: 'Premium',
                        value: subscriptionState.isPremium ? 'Ativo' : 'Inativo',
                        valueColor: subscriptionState.isPremium 
                            ? AppColors.success 
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      _StatusRow(
                        label: 'Fonte',
                        value: ref.read(subscriptionProvider.notifier).premiumSource,
                      ),
                      if (subscriptionState.currentSubscription?.expirationDate != null) ...[
                        const SizedBox(height: 4),
                        _StatusRow(
                          label: 'Expira',
                          value: _formatDate(subscriptionState.currentSubscription!.expirationDate!),
                        ),
                      ],
                      if (ref.read(subscriptionProvider.notifier).isDevLicense) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.science,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Licença de Teste',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateLicense(
    BuildContext context,
    WidgetRef ref,
    int days,
  ) async {
    try {
      await ref.read(subscriptionProvider.notifier).generateLocalLicense(days: days);
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Licença local gerada por $days dias'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar licença: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _revokeLicense(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Licença'),
        content: const Text(
          'Tem certeza que deseja revogar a licença local? '
          'Isso removerá o acesso premium de desenvolvimento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Revogar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(subscriptionProvider.notifier).revokeLocalLicense();
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Licença local revogada'),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao revogar licença: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _refreshStatus(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await ref.read(subscriptionProvider.notifier).refresh();
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status atualizado'),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _restorePurchases(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final result = await ref.read(subscriptionProvider.notifier).restorePurchases();
      if (!context.mounted) return;
      
      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        (subscriptions) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                subscriptions.isNotEmpty 
                  ? 'Compras restauradas com sucesso'
                  : 'Nenhuma compra encontrada para restaurar',
              ),
              backgroundColor: subscriptions.isNotEmpty ? AppColors.success : AppColors.info,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao restaurar compras: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year} '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Widget auxiliar para exibir uma linha de status
class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatusRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

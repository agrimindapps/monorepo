import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/index.dart';
import '../../providers/index.dart';

/// Widget que exibe e gerencia o status de subscription
///
/// Responsabilidades:
/// - Exibir status atual (ativo, expirado, etc)
/// - Mostrar tier e data de expiração
/// - Exibir progresso de expiração
/// - Oferecer ações (upgrade, downgrade, cancel)
/// - Indicadores visuais de urgência
class SubscriptionStatusSection extends ConsumerWidget {
  const SubscriptionStatusSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(userSubscriptionProvider);
    final actions = ref.read(subscriptionActionsProvider);

    // Se não há subscription, mostrar card de chamada para ação
    if (!subscription.hasActiveSubscription) {
      return _buildNoSubscriptionCard(context, actions);
    }

    final sub = subscription.subscription!;

    return Column(
      children: [
        // Card principal com status
        Container(
          decoration: BoxDecoration(
            color: _getStatusColor(sub.status),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusBorderColor(sub.status),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Minha Assinatura',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  _buildStatusBadge(sub.status),
                ],
              ),
              const SizedBox(height: 16),

              // Tier e informações
              Text(
                'Plano: ${_tierDisplayName(sub.tier)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              // Data de expiração
              if (sub.expirationDate != null)
                Text(
                  'Expira em: ${_formatDate(sub.expirationDate!)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 16),

              // Progress bar de vida da assinatura
              if (sub.expirationDate != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: sub.percentageExpired / 100.0,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(sub.percentageExpired),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${sub.percentageExpired.toStringAsFixed(0)}% de vida da assinatura',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],

              const SizedBox(height: 16),

              // Auto-renewal status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      sub.isAutoRenewing ? Icons.check_circle : Icons.info,
                      size: 16,
                      color: sub.isAutoRenewing ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      sub.isAutoRenewing
                          ? 'Renovação automática ativa'
                          : 'Renovação automática desativada',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Botões de ação
        _buildActionButtons(context, sub, actions),
      ],
    );
  }

  /// Card exibido quando não há subscription ativa
  Widget _buildNoSubscriptionCard(
    BuildContext context,
    SubscriptionActions actions,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.star_outline, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'Sem Assinatura Ativa',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Faça upgrade para acessar recursos premium',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Navegar para tela de upgrade
            },
            child: const Text('Ver Planos'),
          ),
        ],
      ),
    );
  }

  /// Cria os botões de ação (upgrade, downgrade, cancel)
  Widget _buildActionButtons(
    BuildContext context,
    SubscriptionEntity subscription,
    SubscriptionActions actions,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Botão de upgrade (se não for tier máximo)
        if (subscription.tier.index < SubscriptionTier.ultimate.index)
          OutlinedButton(
            onPressed: () {
              _showUpgradeDialog(context, subscription, actions);
            },
            child: const Text('Upgrade'),
          ),

        // Botão de downgrade (se não for tier mínimo)
        if (subscription.tier.index > SubscriptionTier.free.index)
          OutlinedButton(
            onPressed: () {
              _showDowngradeDialog(context, subscription, actions);
            },
            child: const Text('Downgrade'),
          ),

        // Botão de cancelamento
        OutlinedButton(
          onPressed: () {
            _showCancelDialog(context, actions);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  /// Dialog de upgrade
  void _showUpgradeDialog(
    BuildContext context,
    SubscriptionEntity currentSubscription,
    SubscriptionActions actions,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fazer Upgrade'),
        content: const Text('Escolha um novo plano para fazer upgrade:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar seleção de plano
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  /// Dialog de downgrade
  void _showDowngradeDialog(
    BuildContext context,
    SubscriptionEntity currentSubscription,
    SubscriptionActions actions,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fazer Downgrade'),
        content: const Text(
          'Tem certeza que deseja fazer downgrade? Você perderá acesso a alguns recursos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar downgrade
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Confirmar Downgrade'),
          ),
        ],
      ),
    );
  }

  /// Dialog de cancelamento
  void _showCancelDialog(BuildContext context, SubscriptionActions actions) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Assinatura'),
        content: const Text(
          'Tem certeza? Você perderá acesso imediato aos recursos premium.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Manter'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar cancelamento
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar Assinatura'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green.shade50;
      case SubscriptionStatus.expired:
        return Colors.red.shade50;
      case SubscriptionStatus.cancelled:
        return Colors.grey.shade100;
      case SubscriptionStatus.paused:
        return Colors.orange.shade50;
      case SubscriptionStatus.pending:
        return Colors.blue.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getStatusBorderColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.expired:
        return Colors.red;
      case SubscriptionStatus.cancelled:
        return Colors.grey;
      case SubscriptionStatus.paused:
        return Colors.orange;
      case SubscriptionStatus.pending:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(SubscriptionStatus status) {
    final (label, color) = _getStatusLabelAndColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  (String, Color) _getStatusLabelAndColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return ('ATIVO', Colors.green);
      case SubscriptionStatus.expired:
        return ('EXPIRADO', Colors.red);
      case SubscriptionStatus.cancelled:
        return ('CANCELADO', Colors.grey);
      case SubscriptionStatus.paused:
        return ('PAUSADO', Colors.orange);
      case SubscriptionStatus.pending:
        return ('PENDENTE', Colors.blue);
      default:
        return ('DESCONHECIDO', Colors.grey);
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 30) return Colors.green;
    if (percentage < 60) return Colors.orange;
    if (percentage < 80) return Colors.deepOrange;
    return Colors.red;
  }

  String _tierDisplayName(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 'Gratuito';
      case SubscriptionTier.basic:
        return 'Básico';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.ultimate:
        return 'Ultimate';
      case SubscriptionTier.lifetime:
        return 'Vitalício';
      case SubscriptionTier.trial:
        return 'Trial';
      default:
        return 'Desconhecido';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

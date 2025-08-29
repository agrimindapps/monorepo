import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_subscription.dart';
import '../providers/subscription_provider.dart';
import 'subscription_page_coordinator.dart';

/// Widget responsible for displaying current subscription information
class CurrentSubscriptionCard extends ConsumerWidget {
  final UserSubscription subscription;
  final String userId;
  final SubscriptionState state;

  const CurrentSubscriptionCard({
    super.key,
    required this.subscription,
    required this.userId,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = subscription.plan;
    final statusInfo = _getStatusInfo(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, statusInfo),
            const SizedBox(height: 16),
            _buildPlanInfo(context, plan),
            const SizedBox(height: 8),
            _buildStatusAndPrice(context, plan, statusInfo),
            ..._buildSubscriptionDetails(context),
            const SizedBox(height: 16),
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, _SubscriptionStatusInfo statusInfo) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: statusInfo.color),
        const SizedBox(width: 8),
        Text(
          'Assinatura Atual',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildPlanInfo(BuildContext context, dynamic plan) {
    return Text(
      plan?.title?.toString() ?? 'Plano não identificado',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildStatusAndPrice(BuildContext context, dynamic plan, _SubscriptionStatusInfo statusInfo) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusInfo.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            statusInfo.text,
            style: TextStyle(
              color: statusInfo.color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const Spacer(),
        Text(
          plan?.formattedPrice?.toString() ?? 'Preço não disponível',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  List<Widget> _buildSubscriptionDetails(BuildContext context) {
    final details = <Widget>[];

    if (subscription.expirationDate != null) {
      details.addAll([
        const SizedBox(height: 8),
        Text(
          'Expira em: ${_formatDate(subscription.expirationDate!)}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ]);
    }

    if (subscription.isInTrialPeriod) {
      details.addAll([
        const SizedBox(height: 8),
        Text(
          'Teste grátis termina em ${subscription.daysUntilTrialEnd} dias',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ]);
    }

    if (subscription.willExpireSoon) {
      details.addAll([
        const SizedBox(height: 8),
        Text(
          'Sua assinatura expira em ${subscription.daysUntilExpiration} dias',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ]);
    }

    return details;
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        if (subscription.isActive && !subscription.isCancelled) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: state.isCancelling ? null : () => _showCancelDialog(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: state.isCancelling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cancel, size: 18),
              label: Text(state.isCancelling ? 'Cancelando...' : 'Cancelar'),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (subscription.isPaused) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: state.isResuming 
                  ? null 
                  : () => SubscriptionPageCoordinator.resumeSubscription(
                        ref, 
                        context, 
                        userId,
                      ),
              icon: state.isResuming
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow, size: 18),
              label: Text(state.isResuming ? 'Retomando...' : 'Retomar'),
            ),
          ),
        ],
      ],
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Assinatura'),
        content: const Text(
          'Tem certeza que deseja cancelar sua assinatura? '
          'Você ainda terá acesso às funcionalidades premium até o final do período pago.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Manter Assinatura'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              SubscriptionPageCoordinator.cancelSubscription(ref, context, userId);
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  _SubscriptionStatusInfo _getStatusInfo(BuildContext context) {
    Color statusColor = Theme.of(context).colorScheme.primary;
    String statusText = 'Ativo';
    
    if (subscription.isCancelled) {
      statusColor = Theme.of(context).colorScheme.error;
      statusText = 'Cancelado';
    } else if (subscription.isPaused) {
      statusColor = Theme.of(context).colorScheme.secondary;
      statusText = 'Pausado';
    } else if (subscription.isExpired) {
      statusColor = Theme.of(context).colorScheme.error;
      statusText = 'Expirado';
    } else if (subscription.isInTrialPeriod) {
      statusColor = Theme.of(context).colorScheme.tertiary;
      statusText = 'Período de teste';
    }

    return _SubscriptionStatusInfo(color: statusColor, text: statusText);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _SubscriptionStatusInfo {
  final Color color;
  final String text;

  const _SubscriptionStatusInfo({
    required this.color,
    required this.text,
  });
}
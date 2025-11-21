import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/index.dart';

/// Widget que exibe e gerencia o estado de período experimental
class TrialSection extends ConsumerWidget {
  const TrialSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(userSubscriptionProvider);

    if (!subscription.hasActiveTrial) {
      return _buildNoTrialCard(context);
    }

    final trial = subscription.trial!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Período Experimental',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ATIVO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Informações do trial
          Text(
            '${subscription.trialDaysRemaining?.inDays ?? 0} dias restantes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Expira: ${_formatDate(trial.endDate)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: subscription.trialProgressPercentage / 100.0,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                subscription.trialProgressPercentage < 50
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${subscription.trialProgressPercentage.toStringAsFixed(0)}% de progresso',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 16),

          // Buttons
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Navegar para tela de upgrade
                },
                child: const Text('Fazer Upgrade'),
              ),
              OutlinedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cancelar Trial'),
                      content: const Text('Tem certeza?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Não'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implementar
                            Navigator.pop(context);
                          },
                          child: const Text('Sim, Cancelar'),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoTrialCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.card_giftcard, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'Nenhum Trial Ativo',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Comece seu período experimental agora',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: const Text('Iniciar Trial')),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}

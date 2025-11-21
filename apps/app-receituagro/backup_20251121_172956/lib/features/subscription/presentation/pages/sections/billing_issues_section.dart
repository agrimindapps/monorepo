import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/index.dart';

/// Widget que exibe e gerencia problemas de cobrança
class BillingIssuesSection extends ConsumerWidget {
  const BillingIssuesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(userSubscriptionProvider);

    if (!subscription.hasBillingIssues) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Nenhum problema de cobrança',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Problemas de Cobrança',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        ...subscription.billingIssuesThatNeedAttention.map((issue) {
          final isCritical = issue.isCritical;
          return Container(
            decoration: BoxDecoration(
              color: isCritical ? Colors.red.shade50 : Colors.orange.shade50,
              border: Border.all(
                color: isCritical ? Colors.red : Colors.orange,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCritical ? Icons.error : Icons.warning,
                      color: isCritical ? Colors.red : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        issue.type.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  issue.displayMessage,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (issue.canRetry)
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Retry'),
                      ),
                    if (issue.requiresUserAction)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: OutlinedButton(
                            onPressed: () {},
                            child: Text(issue.suggestedAction),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

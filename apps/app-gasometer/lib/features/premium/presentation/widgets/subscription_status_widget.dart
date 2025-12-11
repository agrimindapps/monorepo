import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../providers/premium_notifier.dart';
import 'subscription_progress_widget.dart';

class SubscriptionStatusWidget extends ConsumerWidget {
  const SubscriptionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumAsync = ref.watch(premiumProvider);

    return premiumAsync.when(
      data: (premiumState) {
        final subscription = premiumState.premiumStatus.subscription;
        if (subscription == null) return const SizedBox.shrink();

        return Column(
          children: [
            _buildCompactHeader(context, subscription),
            const SizedBox(height: 12),
            if (subscription.expirationDate != null)
              SubscriptionProgressWidget(
                expirationDate: subscription.expirationDate!,
                purchaseDate: subscription.purchaseDate,
                isSandbox: subscription.isSandbox,
                isCompact: false,
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildCompactHeader(BuildContext context, SubscriptionEntity subscription) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3), // Gasometer Primary
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.directions_car, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Premium Ativo',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatProductName(subscription.productId),
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getPlanPrice(subscription.productId),
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatProductName(String productId) {
    final productLower = productId.toLowerCase();

    if (productLower.contains('mensal')) {
      return 'Plano Mensal';
    } else if (productLower.contains('semestral')) {
      return 'Plano Semestral';
    } else if (productLower.contains('anual')) {
      return 'Plano Anual';
    }

    return productId;
  }

  String _getPlanPrice(String productId) {
    final productLower = productId.toLowerCase();

    if (productLower.contains('mensal')) {
      return 'R\$ 19,90/mês';
    } else if (productLower.contains('semestral')) {
      return 'R\$ 99,90/semestre';
    } else if (productLower.contains('anual')) {
      return 'R\$ 179,90/ano';
    }

    return 'Premium';
  }
}

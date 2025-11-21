import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/receituagro_colors.dart';
import '../providers/subscription_notifier.dart';
import 'subscription_progress_widget.dart';

/// Widget responsável pela exibição do status de subscription ativa
///
/// VERSÃO REFATORADA - UX/UI Melhorado:
/// - Header compacto com badge premium (ícone temático agrícola)
/// - Barra de progresso como elemento PRINCIPAL
/// - Card de detalhes financeiros (NOVO)
/// - Remoção de decorações excessivas
///
/// Layout:
/// 1. Header compacto com badges de status
/// 2. Barra de progresso (elemento principal)
/// 3. Detalhes financeiros (valor, renovação, método)
class SubscriptionStatusWidget extends ConsumerWidget {
  const SubscriptionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionNotifierProvider);

    return subscriptionAsync.when(
      data: (subscriptionState) {
        final subscription = subscriptionState.currentSubscription;
        if (subscription == null) return const SizedBox.shrink();

        return Column(
          children: [
            // Header compacto (substituindo card gigante verde)
            _buildCompactHeader(context, subscription),

            const SizedBox(height: 12),

            // Barra de progresso como elemento PRINCIPAL
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

  /// Header compacto com badge premium e valor do plano
  Widget _buildCompactHeader(BuildContext context, dynamic subscription) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícone agrícola com destaque verde
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ReceitaAgroColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: ReceitaAgroColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 24),
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
                  // Nome do plano + Valor
                  Row(
                    children: [
                      Text(
                        _formatProductName(
                          (subscription.productId as String?) ?? 'Premium',
                        ),
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
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getPlanPrice(
                          (subscription.productId as String?) ?? '',
                        ),
                        style: const TextStyle(
                          color: ReceitaAgroColors.primary,
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

  /// Formatar nome do produto
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

  /// Obter valor do plano formatado
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

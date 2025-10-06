import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_notifier.dart';

/// Widget responsável pela exibição do status de subscription ativa
///
/// Funcionalidades:
/// - Card com status premium ativo
/// - Informações do plano atual
/// - Data de renovação
/// - Design celebrativo com gradient verde
/// - Icon de check circle
///
/// Layout:
/// - Card com gradient verde
/// - Icon de sucesso central
/// - Título celebrativo
/// - Descrição dos benefícios
/// - Informações técnicas (plano, renovação)
class SubscriptionStatusWidget extends ConsumerWidget {
  const SubscriptionStatusWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionNotifierProvider);

    return subscriptionAsync.when(
      data: (subscriptionState) {
        final notifier = ref.read(subscriptionNotifierProvider.notifier);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                _buildSuccessIcon(),

                const SizedBox(height: 16),
                _buildCelebrationTitle(),

                const SizedBox(height: 8),
                _buildBenefitsDescription(),
                if (subscriptionState.currentSubscription != null) ...[
                  const SizedBox(height: 16),
                  _buildSubscriptionDetails(subscriptionState.currentSubscription, notifier),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  /// Icon de sucesso centralizado
  Widget _buildSuccessIcon() {
    return const Icon(
      Icons.check_circle,
      color: Colors.white,
      size: 48,
    );
  }

  /// Título celebrativo
  Widget _buildCelebrationTitle() {
    return const Text(
      '🎉 Você é Premium!',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Descrição dos benefícios
  Widget _buildBenefitsDescription() {
    return Text(
      'Aproveite todos os recursos do Pragas Soja',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 16,
      ),
    );
  }

  /// Detalhes da subscription atual
  Widget _buildSubscriptionDetails(dynamic subscription, SubscriptionNotifier notifier) {
    if (subscription == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Plano: ${subscription.productId}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subscription.expirationDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Renovação: ${notifier.formatDate(subscription.expirationDate as DateTime)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
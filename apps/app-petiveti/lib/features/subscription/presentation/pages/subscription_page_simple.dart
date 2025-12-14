import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Simplified Subscription Page using core package providers
class SubscriptionPageSimple extends ConsumerWidget {
  final String userId;

  const SubscriptionPageSimple({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinaturas Premium'),
      ),
      body: subscriptionState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        active: (info) => _buildActiveSubscription(context, info),
        expired: (info) => _buildExpiredSubscription(context, ref, info),
        inactive: () => _buildInactiveSubscription(context, ref),
        error: (message) => _buildError(context, message),
      ),
    );
  }

  Widget _buildActiveSubscription(BuildContext context, SubscriptionInfo info) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Assinatura Ativa',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Plano', info.productId),
                if (info.expirationDate != null)
                  _buildInfoRow(
                    'Expira em',
                    _formatDate(info.expirationDate!),
                  ),
                if (info.isTrialPeriod)
                  Chip(
                    label: const Text('Período de teste'),
                    backgroundColor: Colors.blue.shade100,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildPremiumFeatures(context),
      ],
    );
  }

  Widget _buildExpiredSubscription(
    BuildContext context,
    WidgetRef ref,
    SubscriptionInfo info,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Assinatura Expirada',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Renove sua assinatura para continuar aproveitando os benefícios premium',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSubscribeButton(context, ref),
      ],
    );
  }

  Widget _buildInactiveSubscription(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.workspace_premium, size: 64, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  'Desbloqueie Recursos Premium',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Assine para ter acesso completo a todos os recursos',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildPremiumFeatures(context),
        const SizedBox(height: 24),
        _buildSubscribeButton(context, ref),
        const SizedBox(height: 16),
        _buildRestoreButton(context, ref),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar assinatura',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatures(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recursos Premium',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildFeatureItem('Sem anúncios'),
            _buildFeatureItem('Backup automático em nuvem'),
            _buildFeatureItem('Número ilimitado de pets'),
            _buildFeatureItem('Lembretes avançados'),
            _buildFeatureItem('Suporte prioritário'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(feature),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement subscription flow with RevenueCat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Funcionalidade em desenvolvimento'),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      child: const Text(
        'Assinar Premium',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () async {
        final actions = ref.read(purchaseActionsProvider);
        await actions.restorePurchases();
      },
      icon: const Icon(Icons.restore),
      label: const Text('Restaurar Compras'),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

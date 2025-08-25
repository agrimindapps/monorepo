import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription_plan.dart';
import '../providers/subscription_provider.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  final String userId;

  const SubscriptionPage({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionProvider.notifier).loadAvailablePlans();
      ref.read(subscriptionProvider.notifier).loadCurrentSubscription(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionProvider);

    ref.listen<SubscriptionState>(subscriptionProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(subscriptionProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinaturas'),
        actions: [
          if (state.currentSubscription != null)
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () => _restorePurchases(),
              tooltip: 'Restaurar Compras',
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.currentSubscription != null) ...[
                    _buildCurrentSubscriptionCard(state),
                    const SizedBox(height: 24),
                  ],
                  
                  _buildHeader(),
                  const SizedBox(height: 24),
                  
                  if (state.availablePlans.isNotEmpty) ...[
                    ...state.availablePlans.where((p) => !p.isFree).map(
                      (plan) => _buildPlanCard(plan, state),
                    ),
                  ] else ...[
                    const Center(
                      child: Text(
                        'Nenhum plano disponível no momento',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  _buildFeatureComparison(),
                  const SizedBox(height: 32),
                  _buildRestoreButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentSubscriptionCard(SubscriptionState state) {
    final subscription = state.currentSubscription!;
    final plan = subscription.plan;

    Color statusColor = Colors.green;
    String statusText = 'Ativo';
    
    if (subscription.isCancelled) {
      statusColor = Colors.red;
      statusText = 'Cancelado';
    } else if (subscription.isPaused) {
      statusColor = Colors.orange;
      statusText = 'Pausado';
    } else if (subscription.isExpired) {
      statusColor = Colors.red;
      statusText = 'Expirado';
    } else if (subscription.isInTrialPeriod) {
      statusColor = Colors.blue;
      statusText = 'Período de teste';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  'Assinatura Atual',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              plan.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  plan.formattedPrice,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            
            if (subscription.expirationDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Expira em: ${_formatDate(subscription.expirationDate!)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            
            if (subscription.isInTrialPeriod) ...[
              const SizedBox(height: 8),
              Text(
                'Teste grátis termina em ${subscription.daysUntilTrialEnd} dias',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            
            if (subscription.willExpireSoon) ...[
              const SizedBox(height: 8),
              Text(
                'Sua assinatura expira em ${subscription.daysUntilExpiration} dias',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            Row(
              children: [
                if (subscription.isActive && !subscription.isCancelled) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (subscription.isPaused) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _resumeSubscription(),
                      child: const Text('Retomar'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          Icons.star,
          size: 64,
          color: Colors.amber,
        ),
        const SizedBox(height: 16),
        Text(
          'Desbloqueie Todo o Potencial',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Acesse todas as funcionalidades premium e cuide melhor dos seus pets',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, SubscriptionState state) {
    final isCurrentPlan = state.currentSubscription?.planId == plan.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: plan.isPopular ? 8 : 2,
        child: DecoratedBox(
          decoration: plan.isPopular
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue, width: 2),
                )
              : const BoxDecoration(),
          child: Stack(
            children: [
              if (plan.isPopular)
                Positioned(
                  top: -1,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'MAIS POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                plan.description,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (plan.hasDiscount) ...[
                              Text(
                                '${plan.currency} ${plan.originalPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-${plan.discountPercentage.round()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            Text(
                              plan.formattedPrice,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: plan.isPopular ? Colors.blue : null,
                                  ),
                            ),
                            Text(
                              plan.billingPeriod,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    if (plan.hasTrial) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Teste grátis de ${plan.trialDays} dias',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Features
                    ...plan.features.map(
                      (feature) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(feature),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isCurrentPlan ? null : () => _subscribeToPlan(plan),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: plan.isPopular ? Colors.blue : null,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          isCurrentPlan ? 'Plano Atual' : 'Assinar Agora',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compare os Recursos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            _buildFeatureRow('Animais ilimitados', free: false, premium: true),
            _buildFeatureRow('Todas as calculadoras', free: false, premium: true),
            _buildFeatureRow('Controle de medicamentos', free: false, premium: true),
            _buildFeatureRow('Lembretes avançados', free: false, premium: true),
            _buildFeatureRow('Controle de despesas', free: false, premium: true),
            _buildFeatureRow('Backup na nuvem', free: false, premium: true),
            _buildFeatureRow('Relatórios detalhados', free: false, premium: true),
            _buildFeatureRow('Suporte prioritário', free: false, premium: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, {required bool free, required bool premium}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(feature),
          ),
          Expanded(
            child: Icon(
              free ? Icons.check : Icons.close,
              color: free ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          Expanded(
            child: Icon(
              premium ? Icons.check : Icons.close,
              color: premium ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreButton() {
    return OutlinedButton(
      onPressed: _restorePurchases,
      child: const Text('Restaurar Compras'),
    );
  }

  void _subscribeToPlan(SubscriptionPlan plan) async {
    final success = await ref.read(subscriptionProvider.notifier).subscribeToPlan(
          widget.userId,
          plan.id,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Assinatura do ${plan.title} ativada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showCancelDialog() {
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
              _cancelSubscription();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _cancelSubscription() async {
    final success = await ref.read(subscriptionProvider.notifier).cancelSubscription(widget.userId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assinatura cancelada com sucesso'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _resumeSubscription() async {
    final success = await ref.read(subscriptionProvider.notifier).resumeSubscription(widget.userId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assinatura retomada com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _restorePurchases() async {
    final success = await ref.read(subscriptionProvider.notifier).restorePurchases(widget.userId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compras restauradas com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
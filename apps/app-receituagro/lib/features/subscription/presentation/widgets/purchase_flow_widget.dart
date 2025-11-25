import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/feature_flags_notifier.dart';
import '../providers/subscription_notifier.dart';

/// Advanced Purchase Flow Widget with RevenueCat Integration
///
/// Features:
/// - Multi-step purchase flow
/// - Plan comparison with A/B testing
/// - RevenueCat product loading and validation
/// - Purchase success/error handling
/// - Promotional pricing display
/// - Trial period management
class PurchaseFlowWidget extends ConsumerStatefulWidget {
  final bool showTrialFirst;
  final String? promoCode;
  final VoidCallback? onPurchaseSuccess;
  final VoidCallback? onPurchaseError;
  final VoidCallback? onPurchaseCancelled;

  const PurchaseFlowWidget({
    super.key,
    this.showTrialFirst = true,
    this.promoCode,
    this.onPurchaseSuccess,
    this.onPurchaseError,
    this.onPurchaseCancelled,
  });

  @override
  ConsumerState<PurchaseFlowWidget> createState() => _PurchaseFlowWidgetState();
}

class _PurchaseFlowWidgetState extends ConsumerState<PurchaseFlowWidget>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _slideController;

  int _currentStep = 0;
  bool _isPurchasing = false;
  String? _selectedPlanId;

  static const List<String> _stepTitles = [
    'Escolha seu plano',
    'Confirme a compra',
    'Processando...',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = ref.watch(subscriptionManagementProvider);
    final featureFlagsAsync = ref.watch(featureFlagsProvider);

    return subscriptionAsync.when(
      data: (subscriptionState) {
        return featureFlagsAsync.when(
          data: (featureFlagsState) {
            final subscriptionNotifier = ref.read(
              subscriptionManagementProvider.notifier,
            );
            final featureFlagsNotifier = ref.read(
              featureFlagsProvider.notifier,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressIndicator(context),

                const SizedBox(height: 24),
                SizedBox(
                  height: 500,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPlanSelectionStep(
                        context,
                        subscriptionNotifier,
                        subscriptionState,
                        featureFlagsNotifier,
                      ),
                      _buildConfirmationStep(
                        context,
                        subscriptionNotifier,
                        subscriptionState,
                      ),
                      _buildProcessingStep(context),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  /// Progress Indicator
  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _stepTitles[_currentStep],
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _stepTitles.length,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),

          const SizedBox(height: 8),
          Row(
            children: List.generate(_stepTitles.length, (index) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Step 1: Plan Selection
  Widget _buildPlanSelectionStep(
    BuildContext context,
    SubscriptionManagementNotifier subscriptionNotifier,
    SubscriptionState subscriptionState,
    FeatureFlagsNotifier featureFlagsNotifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTrialFirst && subscriptionState.hasTrialAvailable)
            _buildTrialOfferCard(context, subscriptionNotifier),

          const SizedBox(height: 24),
          Text(
            'Planos Disponíveis',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...subscriptionNotifier.availablePlans.map((plan) {
            return _buildPlanCard(context, plan, subscriptionNotifier);
          }),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedPlanId != null ? _goToConfirmation : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTermsText(context),
        ],
      ),
    );
  }

  /// Step 2: Purchase Confirmation
  Widget _buildConfirmationStep(
    BuildContext context,
    SubscriptionManagementNotifier subscriptionNotifier,
    SubscriptionState subscriptionState,
  ) {
    final selectedPlan = subscriptionNotifier.availablePlans.firstWhere(
      (plan) => plan['id'] == _selectedPlanId,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      selectedPlan['title'] as String,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      selectedPlan['priceString'] as String,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ ${selectedPlan['period'] as String}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (selectedPlan['hasTrialPeriod'] as bool) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${selectedPlan['trialPeriodDays'] as int} dias grátis',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'O que está incluído:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          ...(selectedPlan['features'] as List<String>).map((feature) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPurchasing ? null : _processPurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isPurchasing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Processando...'),
                      ],
                    )
                  : Text(
                      'Confirmar Compra • ${selectedPlan['priceString'] as String}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isPurchasing ? null : _goBackToPlanSelection,
              child: const Text('Voltar'),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 3: Processing
  Widget _buildProcessingStep(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 24),
          Text(
            'Processando sua compra...',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Por favor, aguarde alguns instantes',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Trial Offer Card
  Widget _buildTrialOfferCard(
    BuildContext context,
    SubscriptionManagementNotifier subscriptionNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Oferta Especial',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '7 dias grátis para testar todos os recursos Premium',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startTrial(subscriptionNotifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Iniciar Teste Grátis',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Individual Plan Card
  Widget _buildPlanCard(
    BuildContext context,
    dynamic plan,
    SubscriptionManagementNotifier subscriptionNotifier,
  ) {
    final isSelected = _selectedPlanId == plan.id;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _selectPlan(plan['id'] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio<String>(
                  value: (plan as Map<String, dynamic>)['id'] as String,
                  onChanged: (String? value) {
                    if (value != null) {
                      _selectPlan(value);
                    }
                  },
                ),

                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan['title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plan['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan['priceString'] as String,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '/ ${plan['period'] as String}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (plan['isPromotional'] as bool) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'OFERTA LIMITADA',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.red,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Terms and Conditions Text
  Widget _buildTermsText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'Ao continuar, você concorda com nossos Termos de Uso e Política de Privacidade. '
        'A assinatura será renovada automaticamente, podendo ser cancelada a qualquer momento.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Select Plan
  void _selectPlan(String? planId) {
    setState(() {
      _selectedPlanId = planId;
    });
  }

  /// Go to Confirmation Step
  void _goToConfirmation() {
    setState(() {
      _currentStep = 1;
    });
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _slideController.forward();
  }

  /// Go Back to Plan Selection
  void _goBackToPlanSelection() {
    setState(() {
      _currentStep = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _slideController.reverse();
  }

  /// Start Trial
  Future<void> _startTrial(SubscriptionManagementNotifier subscriptionNotifier) async {
    try {
      setState(() {
        _isPurchasing = true;
        _currentStep = 2;
      });

      await _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      await subscriptionNotifier.startFreeTrial();

      if (widget.onPurchaseSuccess != null) {
        widget.onPurchaseSuccess!();
      }
    } catch (e) {
      if (widget.onPurchaseError != null) {
        widget.onPurchaseError!();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  /// Process Purchase
  Future<void> _processPurchase() async {
    if (_selectedPlanId == null) return;

    try {
      setState(() {
        _isPurchasing = true;
        _currentStep = 2;
      });

      await _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      if (!mounted) return;
      final subscriptionNotifier = ref.read(
        subscriptionManagementProvider.notifier,
      );
      await subscriptionNotifier.purchasePlan(_selectedPlanId!);

      if (widget.onPurchaseSuccess != null) {
        widget.onPurchaseSuccess!();
      }
    } catch (e) {
      if (widget.onPurchaseError != null) {
        widget.onPurchaseError!();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }
}

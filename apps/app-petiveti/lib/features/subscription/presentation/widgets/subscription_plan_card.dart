import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription_plan.dart';
import '../providers/subscription_provider.dart';
import 'subscription_page_coordinator.dart';

/// Widget responsible for displaying subscription plan information and actions
class SubscriptionPlanCard extends ConsumerWidget {
  final SubscriptionPlan plan;
  final String userId;
  final SubscriptionState state;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.userId,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              if (plan.isPopular) _buildPopularBadge(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlanHeader(context),
                    if (plan.hasTrial) ...[
                      const SizedBox(height: 8),
                      _buildTrialBadge(),
                    ],
                    const SizedBox(height: 16),
                    ..._buildFeatureList(),
                    const SizedBox(height: 16),
                    _buildSubscribeButton(context, ref, isCurrentPlan),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularBadge() {
    return Positioned(
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
    );
  }

  Widget _buildPlanHeader(BuildContext context) {
    return Row(
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
        _buildPriceSection(context),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Column(
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
    );
  }

  Widget _buildTrialBadge() {
    return Container(
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
    );
  }

  List<Widget> _buildFeatureList() {
    return plan.features.map(
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
    ).toList();
  }

  Widget _buildSubscribeButton(BuildContext context, WidgetRef ref, bool isCurrentPlan) {
    final isPurchasing = state.isPurchasing(plan.id);
    final isButtonDisabled = isCurrentPlan || isPurchasing;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isButtonDisabled 
            ? null 
            : () => SubscriptionPageCoordinator.subscribeToPlan(
                  ref, 
                  context, 
                  userId, 
                  plan,
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: plan.isPopular ? Colors.blue : null,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        icon: _buildButtonIcon(isPurchasing, isCurrentPlan),
        label: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _getButtonText(isPurchasing, isCurrentPlan),
            key: ValueKey(isPurchasing ? 'loading' : 'normal'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonIcon(bool isPurchasing, bool isCurrentPlan) {
    if (isPurchasing) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    } else if (isCurrentPlan) {
      return const Icon(Icons.check_circle, size: 18);
    } else {
      return const Icon(Icons.shopping_cart, size: 18);
    }
  }

  String _getButtonText(bool isPurchasing, bool isCurrentPlan) {
    if (isPurchasing) {
      return 'Processando...';
    } else if (isCurrentPlan) {
      return 'Plano Atual';
    } else {
      return 'Assinar Agora';
    }
  }
}
import 'package:core/core.dart' hide SubscriptionState, subscriptionProvider;
import 'package:flutter/material.dart';

import '../../domain/entities/subscription_plan.dart';
import '../providers/subscription_provider.dart';

/// Coordinator responsible for managing subscription page business logic
/// and coordinating between different subscription components
class SubscriptionPageCoordinator extends ConsumerWidget {
  final String userId;
  final Widget Function(SubscriptionState state) bodyBuilder;

  const SubscriptionPageCoordinator({
    super.key,
    required this.userId,
    required this.bodyBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionProvider);
    ref.listen<SubscriptionState>(subscriptionProvider, (previous, next) {
      if (next.error != null) {
        _showErrorMessage(context, next.error!);
        ref.read(subscriptionProvider.notifier).clearError();
      }
    });

    return bodyBuilder(state);
  }

  void _showErrorMessage(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Initialize subscription data loading
  static void initializeData(WidgetRef ref, String userId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionProvider.notifier).loadAvailablePlans();
      ref.read(subscriptionProvider.notifier).loadCurrentSubscription(userId);
    });
  }

  /// Handle subscription to a plan
  static Future<void> subscribeToPlan(
    WidgetRef ref,
    BuildContext context,
    String userId,
    SubscriptionPlan plan,
  ) async {
    final success = await ref.read(subscriptionProvider.notifier).subscribeToPlan(
          userId,
          plan.id,
        );

    if (success && context.mounted) {
      _showSuccessMessage(
        context,
        'Assinatura do ${plan.title} ativada com sucesso!',
      );
    }
  }

  /// Handle subscription cancellation
  static Future<void> cancelSubscription(
    WidgetRef ref,
    BuildContext context,
    String userId,
  ) async {
    final success = await ref.read(subscriptionProvider.notifier).cancelSubscription(userId);

    if (success && context.mounted) {
      _showSuccessMessage(
        context,
        'Assinatura cancelada com sucesso',
      );
    }
  }

  /// Handle subscription resumption
  static Future<void> resumeSubscription(
    WidgetRef ref,
    BuildContext context,
    String userId,
  ) async {
    final success = await ref.read(subscriptionProvider.notifier).resumeSubscription(userId);

    if (success && context.mounted) {
      _showSuccessMessage(
        context,
        'Assinatura retomada com sucesso',
      );
    }
  }

  /// Handle purchases restoration
  static Future<void> restorePurchases(
    WidgetRef ref,
    BuildContext context,
    String userId,
  ) async {
    final success = await ref.read(subscriptionProvider.notifier).restorePurchases(userId);

    if (success && context.mounted) {
      _showSuccessMessage(
        context,
        'Compras restauradas com sucesso',
      );
    }
  }

  /// Reload subscription plans
  static void reloadPlans(WidgetRef ref) {
    ref.read(subscriptionProvider.notifier).loadAvailablePlans();
  }

  static void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

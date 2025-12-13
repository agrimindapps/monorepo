import 'package:core/core.dart' hide SubscriptionState, subscriptionProvider;
import 'package:flutter/material.dart';

import '../../domain/entities/subscription_plan.dart';
import '../state/subscription_notifier.dart';
import '../state/subscription_state.dart';

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
      if (next.errorMessage != null) {
        _showErrorMessage(context, next.errorMessage!);
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
    // Data is automatically loaded in the notifier's build method
  }

  /// Handle subscription to a plan
  static Future<bool> subscribeToPlan(
    WidgetRef ref,
    BuildContext context,
    String userId,
    SubscriptionPlan plan,
  ) async {
    final success = await ref.read(subscriptionProvider.notifier).subscribeToPlan(plan.id);
    if (success && context.mounted) {
      _showSuccessMessage(context, 'Assinatura do ${plan.title} ativada com sucesso!');
    }
    return success;
  }

  /// Handle subscription cancellation
  static Future<bool> cancelSubscription(
    WidgetRef ref,
    BuildContext context,
    String userId,
  ) async {
    // TODO: Implement cancel logic in RevenueCat
    return false;
  }

  /// Handle subscription restoration
  static Future<bool> restorePurchases(
    WidgetRef ref,
    BuildContext context,
    String userId,
  ) async {
    final success = await ref.read(subscriptionProvider.notifier).restorePurchases();
    if (success && context.mounted) {
      _showSuccessMessage(context, 'Compras restauradas com sucesso!');
    }
    return success;
  }

  /// Handle subscription resumption
  static Future<bool> resumeSubscription(
    WidgetRef ref,
    BuildContext context,
    String userId,
  ) async {
    // TODO: Implement resume logic
    return false;
  }

  /// Reload subscription plans
  static void reloadPlans(WidgetRef ref) {
    ref.read(subscriptionProvider.notifier).loadAvailablePlans();
  }

  // ignore: unused_element
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

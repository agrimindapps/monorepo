import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/subscription_plan.dart';

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
      if (next is SubscriptionError) {
        _showErrorMessage(context, next.message);
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
    final actions = ref.read(purchaseActionsProvider);
    // TODO: Adapt to use purchasePackage
    return false;
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
    final actions = ref.read(purchaseActionsProvider);
    await actions.restorePurchases();
    if (context.mounted) {
      _showSuccessMessage(context, 'Compras restauradas com sucesso!');
    }
    return true;
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
    ref.read(subscriptionProvider.notifier).checkSubscriptionStatus();
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

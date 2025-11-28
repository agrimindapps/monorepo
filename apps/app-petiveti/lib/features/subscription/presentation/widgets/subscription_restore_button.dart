import 'package:core/core.dart' hide SubscriptionState;
import 'package:flutter/material.dart';

import '../providers/subscription_providers.dart';
import 'subscription_page_coordinator.dart';

/// Widget responsible for rendering the restore purchases button
class SubscriptionRestoreButton extends ConsumerWidget {
  final String userId;
  final SubscriptionState state;

  const SubscriptionRestoreButton({
    super.key,
    required this.userId,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: state.hasAnyLoading 
          ? null 
          : () => SubscriptionPageCoordinator.restorePurchases(ref, context, userId),
      icon: state.hasAnyLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.restore),
      label: const Text('Restaurar Compras'),
    );
  }
}

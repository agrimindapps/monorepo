import 'package:core/core.dart' hide SubscriptionState, SubscriptionInfo, subscriptionProvider;
import 'package:flutter/material.dart';

import '../state/subscription_notifier.dart';
import '../state/subscription_state.dart';

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
    final isLoading = state.isRestoringPurchases;

    return OutlinedButton.icon(
      onPressed: isLoading
          ? null
          : () async {
              final result = await ref
                  .read(subscriptionProvider.notifier)
                  .restorePurchases();
              if (!context.mounted) return;
              result.fold(
                (error) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
                (_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Compras restauradas com sucesso!')),
                ),
              );
            },
      icon: isLoading
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

import 'package:flutter/material.dart';
import '../providers/subscription_provider.dart';

/// Widget responsible for displaying loading overlay during subscription operations
class SubscriptionLoadingOverlay extends StatelessWidget {
  final SubscriptionState state;

  const SubscriptionLoadingOverlay({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowOverlay) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    state.loadingMessage,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (state.isProcessingPurchase) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Este processo pode levar alguns segundos...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _shouldShowOverlay => 
      state.hasAnyLoading && 
      !state.isLoadingPlans && 
      !state.isLoadingCurrentSubscription;
}

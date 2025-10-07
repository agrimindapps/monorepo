import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Discrete sync indicator that shows at the top of screens without blocking UI
class DiscreteSyncIndicator extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const DiscreteSyncIndicator({super.key, this.onRetry, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return const SizedBox.shrink();
      },
    );
  }
}

/// Floating sync indicator that can be positioned anywhere on screen
class FloatingSyncIndicator extends StatelessWidget {
  final Alignment alignment;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onRetry;
  final VoidCallback? onTap;

  const FloatingSyncIndicator({
    super.key,
    this.alignment = Alignment.topCenter,
    this.margin = const EdgeInsets.only(top: 8),
    this.onRetry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return const SizedBox.shrink();
      },
    );
  }
}

/// Minimal sync dot indicator for app bars or status areas
class SyncDotIndicator extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const SyncDotIndicator({super.key, this.size = 8.0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return const SizedBox.shrink();
      },
    );
  }
}

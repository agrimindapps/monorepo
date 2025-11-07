import 'package:flutter/material.dart';

/// Enhanced SnackBar with improved visual feedback
/// Provides consistent feedback messaging across the app
class FeedbackSnackBar {
  /// Show success message
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      type: FeedbackType.success,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Show error message
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      type: FeedbackType.error,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Show warning message
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      type: FeedbackType.warning,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Show info message
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      type: FeedbackType.info,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Show sync status message
  static void showSyncStatus(
    BuildContext context,
    String message,
    bool isSuccess, {
    int? itemCount,
    VoidCallback? onViewDetails,
  }) {
    final statusMessage = itemCount != null 
        ? '$message ($itemCount items)'
        : message;

    _showSnackBar(
      context,
      message: statusMessage,
      type: isSuccess ? FeedbackType.success : FeedbackType.error,
      duration: const Duration(seconds: 4),
      onAction: onViewDetails,
      actionLabel: onViewDetails != null ? 'Details' : null,
    );
  }

  /// Show offline notification
  static void showOfflineNotification(
    BuildContext context, {
    VoidCallback? onDismiss,
  }) {
    _showSnackBar(
      context,
      message: 'You are offline. Changes will be synced when connected.',
      type: FeedbackType.warning,
      duration: const Duration(seconds: 5),
      onAction: onDismiss,
      actionLabel: 'Dismiss',
    );
  }

  /// Show loading with progress
  static void showLoading(
    BuildContext context,
    String message, {
    bool showProgress = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16.0,
              height: 16.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 30), // Long duration for loading
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Dismiss current SnackBar
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required FeedbackType type,
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final theme = Theme.of(context);
    final config = _getTypeConfig(type, theme);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              config.icon,
              color: Colors.white,
              size: 20.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        duration: duration ?? config.duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        action: (onAction != null && actionLabel != null)
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static _TypeConfig _getTypeConfig(FeedbackType type, ThemeData theme) {
    switch (type) {
      case FeedbackType.success:
        return _TypeConfig(
          icon: Icons.check_circle_outline,
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 3),
        );
      case FeedbackType.error:
        return _TypeConfig(
          icon: Icons.error_outline,
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
        );
      case FeedbackType.warning:
        return _TypeConfig(
          icon: Icons.warning_amber_outlined,
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 4),
        );
      case FeedbackType.info:
        return _TypeConfig(
          icon: Icons.info_outline,
          backgroundColor: Colors.blue.shade600,
          duration: const Duration(seconds: 3),
        );
    }
  }
}

/// Custom SnackBar widget with enhanced styling
class CustomSnackBar extends StatelessWidget {

  const CustomSnackBar({
    super.key,
    required this.message,
    required this.type,
    this.onAction,
    this.actionLabel,
    this.onDismiss,
  });
  final String message;
  final FeedbackType type;
  final VoidCallback? onAction;
  final String? actionLabel;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = FeedbackSnackBar._getTypeConfig(type, theme);

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            config.icon,
            color: Colors.white,
            size: 20.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(width: 8.0),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 4.0),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18.0,
              ),
              constraints: const BoxConstraints(
                minWidth: 32.0,
                minHeight: 32.0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Floating feedback message
class FloatingFeedback extends StatefulWidget {

  const FloatingFeedback({
    super.key,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
  });
  final String message;
  final FeedbackType type;
  final Duration duration;
  final VoidCallback? onDismiss;

  @override
  State<FloatingFeedback> createState() => _FloatingFeedbackState();
}

class _FloatingFeedbackState extends State<FloatingFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomSnackBar(
          message: widget.message,
          type: widget.type,
          onDismiss: () {
            _controller.reverse().then((_) {
              widget.onDismiss?.call();
            });
          },
        ),
      ),
    );
  }
}

/// Feedback type enumeration
enum FeedbackType {
  success,
  error,
  warning,
  info,
}

/// Type configuration model
class _TypeConfig {

  const _TypeConfig({
    required this.icon,
    required this.backgroundColor,
    required this.duration,
  });
  final IconData icon;
  final Color backgroundColor;
  final Duration duration;
}

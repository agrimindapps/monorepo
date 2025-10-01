import 'package:flutter/material.dart';

/// ✅ UNIFIED ERROR HANDLING: Single source of truth for error display patterns
/// 
/// This class provides standardized error handling across the entire app,
/// replacing the 3 different patterns currently in use:
/// 1. FormMixin pattern (showErrorDialog/showErrorSnackbar)  
/// 2. FeedbackSnackBar pattern (FeedbackSnackBar.showError)
/// 3. Manual ScaffoldMessenger pattern (direct ScaffoldMessenger calls)
class UnifiedErrorHandler {
  
  /// Show error as dialog - use for critical errors that require user acknowledgment
  static Future<void> showErrorDialog(
    BuildContext context,
    String message, {
    String? title,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    if (!context.mounted) return;
    
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(title ?? 'Erro'),
        content: Text(message),
        actions: [
          if (onAction != null && actionText != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(actionText),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  /// Show error as snackbar - use for non-critical errors and feedback
  static void showErrorSnackbar(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionText,
    VoidCallback? onAction,
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onError,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 4),
        action: onAction != null && actionText != null
            ? SnackBarAction(
                label: actionText,
                textColor: Theme.of(context).colorScheme.onError,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
  
  /// Show success feedback - standardized success pattern
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionText,
    VoidCallback? onAction,
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50), // Success green
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 3),
        action: onAction != null && actionText != null
            ? SnackBarAction(
                label: actionText,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
  
  /// Show warning feedback - for non-blocking warnings
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionText,
    VoidCallback? onAction,
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF9800), // Warning orange
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 3),
        action: onAction != null && actionText != null
            ? SnackBarAction(
                label: actionText,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
  
  /// Show info feedback - for informational messages
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionText,
    VoidCallback? onAction,
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 3),
        action: onAction != null && actionText != null
            ? SnackBarAction(
                label: actionText,
                textColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Handle different error types systematically
  static void handleError(
    BuildContext context,
    dynamic error, {
    bool useDialog = false,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;
    
    final String message = customMessage ?? _getErrorMessage(error);
    
    if (useDialog) {
      showErrorDialog(
        context,
        message,
        actionText: onRetry != null ? 'Tentar Novamente' : null,
        onAction: onRetry,
      );
    } else {
      showErrorSnackbar(
        context,
        message,
        actionText: onRetry != null ? 'Tentar Novamente' : null,
        onAction: onRetry,
      );
    }
  }
  
  /// Extract user-friendly error message from different error types
  static String _getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else if (error is Error) {
      return 'Erro interno: ${error.toString()}';
    } else {
      return 'Erro desconhecido';
    }
  }
}

/// ✅ MIXIN: Easy integration with existing widgets
mixin UnifiedErrorMixin {
  /// Get context for error handling - must be implemented by using class
  BuildContext get context;
  
  /// Check if widget is still mounted - must be implemented by using class
  bool get mounted;
  
  /// Show error dialog with retry option
  Future<void> showErrorDialog(
    String message, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    if (!mounted) return;
    
    await UnifiedErrorHandler.showErrorDialog(
      context,
      message,
      title: title,
      actionText: onRetry != null ? 'Tentar Novamente' : null,
      onAction: onRetry,
    );
  }
  
  /// Show error snackbar with retry option
  void showErrorSnackbar(String message, {VoidCallback? onRetry}) {
    if (!mounted) return;
    
    UnifiedErrorHandler.showErrorSnackbar(
      context,
      message,
      actionText: onRetry != null ? 'Tentar Novamente' : null,
      onAction: onRetry,
    );
  }
  
  /// Show success message
  void showSuccess(String message) {
    if (!mounted) return;
    UnifiedErrorHandler.showSuccess(context, message);
  }
  
  /// Show warning message
  void showWarning(String message) {
    if (!mounted) return;
    UnifiedErrorHandler.showWarning(context, message);
  }
  
  /// Show info message
  void showInfo(String message) {
    if (!mounted) return;
    UnifiedErrorHandler.showInfo(context, message);
  }
  
  /// Handle any error type
  void handleError(
    dynamic error, {
    bool useDialog = false,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    if (!mounted) return;
    
    UnifiedErrorHandler.handleError(
      context,
      error,
      useDialog: useDialog,
      customMessage: customMessage,
      onRetry: onRetry,
    );
  }
}
import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// A centralized utility for displaying user-friendly feedback, such as errors,
/// success messages, and information, using SnackBars and dialogs.
class ErrorHandler {
  ErrorHandler._();

  /// Shows a styled [SnackBar] with an error message derived from an [AppError].
  static void showErrorSnackbar(
    BuildContext context,
    AppError error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _showStyledSnackbar(
      context: context,
      title: _getErrorTitle(error),
      message: error.userMessage,
      icon: _getErrorIcon(error),
      backgroundColor: _getErrorColor(error),
      duration: duration,
    );
  }

  /// Shows a styled [SnackBar] with a success message.
  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    String title = 'Success',
    Duration duration = const Duration(seconds: 3),
  }) {
    _showStyledSnackbar(
      context: context,
      title: title,
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: AppTheme.successColor,
      duration: duration,
    );
  }

  /// Shows a styled [SnackBar] with an informational message.
  static void showInfoSnackbar(
    BuildContext context,
    String message, {
    String title = 'Information',
    Duration duration = const Duration(seconds: 3),
  }) {
    _showStyledSnackbar(
      context: context,
      title: title,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: AppTheme.infoColor,
      duration: duration,
    );
  }

  /// A private helper to create and show a styled [SnackBar].
  static void _showStyledSnackbar({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Shows an [AlertDialog] with details about the [AppError].
  static Future<void> showErrorDialog(
    BuildContext context,
    AppError error, {
    String? customTitle,
    List<Widget>? actions,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(_getErrorIcon(error), color: _getErrorColor(error), size: 48),
          title: Text(customTitle ?? _getErrorTitle(error)),
          content: Text(error.userMessage.isNotEmpty
              ? error.userMessage
              : 'An unexpected error occurred.'),
          actions: actions ??
              [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
        );
      },
    );
  }

  /// Returns an appropriate icon based on the [AppError]'s category.
  static IconData _getErrorIcon(AppError error) {
    switch (error.category) {
      case ErrorCategory.network:
        return Icons.wifi_off_outlined;
      case ErrorCategory.external:
        return Icons.cloud_off_outlined;
      case ErrorCategory.storage:
        return Icons.storage_outlined;
      case ErrorCategory.validation:
        return Icons.warning_amber_outlined;
      case ErrorCategory.authentication:
        return Icons.lock_person_outlined;
      default:
        return Icons.error_outline;
    }
  }

  /// Returns an appropriate color based on the [AppError]'s severity.
  static Color _getErrorColor(AppError error) {
    switch (error.severity) {
      case ErrorSeverity.low:
        return AppTheme.infoColor;
      case ErrorSeverity.medium:
        return AppTheme.warningColor;
      case ErrorSeverity.high:
      case ErrorSeverity.critical:
        return AppTheme.errorColor;
    }
  }

  /// Returns an appropriate title based on the [AppError]'s category.
  static String _getErrorTitle(AppError error) {
    switch (error.category) {
      case ErrorCategory.network:
        return 'Connection Problem';
      case ErrorCategory.external:
        return 'Server Error';
      case ErrorCategory.storage:
        return 'Storage Error';
      case ErrorCategory.validation:
        return 'Invalid Data';
      case ErrorCategory.authentication:
        return 'Authentication Error';
      default:
        return 'Error';
    }
  }
}

/// A mixin to provide convenient access to [ErrorHandler] methods within widgets.
mixin ErrorHandlerMixin {
  /// Shows an error snackbar for the given [AppError].
  void showError(BuildContext context, AppError error) {
    ErrorHandler.showErrorSnackbar(context, error);
  }

  /// Shows a success message.
  void showSuccess(BuildContext context, String message, {String? title}) {
    ErrorHandler.showSuccessSnackbar(context, message, title: title ?? 'Success');
  }

  /// Shows an informational message.
  void showInfo(BuildContext context, String message, {String? title}) {
    ErrorHandler.showInfoSnackbar(context, message, title: title ?? 'Information');
  }

  /// Shows an error dialog for the given [AppError].
  Future<void> showErrorDialog(BuildContext context, AppError error) {
    return ErrorHandler.showErrorDialog(context, error);
  }
}
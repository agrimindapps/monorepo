import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/theme/design_tokens.dart';

/// Service responsible for UI feedback operations
/// Follows SRP by handling only user feedback logic
@lazySingleton
class SnackBarService {
  /// Show success snackbar
  void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: GasometerDesignTokens.colorSuccess,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show error snackbar
  void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 4),
    );
  }

  /// Show info snackbar
  void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.primary,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show warning snackbar
  void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show snackbar with custom duration
  void showWithDuration(
    BuildContext context,
    String message,
    Duration duration,
  ) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.primary,
      duration: duration,
    );
  }

  /// Show snackbar with action button
  void showWithAction(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusButton,
          ),
        ),
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: onAction,
        ),
      ),
    );
  }

  /// Show persistent snackbar (requires manual dismiss)
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showPersistent(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 365), // Practically persistent
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusButton,
          ),
        ),
        action: SnackBarAction(
          label: 'Fechar',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  /// Hide current snackbar
  void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Clear all snackbars
  void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  // Private helper method
  void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusButton,
          ),
        ),
      ),
    );
  }
}

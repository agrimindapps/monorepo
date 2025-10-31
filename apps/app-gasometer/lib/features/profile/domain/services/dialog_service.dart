import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// Service responsible for showing dialogs
/// Follows SRP by handling only dialog operations
@lazySingleton
class DialogService {
  /// Show loading dialog
  void showLoading(
    BuildContext context, {
    String message = 'Carregando...',
    bool barrierDismissible = false,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  /// Show confirmation dialog
  Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous
                ? ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show error dialog
  Future<void> showError(
    BuildContext context, {
    String title = 'Erro',
    required String message,
    String buttonText = 'OK',
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  Future<void> showSuccess(
    BuildContext context, {
    String title = 'Sucesso',
    required String message,
    String buttonText = 'OK',
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show info dialog
  Future<void> showInfo(
    BuildContext context, {
    String title = 'Informação',
    required String message,
    String buttonText = 'OK',
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show custom dialog
  Future<T?> showCustom<T>(
    BuildContext context, {
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  /// Show bottom sheet
  Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: builder,
    );
  }

  /// Show choices dialog
  Future<T?> showChoices<T>(
    BuildContext context, {
    required String title,
    required List<DialogChoice<T>> choices,
  }) async {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: choices.map((choice) {
            return ListTile(
              leading: choice.icon != null ? Icon(choice.icon) : null,
              title: Text(choice.label),
              subtitle: choice.subtitle != null ? Text(choice.subtitle!) : null,
              onTap: () => Navigator.of(context).pop(choice.value),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Dismiss current dialog
  void dismiss(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  /// Dismiss all dialogs
  void dismissAll(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

/// Dialog choice model
class DialogChoice<T> {
  final String label;
  final String? subtitle;
  final IconData? icon;
  final T value;

  const DialogChoice({
    required this.label,
    this.subtitle,
    this.icon,
    required this.value,
  });
}

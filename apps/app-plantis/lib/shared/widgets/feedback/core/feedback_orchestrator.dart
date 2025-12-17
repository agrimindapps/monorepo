import 'package:flutter/material.dart';

import 'operation_config.dart';

/// Orchestrator para coordenar operações com feedback
/// Base para extensions helpers
class FeedbackOrchestrator {
  /// Executa uma operação com configuração de feedback
  Future<T> executeOperation<T>({
    required BuildContext context,
    required String operationKey,
    required Future<T> Function() operation,
    required OperationConfig config,
  }) async {
    // Implementação básica - pode ser expandida conforme necessário
    try {
      return await operation();
    } catch (e) {
      rethrow;
    }
  }

  /// Executa uma operação com progresso
  Future<T> executeWithProgress<T>({
    required BuildContext context,
    required String operationKey,
    required Future<T> Function(void Function(double, String?) progressCallback) operation,
    required ProgressOperationConfig config,
  }) async {
    try {
      return await operation((progress, message) {
        // Callback de progresso - pode ser expandido
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Mostra confirmação
  Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    String? confirmLabel,
    String? cancelLabel,
    dynamic type,
    IconData? icon,
  }) async {
    final confirm = confirmLabel ?? confirmText ?? 'Confirmar';
    final cancel = cancelLabel ?? cancelText ?? 'Cancelar';
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirm),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Mostra confirmação destrutiva
  Future<bool> showDestructiveConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    String? confirmLabel,
    bool? requiresDoubleConfirmation,
  }) async {
    final confirm = confirmLabel ?? confirmText ?? 'Excluir';
    final cancel = cancelText ?? 'Cancelar';
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(confirm),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Mostra toast de sucesso
  void showSuccessToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Mostra toast de erro
  void showErrorToast(BuildContext context, String message, {VoidCallback? onRetry}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Tentar novamente',
                onPressed: onRetry,
                textColor: Colors.white,
              )
            : null,
      ),
    );
  }

  /// Mostra toast informativo
  void showInfoToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Mostra toast de aviso
  void showWarningToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// Haptic leve
  Future<void> lightHaptic() async {
    // Implementação pode ser adicionada com HapticFeedback
  }

  /// Haptic médio
  Future<void> mediumHaptic() async {
    // Implementação pode ser adicionada com HapticFeedback
  }

  /// Haptic pesado
  Future<void> heavyHaptic() async {
    // Implementação pode ser adicionada com HapticFeedback
  }

  /// Haptic contextual
  Future<void> contextualHaptic(String context) async {
    // Implementação pode ser adicionada com HapticFeedback
  }
}

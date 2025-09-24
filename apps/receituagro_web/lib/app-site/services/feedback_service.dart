import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../core/utils/secure_logger.dart';

/// Service para feedback visual unificado
class FeedbackService {
  /// Mostra snackbar de sucesso
  static void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    bool includeHaptic = true,
  }) {
    if (includeHaptic) {
      HapticFeedback.lightImpact();
    }

    Get.snackbar(
      'Sucesso',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      mainButton: actionLabel != null && onAction != null
          ? TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
      animationDuration: const Duration(milliseconds: 300),
    );

    SecureLogger.info('Feedback de sucesso: $message');
  }

  /// Mostra snackbar de erro
  static void showError(
    String message, {
    Duration duration = const Duration(seconds: 5),
    String? actionLabel,
    VoidCallback? onAction,
    bool includeHaptic = true,
  }) {
    if (includeHaptic) {
      HapticFeedback.heavyImpact();
    }

    Get.snackbar(
      'Erro',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      mainButton: actionLabel != null && onAction != null
          ? TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
      animationDuration: const Duration(milliseconds: 300),
    );

    SecureLogger.warning('Feedback de erro: $message');
  }

  /// Mostra snackbar de aviso
  static void showWarning(
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    bool includeHaptic = true,
  }) {
    if (includeHaptic) {
      HapticFeedback.mediumImpact();
    }

    Get.snackbar(
      'Aviso',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      mainButton: actionLabel != null && onAction != null
          ? TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
      animationDuration: const Duration(milliseconds: 300),
    );

    SecureLogger.warning('Feedback de aviso: $message');
  }

  /// Mostra snackbar de informação
  static void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    bool includeHaptic = false,
  }) {
    if (includeHaptic) {
      HapticFeedback.selectionClick();
    }

    Get.snackbar(
      'Informação',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      mainButton: actionLabel != null && onAction != null
          ? TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
      animationDuration: const Duration(milliseconds: 300),
    );

    SecureLogger.info('Feedback de informação: $message');
  }

  /// Mostra dialog de confirmação
  static Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
    IconData? icon,
    bool isDangerous = false,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isDangerous ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  confirmColor ?? (isDangerous ? Colors.red : Colors.blue),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }

  /// Mostra loading dialog
  static void showLoadingDialog(String message) {
    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Esconde loading dialog
  static void hideLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  /// Mostra toast message simples
  static void showToast(
    String message, {
    Duration duration = const Duration(seconds: 2),
    ToastType type = ToastType.neutral,
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green.shade600;
        icon = Icons.check_circle;
        break;
      case ToastType.error:
        backgroundColor = Colors.red.shade600;
        icon = Icons.error;
        break;
      case ToastType.warning:
        backgroundColor = Colors.orange.shade600;
        icon = Icons.warning;
        break;
      case ToastType.info:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.info;
        break;
      case ToastType.neutral:
        backgroundColor = Colors.grey.shade600;
        icon = Icons.notifications;
        break;
    }

    Get.rawSnackbar(
      message: message,
      backgroundColor: backgroundColor,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: duration,
      icon: Icon(icon, color: Colors.white),
      animationDuration: const Duration(milliseconds: 200),
      overlayBlur: 0,
    );
  }

  /// Mostra progress indicator inline
  static Widget buildProgressIndicator({
    String? message,
    double size = 24,
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Colors.blue,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  /// Mostra feedback de ação bem-sucedida
  static void showActionSuccess(
    String action, {
    String? details,
    VoidCallback? onUndo,
  }) {
    final message = details != null ? '$action: $details' : action;

    showSuccess(
      message,
      actionLabel: onUndo != null ? 'Desfazer' : null,
      onAction: onUndo,
    );
  }

  /// Mostra feedback de ação falhada
  static void showActionError(
    String action,
    String error, {
    VoidCallback? onRetry,
  }) {
    showError(
      'Erro ao $action: $error',
      actionLabel: onRetry != null ? 'Tentar novamente' : null,
      onAction: onRetry,
    );
  }

  /// Trigger haptic feedback
  static void triggerHaptic(HapticType type) {
    switch (type) {
      case HapticType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }
}

/// Tipos de toast
enum ToastType {
  success,
  error,
  warning,
  info,
  neutral,
}

/// Tipos de haptic feedback
enum HapticType {
  light,
  medium,
  heavy,
  selection,
}

/// Widget para feedback visual inline
class FeedbackWidget extends StatelessWidget {
  final String message;
  final FeedbackType type;
  final bool showIcon;
  final VoidCallback? onDismiss;
  final EdgeInsets padding;

  const FeedbackWidget({
    super.key,
    required this.message,
    required this.type,
    this.showIcon = true,
    this.onDismiss,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case FeedbackType.success:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case FeedbackType.error:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.error;
        break;
      case FeedbackType.warning:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.warning;
        break;
      case FeedbackType.info:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.info;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: textColor,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tipos de feedback visual
enum FeedbackType {
  success,
  error,
  warning,
  info,
}

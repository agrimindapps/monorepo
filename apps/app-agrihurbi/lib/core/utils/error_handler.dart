import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Centralized error handling utility
class ErrorHandler {
  ErrorHandler._();
  /// Show error snackbar based on failure type
  static void showErrorSnackbar(
    BuildContext context,
    Failure failure, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(failure),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getErrorTitle(failure),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (failure.message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      failure.message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(failure),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    String title = 'Sucesso',
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar(
    BuildContext context,
    String message, {
    String title = 'Informação',
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.infoColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    Failure failure, {
    String? customTitle,
    List<Widget>? actions,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            _getErrorIcon(failure),
            color: _getErrorColor(failure),
            size: 48,
          ),
          title: Text(customTitle ?? _getErrorTitle(failure)),
          content: Text(failure.message.isNotEmpty ? failure.message : 'Ocorreu um erro inesperado'),
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

  /// Get error icon based on failure type
  static IconData _getErrorIcon(Failure failure) {
    if (failure is NetworkFailure) {
      return Icons.wifi_off_outlined;
    } else if (failure is ServerFailure) {
      return Icons.cloud_off_outlined;
    } else if (failure is CacheFailure) {
      return Icons.storage_outlined;
    } else if (failure is ValidationFailure) {
      return Icons.warning_outlined;
    } else {
      return Icons.error_outline;
    }
  }

  /// Get error color based on failure type
  static Color _getErrorColor(Failure failure) {
    if (failure is NetworkFailure) {
      return AppTheme.warningColor;
    } else if (failure is ServerFailure) {
      return AppTheme.errorColor;
    } else if (failure is CacheFailure) {
      return AppTheme.infoColor;
    } else if (failure is ValidationFailure) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }

  /// Get error title based on failure type
  static String _getErrorTitle(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Problema de Conexão';
    } else if (failure is ServerFailure) {
      return 'Erro do Servidor';
    } else if (failure is CacheFailure) {
      return 'Erro de Cache';
    } else if (failure is ValidationFailure) {
      return 'Dados Inválidos';
    } else {
      return 'Erro';
    }
  }

  /// Handle failure and return user-friendly message
  static String getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Verifique sua conexão com a internet e tente novamente.';
    } else if (failure is ServerFailure) {
      return 'Nossos servidores estão temporariamente indisponíveis. Tente novamente em alguns minutos.';
    } else if (failure is CacheFailure) {
      return 'Problema no armazenamento local. Reinicie o aplicativo.';
    } else if (failure is ValidationFailure) {
      return failure.message.isNotEmpty 
          ? failure.message 
          : 'Verifique os dados inseridos e tente novamente.';
    } else {
      return failure.message.isNotEmpty 
          ? failure.message 
          : 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}

/// Mixin to provide easy access to error handling in widgets
mixin ErrorHandlerMixin {
  /// Show error snackbar
  void showError(BuildContext context, Failure failure) {
    ErrorHandler.showErrorSnackbar(context, failure);
  }

  /// Show success message
  void showSuccess(BuildContext context, String message, {String? title}) {
    ErrorHandler.showSuccessSnackbar(
      context, 
      message, 
      title: title ?? 'Sucesso',
    );
  }

  /// Show info message
  void showInfo(BuildContext context, String message, {String? title}) {
    ErrorHandler.showInfoSnackbar(
      context, 
      message, 
      title: title ?? 'Informação',
    );
  }

  /// Show error dialog
  Future<void> showErrorDialog(BuildContext context, Failure failure) {
    return ErrorHandler.showErrorDialog(context, failure);
  }
}
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../navigation/plantas_navigator.dart';

/// Serviço especializado para gerenciar UI, feedback e interações do usuário
/// Centraliza toda lógica de apresentação e feedback visual
class PlantasUIService {
  // ========== CONSTANTS ==========

  static const Color _successColor = Color(0xFF20B2AA);
  static const Color _errorColor = Colors.red;
  static const Color _warningColor = Colors.orange;
  static const Color _infoColor = Colors.blue;

  static const Duration _defaultDuration = Duration(seconds: 3);
  static const Duration _shortDuration = Duration(seconds: 2);

  // ========== SUCCESS MESSAGES ==========

  /// Exibe mensagem de sucesso com estilo consistente
  void showSuccess(
    String message, {
    String? title,
    Duration? duration,
  }) {
    Get.snackbar(
      title ?? 'Sucesso',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _successColor,
      colorText: Colors.white,
      duration: duration ?? _shortDuration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
        size: 24,
      ),
      shouldIconPulse: false,
    );
  }

  // ========== ERROR MESSAGES ==========

  /// Exibe mensagem de erro com estilo consistente
  void showError(
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? onRetry,
  }) {
    Get.snackbar(
      title ?? 'Erro',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _errorColor,
      colorText: Colors.white,
      duration: duration ?? _defaultDuration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
        size: 24,
      ),
      shouldIconPulse: false,
      mainButton: onRetry != null
          ? TextButton(
              onPressed: onRetry,
              child: const Text(
                'Tentar Novamente',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  // ========== WARNING MESSAGES ==========

  /// Exibe mensagem de aviso com estilo consistente
  void showWarning(
    String message, {
    String? title,
    Duration? duration,
  }) {
    Get.snackbar(
      title ?? 'Atenção',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _warningColor,
      colorText: Colors.white,
      duration: duration ?? _defaultDuration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.warning_outlined,
        color: Colors.white,
        size: 24,
      ),
      shouldIconPulse: false,
    );
  }

  // ========== INFO MESSAGES ==========

  /// Exibe mensagem informativa com estilo consistente
  void showInfo(
    String message, {
    String? title,
    Duration? duration,
  }) {
    Get.snackbar(
      title ?? 'Informação',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _infoColor,
      colorText: Colors.white,
      duration: duration ?? _defaultDuration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.info_outline,
        color: Colors.white,
        size: 24,
      ),
      shouldIconPulse: false,
    );
  }

  // ========== CONFIRMATION DIALOGS ==========

  /// Exibe dialog de confirmação para remoção de planta
  ///
  /// [plantName] - Nome da planta a ser removida
  /// Returns: `true` se confirmado, `false` caso contrário
  Future<bool> showRemoveConfirmation(String plantName) async {
    try {
      return await PlantasNavigator.showRemoveConfirmation(plantName);
    } catch (e) {
      Get.log('❌ PlantasUIService: Erro ao exibir confirmação: $e');
      return false;
    }
  }

  /// Exibe dialog de confirmação genérico
  ///
  /// [title] - Título do dialog
  /// [message] - Mensagem do dialog
  /// [confirmText] - Texto do botão de confirmação
  /// [cancelText] - Texto do botão de cancelamento
  /// Returns: `true` se confirmado, `false` caso contrário
  Future<bool> showConfirmation({
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
  }) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text(title),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                cancelText,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(
                confirmText,
                style: TextStyle(
                  color: confirmColor ?? _successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      return result ?? false;
    } catch (e) {
      Get.log('❌ PlantasUIService: Erro ao exibir dialog de confirmação: $e');
      return false;
    }
  }

  // ========== LOADING INDICATORS ==========

  /// Exibe indicador de loading com mensagem opcional
  void showLoading({String? message}) {
    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_successColor),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Oculta indicador de loading
  void hideLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  // ========== INPUT DIALOGS ==========

  /// Exibe dialog para input de texto
  ///
  /// [title] - Título do dialog
  /// [hint] - Placeholder do campo
  /// [initialValue] - Valor inicial do campo
  /// Returns: Texto inserido ou `null` se cancelado
  Future<String?> showTextInput({
    required String title,
    String? hint,
    String? initialValue,
    int? maxLength,
    TextInputType? keyboardType,
  }) async {
    final controller = TextEditingController(text: initialValue);

    try {
      final result = await Get.dialog<String>(
        AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              counterText: maxLength != null ? null : '',
            ),
            maxLength: maxLength,
            keyboardType: keyboardType,
            autofocus: true,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () => Get.back(result: controller.text.trim()),
              child: const Text(
                'Confirmar',
                style: TextStyle(
                  color: _successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      return result?.isNotEmpty == true ? result : null;
    } catch (e) {
      Get.log('❌ PlantasUIService: Erro ao exibir input dialog: $e');
      return null;
    } finally {
      controller.dispose();
    }
  }

  // ========== UTILITY METHODS ==========

  /// Fecha todos os snackbars ativos
  void clearSnackbars() {
    Get.closeAllSnackbars();
  }

  /// Verifica se há snackbar ativo
  bool get hasActiveSnackbar => Get.isSnackbarOpen;

  /// Verifica se há dialog ativo
  bool get hasActiveDialog => Get.isDialogOpen == true;

  /// Obtém cor baseada no tipo de feedback
  Color getColorByType(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return _successColor;
      case 'error':
        return _errorColor;
      case 'warning':
        return _warningColor;
      case 'info':
        return _infoColor;
      default:
        return _infoColor;
    }
  }
}

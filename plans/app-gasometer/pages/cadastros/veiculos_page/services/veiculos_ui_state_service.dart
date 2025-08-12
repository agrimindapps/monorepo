// Flutter

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/veiculos_page_constants.dart';

// External packages

// Local imports

/// Service responsável pelo gerenciamento de estado da UI
class VeiculosUIStateService {
  // Mostra SnackBar genérica
  static void _showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Mostra mensagem de sucesso
  static void showSuccessMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green);
  }

  // Mostra mensagem de erro
  static void showErrorMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.red);
  }

  // Mostra mensagem informativa
  static void showInfoMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blue);
  }

  // Atualiza UI com base em IDs específicos para melhor performance
  static void updateUI(GetxController controller, {List<String>? ids}) {
    if (ids != null && ids.isNotEmpty) {
      // Update apenas partes específicas da UI
      for (final id in ids) {
        controller.update([id]);
      }
    } else {
      // Update toda a UI
      controller.update();
    }
  }

  // Verifica se é dispositivo móvel
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <
        VeiculosPageConstants.mobileBreakpoint;
  }

  // Verifica se é tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= VeiculosPageConstants.mobileBreakpoint &&
        width < VeiculosPageConstants.tabletBreakpoint;
  }

  // Verifica se é desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >=
        VeiculosPageConstants.desktopMinWidth;
  }

  // Obtém número de colunas para grid responsivo
  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return VeiculosPageConstants.getGridColumns(width);
  }

  // Mostra dialog de confirmação
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
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
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Mostra loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: VeiculosPageConstants.standardSpacing),
              Text(message ?? 'Carregando...'),
            ],
          ),
        ),
      ),
    );
  }

  // Esconde loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}

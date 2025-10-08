import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Serviço responsável por exibir dialogs e snackbars
class UiFeedbackService {
  /// Mostra um SnackBar de sucesso
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: GasometerDesignTokens.colorSuccess,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusButton,
          ),
        ),
      ),
    );
  }

  /// Mostra um SnackBar de erro
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusButton,
          ),
        ),
      ),
    );
  }

  /// Mostra dialog de processamento de imagem
  static void showImageProcessingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Processando imagem...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
    );
  }

  /// Mostra dialog de confirmação para remoção de imagem
  static Future<bool> showRemoveImageConfirmationDialog(
    BuildContext context,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remover Foto'),
            content: const Text('Deseja realmente remover sua foto do perfil?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remover'),
              ),
            ],
          ),
    );

    return result ?? false;
  }
}

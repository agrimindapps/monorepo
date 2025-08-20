// Flutter imports:
import 'package:flutter/material.dart';

/// Um diálogo de sucesso que exibe uma mensagem e um ícone de sucesso.
/// Fecha automaticamente após o tempo definido.
class SuccessDialog {
  /// Exibe o diálogo de sucesso.
  ///
  /// [context] é o contexto do BuildContext.
  /// [title] é o título do diálogo (opcional).
  /// [message] é a mensagem a ser exibida.
  /// [duration] é a duração em milissegundos para fechar o diálogo (padrão: 1500ms).
  /// [onClosed] é uma função opcional chamada quando o diálogo é fechado.
  static Future<void> show({
    required BuildContext context,
    String title = 'Sucesso!',
    required String message,
    int duration = 1500,
    VoidCallback? onClosed,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 70,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(Duration(milliseconds: duration), () {
      Navigator.of(context).pop();
      if (onClosed != null) onClosed();
    });
  }
}

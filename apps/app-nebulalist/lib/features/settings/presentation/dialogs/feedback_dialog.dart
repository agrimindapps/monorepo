import 'package:flutter/material.dart';

/// Dialog para envio de feedback do usuário
class FeedbackDialog extends StatelessWidget {
  const FeedbackDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.feedback, size: 28),
          SizedBox(width: 12),
          Text('Enviar Feedback'),
        ],
      ),
      content: const Text(
        'Tem sugestões ou encontrou algum problema? Entre em contato conosco!',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Fechar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Enviar'),
        ),
      ],
    );
  }

  /// Mostra o dialog e retorna true se usuário confirmou envio
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const FeedbackDialog(),
    );
    return result ?? false;
  }
}

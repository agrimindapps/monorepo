import 'package:flutter/material.dart';

/// Dialog para solicitar avaliação do app na loja
class RateAppDialog extends StatelessWidget {
  const RateAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.star_rate, color: Colors.amber, size: 28),
          SizedBox(width: 12),
          Text('Avaliar o App'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Está gostando do NebulaList?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Sua avaliação nos ajuda a melhorar e alcançar mais pessoas!',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Mais tarde'),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.star),
          label: const Text('Avaliar'),
        ),
      ],
    );
  }

  /// Mostra o dialog e retorna true se usuário confirmou
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const RateAppDialog(),
    );
    return result ?? false;
  }
}

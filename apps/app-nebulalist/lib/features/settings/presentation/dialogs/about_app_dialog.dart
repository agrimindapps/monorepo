import 'package:flutter/material.dart';

/// Dialog com informações sobre o app
class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primaryColor,
            ),
            child: const Icon(Icons.list_alt, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('NebulaList'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seu gerenciador de tarefas moderno',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context, 'Versão', '1.0.0'),
          _buildInfoRow(context, 'Build', '1'),
          _buildInfoRow(context, 'Plataforma', 'Flutter'),
          const SizedBox(height: 16),
          Text(
            'Sistema de gerenciamento de tarefas com sincronização em nuvem.',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Mostra o dialog
  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const AboutAppDialog(),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

class EmptyStateMessage extends StatelessWidget {
  const EmptyStateMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 48.0,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum defensivo encontrado',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente usar palavras-chave diferentes na busca',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}

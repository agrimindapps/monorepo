import 'package:flutter/material.dart';

/// Empty state para ComentariosPage
///
/// Responsabilidade: Exibir mensagem quando não há comentários
class ComentariosEmptyStateWidget extends StatelessWidget {
  const ComentariosEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.comment_outlined,
              size: 48,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum comentário ainda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione suas anotações pessoais',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PrivacyChangesSection extends StatelessWidget {
  const PrivacyChangesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alterações nesta Política de Privacidade',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 30),
              _buildParagraph(
                  'Podemos atualizar nossa Política de Privacidade de tempos em tempos. Assim, recomendamos que você revise esta página periodicamente para quaisquer alterações. Vamos notificá-lo sobre quaisquer alterações publicando a nova Política de Privacidade nesta página.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Esta política está em vigor a partir de 01/01/2025'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Colors.grey[800],
      ),
      textAlign: TextAlign.justify,
    );
  }
}

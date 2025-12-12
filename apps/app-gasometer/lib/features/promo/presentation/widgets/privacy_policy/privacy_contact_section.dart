import 'package:flutter/material.dart';

class PrivacyContactSection extends StatelessWidget {
  const PrivacyContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[50],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contate-nos',
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
                  'Se você tiver alguma dúvida ou sugestão sobre nossa Política de Privacidade, não hesite em nos contatar pelo e-mail:'),
              const SizedBox(height: 16),
              Text(
                'agrimind.br@gmail.com',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 20),
              _buildParagraph(
                  'Para solicitar a exclusão completa de sua conta e dados pessoais, acesse nossa página de Exclusão de Conta ou entre em contato conosco.'),
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

import 'package:flutter/material.dart';

class PrivacyChildrenSection extends StatelessWidget {
  const PrivacyChildrenSection({super.key});

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
                'Privacidade das Crianças',
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
                  'Esses Serviços não se dirigem a menores de 13 anos. Não coletamos intencionalmente informações de identificação pessoal de crianças menores de 13 anos. No caso de descobrirmos que uma criança menor de 13 anos nos forneceu informações pessoais, nós imediatamente as excluímos de nossos servidores. Se você é pai ou responsável e está ciente de que seu filho nos forneceu informações pessoais, entre em contato conosco para que possamos tomar as medidas necessárias.'),
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

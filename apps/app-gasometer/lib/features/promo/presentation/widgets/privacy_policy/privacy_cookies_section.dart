import 'package:flutter/material.dart';

class PrivacyCookiesSection extends StatelessWidget {
  const PrivacyCookiesSection({super.key});

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
                'Cookies',
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
                  'Cookies são arquivos com uma pequena quantidade de dados que são comumente usados como identificadores exclusivos anônimos. Eles são enviados para o seu navegador a partir dos sites que você visita e são armazenados na memória interna do seu dispositivo.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Este Serviço não usa esses "cookies" explicitamente. No entanto, o aplicativo pode usar código de terceiros e bibliotecas que usam "cookies" para coletar informações e melhorar seus serviços. Você tem a opção de aceitar ou recusar esses cookies e saber quando um cookie está sendo enviado ao seu dispositivo. Se você optar por recusar nossos cookies, talvez não consiga usar algumas partes deste Serviço.'),
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

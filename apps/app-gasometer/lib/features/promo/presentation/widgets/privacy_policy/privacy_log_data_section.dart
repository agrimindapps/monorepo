import 'package:flutter/material.dart';

class PrivacyLogDataSection extends StatelessWidget {
  const PrivacyLogDataSection({super.key});

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
                'Log Data',
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
                  'Queremos informar que sempre que você usar nosso Serviço, em caso de erro no aplicativo, coletamos dados e informações (através de produtos de terceiros) em seu telefone chamado Log Data. Esses Dados de Registro podem incluir informações como o endereço do Protocolo de Internet ("IP") do seu dispositivo, nome do dispositivo, versão do sistema operacional, a configuração do aplicativo ao utilizar nosso Serviço, a hora e a data de seu uso do Serviço e outras estatísticas.'),
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

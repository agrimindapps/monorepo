import 'package:flutter/material.dart';

class PrivacyIntroSection extends StatelessWidget {
  const PrivacyIntroSection({super.key});

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
                'Introdução',
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
                  'A Agrimind Apps construiu o aplicativo GasOMeter como um aplicativo suportado por anúncios. Este SERVIÇO é fornecido pela Agrimind Apps sem custo e destina-se ao uso como está.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Esta página é usada para informar os visitantes sobre nossas políticas de coleta, uso e divulgação de Informações Pessoais se alguém decidir usar nosso Serviço.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Se você optar por usar nosso Serviço, concorda com a coleta e uso de informações em relação a esta política. As Informações Pessoais que coletamos são usadas para fornecer e melhorar o Serviço. Não usaremos ou compartilharemos suas informações com ninguém, exceto conforme descrito nesta Política de Privacidade.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Os termos utilizados nesta Política de Privacidade têm os mesmos significados que em nossos Termos e Condições, que são acessíveis no GasOMeter, salvo definição em contrário nesta Política de Privacidade.'),
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

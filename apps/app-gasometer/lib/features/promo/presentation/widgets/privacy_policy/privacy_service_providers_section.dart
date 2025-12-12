import 'package:flutter/material.dart';

class PrivacyServiceProvidersSection extends StatelessWidget {
  const PrivacyServiceProvidersSection({super.key});

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
                'Provedores de Serviço',
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
                  'Podemos empregar empresas e indivíduos terceirizados pelos seguintes motivos:'),
              const SizedBox(height: 16),
              _buildBulletPoint('Para facilitar nosso Serviço;'),
              _buildBulletPoint('Para fornecer o Serviço em nosso nome;'),
              _buildBulletPoint(
                  'Executar serviços relacionados ao Serviço; ou'),
              _buildBulletPoint(
                  'Para nos ajudar a analisar como nosso Serviço é usado.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Utilizamos especificamente os seguintes provedores de serviço:'),
              const SizedBox(height: 12),
              _buildBulletPoint('RevenueCat: Utilizado para gerenciamento de assinaturas premium e compras dentro do aplicativo. A RevenueCat pode coletar e processar informações sobre suas transações e uso de funcionalidades premium.'),
              const SizedBox(height: 16),
              _buildParagraph(
                  'Queremos informar aos usuários deste Serviço que esses terceiros têm acesso às suas Informações Pessoais. O motivo é realizar as tarefas atribuídas a eles em nosso nome. No entanto, eles são obrigados a não divulgar ou usar as informações para qualquer outra finalidade.'),
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

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

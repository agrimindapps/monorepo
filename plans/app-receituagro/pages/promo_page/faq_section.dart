// Flutter imports:
import 'package:flutter/material.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'O aplicativo funciona offline?',
      'answer':
          'Sim, uma vez que você tenha feito o download da base de dados, a maioria das funcionalidades do ReceiturAgro estará disponível mesmo sem conexão com a internet.',
      'isExpanded': false,
    },
    {
      'question': 'É necessário pagar para usar o aplicativo?',
      'answer':
          'O ReceiturAgro oferece uma versão gratuita com acesso a funcionalidades básicas e uma versão premium com recursos avançados como diagnósticos personalizados, histórico completo e sincronização entre dispositivos.',
      'isExpanded': false,
    },
    {
      'question': 'Com que frequência a base de dados é atualizada?',
      'answer':
          'Nossa base de dados é atualizada mensalmente com novos registros de defensivos, pragas e doenças. Atualizações importantes, como novas regulamentações do MAPA, são implementadas imediatamente.',
      'isExpanded': false,
    },
    {
      'question': 'Como faço para identificar uma praga usando o app?',
      'answer':
          'É simples! Basta acessar a seção "Identificação de Pragas", selecionar a cultura afetada e navegar pelos sintomas visíveis. O aplicativo irá mostrar as possíveis pragas que correspondem à sua descrição, com imagens para confirmar a identificação.',
      'isExpanded': false,
    },
    {
      'question':
          'Posso compartilhar informações do aplicativo com outras pessoas?',
      'answer':
          'Sim, o ReceiturAgro permite compartilhar informações sobre pragas, defensivos e diagnósticos via WhatsApp, e-mail ou outras plataformas de mensagens. Isso facilita a comunicação com consultores, técnicos ou outros produtores.',
      'isExpanded': false,
    },
    {
      'question': 'O aplicativo substitui um profissional técnico?',
      'answer':
          'O ReceiturAgro é uma ferramenta de apoio que fornece informações técnicas precisas, mas não substitui a orientação de um engenheiro agrônomo ou técnico agrícola credenciado, especialmente para prescrições de receituário agronômico.',
      'isExpanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text(
                'Perguntas Frequentes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tire suas dúvidas sobre o ReceiturAgro',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 40),
              _buildFaqList(),
              const SizedBox(height: 30),
              _buildContactInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqList() {
    return ExpansionPanelList(
      elevation: 3,
      expandedHeaderPadding: EdgeInsets.zero,
      dividerColor: Colors.grey.shade200,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _faqItems[index]['isExpanded'] = !isExpanded;
        });
      },
      children: _faqItems.map<ExpansionPanel>((Map<String, dynamic> item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                item['question'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              tileColor: Colors.white,
            );
          },
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              item['answer'],
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
          isExpanded: item['isExpanded'],
          canTapOnHeader: true,
          backgroundColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'Ainda tem dúvidas?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Entre em contato com nossa equipe de suporte',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.email),
                label: const Text('Enviar E-mail'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat),
                label: const Text('Chat Online'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: BorderSide(color: Colors.green.shade600),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> with TickerProviderStateMixin {
  int? _expandedIndex;

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'O aplicativo é gratuito?',
      'answer':
          'Sim, o GasOMeter é completamente gratuito. Você pode cadastrar seus veículos, registrar abastecimentos e acompanhar manutenções sem nenhum custo.',
    },
    {
      'question': 'Posso cadastrar mais de um veículo?',
      'answer':
          'Sim, você pode cadastrar quantos veículos quiser no GasOMeter. Cada veículo terá seu próprio histórico de abastecimentos, manutenções e estatísticas individuais.',
    },
    {
      'question': 'Os dados ficam salvos se eu trocar de celular?',
      'answer':
          'Sim, todos os seus dados ficam seguros na nuvem. Ao fazer login em um novo dispositivo, todos os seus veículos e históricos serão sincronizados automaticamente.',
    },
    {
      'question': 'O app funciona offline?',
      'answer':
          'Sim, você pode usar a maioria das funcionalidades mesmo sem internet. Os dados serão sincronizados automaticamente quando você estiver conectado.',
    },
    {
      'question': 'Como funciona o sistema de notificações?',
      'answer':
          'O GasOMeter te avisa quando está na hora de fazer a manutenção do seu veículo, baseado na quilometragem ou tempo que você configurar para cada tipo de serviço.',
    },
  ];

  void _toggleExpansion(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : screenSize.width * 0.1,
      ),
      child: Column(
        children: [
          // Título da seção
          Column(
            children: [
              Text(
                'Perguntas Frequentes',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.purple[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),

          // Lista de perguntas
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: _faqItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ExpansionTile(
                      title: Text(
                        item['question']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      childrenPadding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 20,
                      ),
                      iconColor: Colors.purple[600],
                      collapsedIconColor: Colors.grey[600],
                      onExpansionChanged: (expanded) {
                        if (expanded) {
                          _toggleExpansion(index);
                        } else {
                          _toggleExpansion(-1);
                        }
                      },
                      children: [
                        Text(
                          item['answer']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
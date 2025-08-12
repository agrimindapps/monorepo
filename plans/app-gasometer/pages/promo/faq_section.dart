// Flutter imports:
import 'package:flutter/material.dart';

class FAQSection extends StatefulWidget {
  const FAQSection({super.key});

  @override
  State<FAQSection> createState() => _FAQSectionState();
}

class _FAQSectionState extends State<FAQSection> with TickerProviderStateMixin {
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
                final isExpanded = _expandedIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: isExpanded
                          ? Colors.purple[600]!
                          : Colors.grey.withValues(alpha: 0.2),
                      width: isExpanded ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        // Pergunta
                        InkWell(
                          onTap: () => _toggleExpansion(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['question']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.125 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isExpanded
                                          ? Colors.purple[600]
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: isExpanded
                                          ? Colors.white
                                          : Colors.grey[600],
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Resposta (expansível)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: isExpanded ? null : 0,
                          child: isExpanded
                              ? Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    border: Border(
                                      top: BorderSide(
                                        color:
                                            Colors.grey.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    item['answer']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.6,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
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

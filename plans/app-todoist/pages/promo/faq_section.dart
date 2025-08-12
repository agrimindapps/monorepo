// Flutter imports:
import 'package:flutter/material.dart';

class TodoistFAQSection extends StatefulWidget {
  const TodoistFAQSection({super.key});

  @override
  State<TodoistFAQSection> createState() => _TodoistFAQSectionState();
}

class _TodoistFAQSectionState extends State<TodoistFAQSection>
    with TickerProviderStateMixin {
  int? _expandedIndex;

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'O Todoist é gratuito?',
      'answer':
          'Sim, o Todoist oferece um plano gratuito robusto que inclui até 80 projetos, 5 pessoas por projeto, e recursos essenciais de produtividade. Também oferecemos planos premium com recursos avançados.',
    },
    {
      'question': 'Posso usar o Todoist offline?',
      'answer':
          'Sim, você pode usar o Todoist offline em todos os dispositivos. Suas alterações serão sincronizadas automaticamente quando você se conectar à internet novamente.',
    },
    {
      'question': 'Como funciona a sincronização entre dispositivos?',
      'answer':
          'O Todoist sincroniza automaticamente em tempo real entre todos os seus dispositivos - celular, tablet, computador e navegador. Suas tarefas e projetos estão sempre atualizados.',
    },
    {
      'question': 'Posso colaborar com outras pessoas em projetos?',
      'answer':
          'Sim, você pode compartilhar projetos com colegas, família ou amigos. Atribua tarefas, adicione comentários e acompanhe o progresso colaborativo em tempo real.',
    },
    {
      'question': 'Como funcionam os lembretes e notificações?',
      'answer':
          'O Todoist envia lembretes inteligentes baseados em prazos, localização e prioridade. Você pode personalizar completamente quando e como receber notificações.',
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
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 40,
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
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE44332),
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
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isExpanded
                          ? const Color(0xFFE44332)
                          : Colors.grey[200]!,
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
                                          ? const Color(0xFFE44332)
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
                                        color: Colors.grey[200]!,
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

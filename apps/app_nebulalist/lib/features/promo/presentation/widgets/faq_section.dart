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
      'question': 'O NebulaList é gratuito?',
      'answer':
          'Sim, o NebulaList oferece uma versão gratuita completa com todas as funcionalidades essenciais. Também temos planos premium com recursos avançados para quem precisa de mais poder.',
    },
    {
      'question': 'Posso usar offline?',
      'answer':
          'Sim! O NebulaList funciona perfeitamente offline. Todas as suas tarefas e listas ficam disponíveis mesmo sem internet. Quando você se conectar novamente, tudo será sincronizado automaticamente.',
    },
    {
      'question': 'Como funciona a sincronização?',
      'answer':
          'Seus dados são sincronizados automaticamente na nuvem em tempo real. Você pode acessar suas tarefas de qualquer dispositivo e todas as alterações são refletidas instantaneamente em todos os seus aparelhos.',
    },
    {
      'question': 'Posso compartilhar listas com outras pessoas?',
      'answer':
          'Sim! Você pode compartilhar listas e tarefas com amigos, família ou colegas de trabalho. Todos podem colaborar em tempo real, adicionar tarefas e marcar conclusões.',
    },
    {
      'question': 'Meus dados estão seguros?',
      'answer':
          'Absolutamente! Utilizamos criptografia de ponta a ponta e servidores seguros para proteger seus dados. Suas informações são privadas e nunca serão compartilhadas com terceiros.',
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
        horizontal: isMobile ? 20 : screenSize.width * 0.1,
      ),
      child: Column(
        children: [
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
                  color: const Color(0xFF673AB7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
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
                      iconColor: const Color(0xFF673AB7),
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

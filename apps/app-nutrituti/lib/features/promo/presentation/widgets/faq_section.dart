import 'package:flutter/material.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int _expandedIndex = -1;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'O NutriTuti é gratuito?',
      'answer':
          'Sim! O NutriTuti oferece uma versão gratuita com todas as funcionalidades essenciais. Também temos planos premium com recursos avançados para quem deseja uma experiência completa.',
    },
    {
      'question': 'Como funciona o cálculo de macros?',
      'answer':
          'Nosso algoritmo calcula automaticamente as calorias, proteínas, carboidratos e gorduras de cada alimento com base em uma extensa base de dados nutricional. Basta registrar o que você comeu!',
    },
    {
      'question': 'Posso sincronizar em múltiplos dispositivos?',
      'answer':
          'Sim! Com sua conta, seus dados ficam sincronizados na nuvem e você pode acessar de qualquer dispositivo - celular, tablet ou computador.',
    },
    {
      'question': 'O app funciona offline?',
      'answer':
          'Sim! Você pode registrar suas refeições mesmo sem conexão com a internet. Quando voltar online, tudo será sincronizado automaticamente.',
    },
    {
      'question': 'Como cancelo minha assinatura?',
      'answer':
          'Você pode cancelar a qualquer momento diretamente nas configurações do app ou através da loja de aplicativos (App Store ou Google Play). Não cobramos taxas de cancelamento.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 900;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 100,
        horizontal: isMobile ? 20 : screenSize.width * 0.08,
      ),
      color: Colors.white,
      child: Column(
        children: [
          _buildSectionHeader(isMobile),
          const SizedBox(height: 60),
          Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: _faqs.asMap().entries.map((entry) {
                return _buildFaqItem(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isMobile) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Text(
            'FAQ',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Perguntas Frequentes',
          style: TextStyle(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'Encontre respostas para as dúvidas mais comuns sobre o NutriTuti.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFaqItem(int index, Map<String, String> faq) {
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isExpanded ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? Colors.green[200]! : Colors.grey[200]!,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: Key(index.toString()),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedIndex = expanded ? index : -1;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          childrenPadding:
              const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isExpanded ? Colors.green[100] : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpanded ? Icons.remove : Icons.add,
              color: isExpanded ? Colors.green[700] : Colors.grey[600],
            ),
          ),
          title: Text(
            faq['question']!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isExpanded ? Colors.green[800] : Colors.grey[800],
            ),
          ),
          trailing: const SizedBox.shrink(),
          children: [
            Text(
              faq['answer']!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

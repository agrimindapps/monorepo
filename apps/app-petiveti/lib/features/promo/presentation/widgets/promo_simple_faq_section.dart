import 'package:flutter/material.dart';
import '../../../../shared/constants/splash_constants.dart';

class PromoSimpleFaqSection extends StatefulWidget {
  const PromoSimpleFaqSection({super.key});

  @override
  State<PromoSimpleFaqSection> createState() => _PromoSimpleFaqSectionState();
}

class _PromoSimpleFaqSectionState extends State<PromoSimpleFaqSection> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final faqs = _getFAQs();
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 80,
      ),
      color: Colors.white,
      child: Column(
        children: [
          // Section Header
          _buildSectionHeader(context, isMobile),
          
          const SizedBox(height: 60),
          
          // FAQ List
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: faqs.asMap().entries.map((entry) {
                final index = entry.key;
                final faq = entry.value;
                return _buildFAQItem(faq, index);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, bool isMobile) {
    return Column(
      children: [
        Text(
          'Perguntas Frequentes',
          style: TextStyle(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: SplashColors.textColor,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'Tire suas dúvidas sobre o PetiVeti',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: SplashColors.textColor.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        // Accent line
        Container(
          margin: const EdgeInsets.only(top: 24),
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: SplashColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(_FAQData faq, int index) {
    final isExpanded = expandedIndex == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: SplashColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded 
              ? SplashColors.primaryColor.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question
          InkWell(
            onTap: () {
              setState(() {
                expandedIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      faq.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: SplashColors.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: SplashColors.primaryColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          
          // Answer
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                faq.answer,
                style: TextStyle(
                  fontSize: 14,
                  color: SplashColors.textColor.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<_FAQData> _getFAQs() {
    return [
      const _FAQData(
        question: 'O PetiVeti é gratuito?',
        answer: 'O PetiVeti oferece funcionalidades básicas gratuitas e um plano premium com recursos avançados. Você pode começar gratuitamente e fazer upgrade quando precisar.',
      ),
      const _FAQData(
        question: 'Como funciona o lembrete de vacinas?',
        answer: 'O app envia notificações automáticas baseadas no calendário de vacinação do seu pet. Você recebe alertas alguns dias antes da data marcada para não esquecer.',
      ),
      const _FAQData(
        question: 'Posso cadastrar mais de um pet?',
        answer: 'Sim! Você pode cadastrar quantos pets quiser, cada um com seu perfil individual, histórico médico e agenda personalizada.',
      ),
      const _FAQData(
        question: 'Os dados ficam seguros na nuvem?',
        answer: 'Sim, todos os dados são criptografados e armazenados com segurança. Você pode acessar as informações do seu pet em qualquer dispositivo.',
      ),
      const _FAQData(
        question: 'Quando o app será lançado?',
        answer: 'O PetiVeti será lançado em 1º de outubro de 2025. Faça seu pré-cadastro para ser um dos primeiros a usar!',
      ),
    ];
  }
}

class _FAQData {
  final String question;
  final String answer;

  const _FAQData({
    required this.question,
    required this.answer,
  });
}
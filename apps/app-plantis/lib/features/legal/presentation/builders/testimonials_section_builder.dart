import 'package:flutter/material.dart';

/// Builder estático para seção de Depoimentos
/// SRP: Isolates testimonials section UI construction
class TestimonialsSectionBuilder {
  static Widget build({required double screenWidth}) {
    final isMobile = screenWidth < 800;

    final testimonials = [
      {
        'name': 'Ana Costa',
        'text':
            'O Plantis mudou completamente minha rotina! Nunca mais esqueci de regar minhas plantas.',
        'rating': 5,
        'avatar': Icons.person,
      },
      {
        'name': 'Pedro Silva',
        'text':
            'Excelente app! Os lembretes são precisos e a interface é muito intuitiva.',
        'rating': 5,
        'avatar': Icons.person_outline,
      },
      {
        'name': 'Maria Oliveira',
        'text':
            'Minhas plantas nunca estiveram tão saudáveis. Recomendo para todos os jardineiros!',
        'rating': 5,
        'avatar': Icons.person,
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 24 : 40,
      ),
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'O Que Dizem Sobre Nós',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Milhares de jardineiros já estão transformando seu jardim',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: testimonials.map((testimonial) {
                  return SizedBox(
                    width: isMobile ? screenWidth - 48 : 320,
                    child: _buildTestimonialCard(
                      testimonial['name'] as String,
                      testimonial['text'] as String,
                      testimonial['rating'] as int,
                      testimonial['avatar'] as IconData,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildTestimonialCard(
    String name,
    String text,
    int rating,
    IconData avatar,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                child: Icon(avatar, color: const Color(0xFF4CAF50)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        rating,
                        (index) => const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.6,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

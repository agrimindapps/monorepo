// Flutter imports:
import 'package:flutter/material.dart';

class TodoistTestimonialsSection extends StatelessWidget {
  final List<Map<String, dynamic>> testimonials;

  const TodoistTestimonialsSection({super.key, required this.testimonials});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Column(
        children: [
          // Título da seção
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'O Que Nossos ',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                TextSpan(
                  text: 'Usuários',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE44332),
                    height: 1.2,
                  ),
                ),
                TextSpan(
                  text: ' Dizem',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),

          // Cards de depoimentos
          isMobile ? _buildMobileTestimonials() : _buildDesktopTestimonials(),
        ],
      ),
    );
  }

  Widget _buildDesktopTestimonials() {
    return Row(
      children: testimonials.map((testimonial) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: _buildTestimonialCard(testimonial),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileTestimonials() {
    return Column(
      children: testimonials.map((testimonial) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: _buildTestimonialCard(testimonial),
        );
      }).toList(),
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFE44332).withValues(alpha: 0.1),
            child: Icon(
              testimonial['avatar'],
              color: const Color(0xFFE44332),
              size: 30,
            ),
          ),

          const SizedBox(height: 16),

          // Nome
          Text(
            testimonial['name'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          // Estrelas de avaliação
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < testimonial['rating'] ? Icons.star : Icons.star_outline,
                color: const Color(0xFFFFA726),
                size: 16,
              );
            }),
          ),

          const SizedBox(height: 16),

          // Comentário
          Text(
            '"${testimonial['comment']}"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

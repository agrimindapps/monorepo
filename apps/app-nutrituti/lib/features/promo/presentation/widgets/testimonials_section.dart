import 'package:flutter/material.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : screenSize.width * 0.08,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'O Que Nossos ',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                TextSpan(
                  text: 'Usuários',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                    height: 1.2,
                  ),
                ),
                TextSpan(
                  text: ' Dizem',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildTestimonialCard(
                name: 'Marina Silva',
                role: 'Nutricionista',
                content:
                    'O NutriTuti revolucionou a forma como acompanho meus pacientes. Interface intuitiva e relatórios completos!',
                rating: 5,
                imageColor: Colors.green,
              ),
              const SizedBox(height: 30),
              _buildTestimonialCard(
                name: 'Carlos Eduardo',
                role: 'Personal Trainer',
                content:
                    'Perfeito para recomendar aos meus alunos. O cálculo de macros é preciso e fácil de entender.',
                rating: 5,
                imageColor: Colors.blue,
              ),
            ],
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 40), // Offset for masonry effect
              _buildTestimonialCard(
                name: 'Juliana Mendes',
                role: 'Usuária Premium',
                content:
                    'Consegui alcançar minhas metas de emagrecimento de forma saudável. O app me guiou em cada refeição.',
                rating: 5,
                imageColor: Colors.purple,
              ),
              const SizedBox(height: 30),
              _buildTestimonialCard(
                name: 'Roberto Santos',
                role: 'Atleta Amador',
                content:
                    'Os lembretes de hidratação e refeições me ajudam a manter a disciplina. Recomendo demais!',
                rating: 4,
                imageColor: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildTestimonialCard(
          name: 'Marina Silva',
          role: 'Nutricionista',
          content:
              'O NutriTuti revolucionou a forma como acompanho meus pacientes. Interface intuitiva e relatórios completos!',
          rating: 5,
          imageColor: Colors.green,
        ),
        const SizedBox(height: 20),
        _buildTestimonialCard(
          name: 'Juliana Mendes',
          role: 'Usuária Premium',
          content:
              'Consegui alcançar minhas metas de emagrecimento de forma saudável. O app me guiou em cada refeição.',
          rating: 5,
          imageColor: Colors.purple,
        ),
        const SizedBox(height: 20),
        _buildTestimonialCard(
          name: 'Carlos Eduardo',
          role: 'Personal Trainer',
          content:
              'Perfeito para recomendar aos meus alunos. O cálculo de macros é preciso e fácil de entender.',
          rating: 5,
          imageColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildTestimonialCard({
    required String name,
    required String role,
    required String content,
    required int rating,
    required Color imageColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                size: 20,
                color: index < rating ? Colors.amber[400] : Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '"$content"',
            style: const TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Color(0xFF334155), // Slate 700
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: imageColor.withValues(alpha: 0.2),
                radius: 24,
                child: Text(
                  name[0],
                  style: TextStyle(
                    color: imageColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

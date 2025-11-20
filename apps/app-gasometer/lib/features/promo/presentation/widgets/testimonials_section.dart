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
                    color: Colors.blue[800],
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
                name: 'Ricardo Silva',
                role: 'Motorista de App',
                content:
                    'O GasOMeter mudou completamente a forma como controlo meus gastos. A economia no final do mês é real!',
                rating: 5,
                imageColor: Colors.blue,
              ),
              const SizedBox(height: 30),
              _buildTestimonialCard(
                name: 'Ana Paula',
                role: 'Representante Comercial',
                content:
                    'Interface super intuitiva e relatórios detalhados. Consigo saber exatamente quanto gasto por km rodado.',
                rating: 5,
                imageColor: Colors.purple,
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
                name: 'Carlos Mendes',
                role: 'Entusiasta Automotivo',
                content:
                    'A funcionalidade de lembretes de manutenção é fantástica. Nunca mais esqueci de trocar o óleo na data certa.',
                rating: 5,
                imageColor: Colors.orange,
              ),
              const SizedBox(height: 30),
              _buildTestimonialCard(
                name: 'Fernanda Oliveira',
                role: 'Gestora de Frota',
                content:
                    'Uso para gerenciar os 3 carros da família. É impressionante como ficou fácil organizar tudo em um só lugar.',
                rating: 4,
                imageColor: Colors.green,
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
          name: 'Ricardo Silva',
          role: 'Motorista de App',
          content:
              'O GasOMeter mudou completamente a forma como controlo meus gastos. A economia no final do mês é real!',
          rating: 5,
          imageColor: Colors.blue,
        ),
        const SizedBox(height: 20),
        _buildTestimonialCard(
          name: 'Ana Paula',
          role: 'Representante Comercial',
          content:
              'Interface super intuitiva e relatórios detalhados. Consigo saber exatamente quanto gasto por km rodado.',
          rating: 5,
          imageColor: Colors.purple,
        ),
        const SizedBox(height: 20),
        _buildTestimonialCard(
          name: 'Carlos Mendes',
          role: 'Entusiasta Automotivo',
          content:
              'A funcionalidade de lembretes de manutenção é fantástica. Nunca mais esqueci de trocar o óleo na data certa.',
          rating: 5,
          imageColor: Colors.orange,
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
        ],
      ),
    );
  }
}

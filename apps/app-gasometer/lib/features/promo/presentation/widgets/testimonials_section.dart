import 'package:flutter/material.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  int _selectedIndex = 0;
  final _avatarColors = [
    Colors.blue[100]!,
    Colors.green[100]!,
    Colors.amber[100]!,
  ];

  final _avatarIconColors = [
    Colors.blue[800]!,
    Colors.green[700]!,
    Colors.amber[700]!,
  ];

  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Carlos Silva',
      'role': 'Motorista de App',
      'text': 'O GasOMeter me ajudou a reduzir meus gastos com combustível em 20%. Agora consigo acompanhar o consumo em tempo real.',
      'rating': 5,
    },
    {
      'name': 'Maria Santos',
      'role': 'Empresária',
      'text': 'Excelente para controlar a frota da empresa. Os relatórios são muito detalhados e me ajudam na tomada de decisões.',
      'rating': 5,
    },
    {
      'name': 'João Costa',
      'role': 'Engenheiro',
      'text': 'Interface simples e intuitiva. Consigo registrar tudo rapidamente e os lembretes de manutenção são muito úteis.',
      'rating': 5,
    },
  ];

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
                  text: ' Vão Dizer',
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
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: const Text(
              'Veja como o GasOMeter tem ajudado motoristas a ter maior controle em todo o Brasil',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 60),
          Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: isMobile ? _buildMobileTestimonials() : _buildDesktopTestimonials(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTestimonials() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _testimonials.asMap().entries.map((entry) {
        final index = entry.key;
        final testimonial = entry.value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildTestimonialCard(testimonial, index),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileTestimonials() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _testimonials.length,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _selectedIndex == index ? 30 : 10,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: _selectedIndex == index
                      ? Colors.blue[800]
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buildTestimonialCard(_testimonials[_selectedIndex], _selectedIndex),
      ],
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial, int index) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _avatarColors[index % _avatarColors.length],
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: _avatarIconColors[index % _avatarIconColors.length],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              testimonial['rating'] as int,
              (index) => Icon(
                Icons.star,
                color: Colors.amber[400],
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"${testimonial['text']}"',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            testimonial['name'] as String,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            testimonial['role'] as String,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
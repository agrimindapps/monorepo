// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'João Silva',
      'role': 'Produtor Rural - MT',
      'image': 'assets/imagens/others/profile1.jpg',
      'text':
          'O ReceiturAgro revolucionou a maneira como diagnostico problemas na lavoura. A identificação de pragas é precisa e as recomendações são realmente efetivas.',
    },
    {
      'name': 'Maria Oliveira',
      'role': 'Engenheira Agrônoma - SP',
      'image': 'assets/imagens/others/profile2.jpg',
      'text':
          'Como consultora, utilizo o app diariamente para rápida identificação de pragas e doenças. A base de dados de defensivos é completa e sempre atualizada.',
    },
    {
      'name': 'Carlos Santos',
      'role': 'Cooperativa Agrícola - RS',
      'image': 'assets/imagens/others/profile3.jpg',
      'text':
          'Nossa cooperativa implementou o uso do ReceiturAgro entre os associados e vimos um aumento significativo na eficiência do manejo de pragas.',
    },
    {
      'name': 'Ana Costa',
      'role': 'Técnica Agrícola - PR',
      'image': 'assets/imagens/others/profile4.jpg',
      'text':
          'O aplicativo facilita demais meu trabalho no campo. Consigo identificar rapidamente problemas nas culturas e recomendar as soluções mais adequadas.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade50,
            Colors.green.shade100,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          const Text(
            'O Que Dizem Nossos Usuários',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Depoimentos de profissionais e produtores rurais',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 50),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 320,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _testimonials.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildTestimonialCard(_testimonials[index]),
                    );
                  },
                ),
              ),
              if (size.width > 600) ...[
                Positioned(
                  left: 0,
                  child: IconButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.green,
                    ),
                    splashRadius: 20,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.green,
                    ),
                    splashRadius: 20,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _testimonials.length,
              (index) => _buildDotIndicator(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              FontAwesome.quote_left_solid,
              color: Colors.green,
              size: 30,
            ),
            const SizedBox(height: 16),
            Text(
              testimonial['text'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildAuthorInfo(testimonial),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(Map<String, dynamic> testimonial) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(testimonial['image']),
          onBackgroundImageError: (exception, stackTrace) {},
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Icon(
              Icons.person,
              color: Colors.grey.shade400,
              size: 25,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              testimonial['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              testimonial['role'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.green : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

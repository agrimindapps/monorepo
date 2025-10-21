// Dart imports:
import 'dart:async';
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

class TestimonialsSection extends StatefulWidget {
  final List<Map<String, dynamic>> testimonials;

  const TestimonialsSection({super.key, required this.testimonials});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController(viewportFraction: 0.85);
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  int _hoveredIndex = -1;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Iniciar o auto-scroll do carrossel
    _startAutoScroll();

    // Ouvir as mudanças de página para atualizar o indicador
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (_currentPage != page && page < widget.testimonials.length) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < widget.testimonials.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Elementos decorativos
          ..._buildDecorativeElements(),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ícone de aspas estilizado
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.format_quote,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              // Título com estilo destacado
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  children: [
                    const TextSpan(text: 'O que Dizem '),
                    TextSpan(
                      text: 'Nossos Usuários',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Subtítulo estilizado
              Container(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  'Descubra como o Calculei tem transformado o dia a dia de pessoas em diferentes áreas profissionais',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Carrossel de depoimentos
              SizedBox(
                height: 320,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.testimonials.length,
                  itemBuilder: (context, index) {
                    final testimonial = widget.testimonials[index];
                    return MouseRegion(
                      onEnter: (_) => setState(() => _hoveredIndex = index),
                      onExit: (_) => setState(() => _hoveredIndex = -1),
                      child: _buildTestimonialCard(
                        name: testimonial['name'],
                        comment: testimonial['comment'],
                        rating: testimonial['rating'],
                        context: context,
                        isHovered: _hoveredIndex == index,
                        isActive: _currentPage == index,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Indicadores de página
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.testimonials.length,
                  (index) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: _currentPage == index ? 24 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Botão para ver mais
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.rate_review,
                  color: Theme.of(context).primaryColor,
                ),
                label: const Text(
                  'Mais depoimentos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Elementos decorativos animados
  List<Widget> _buildDecorativeElements() {
    return [
      // Círculos decorativos
      Positioned(
        top: 40,
        left: 40,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                math.sin(_animationController.value * math.pi * 2) * 10,
                math.cos(_animationController.value * math.pi * 2) * 10,
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.07),
                ),
              ),
            );
          },
        ),
      ),

      Positioned(
        bottom: 60,
        right: 60,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                math.cos(_animationController.value * math.pi * 2) * 15,
                math.sin(_animationController.value * math.pi * 2) * 15,
              ),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.05),
                ),
              ),
            );
          },
        ),
      ),

      // Pequenos ícones de calculadoras espalhados
      Positioned(
        top: 180,
        left: 80,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animationController.value * math.pi * 2,
              child: Icon(
                Icons.calculate,
                size: 24,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              ),
            );
          },
        ),
      ),

      Positioned(
        bottom: 120,
        right: 100,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: -_animationController.value * math.pi * 2,
              child: Icon(
                Icons.apps,
                size: 20,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.15),
              ),
            );
          },
        ),
      ),
    ];
  }

  // Card de depoimento
  Widget _buildTestimonialCard({
    required String name,
    required String comment,
    required int rating,
    required BuildContext context,
    required bool isHovered,
    required bool isActive,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isHovered || isActive ? 10 : 20,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isHovered || isActive
                ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isHovered || isActive ? 20 : 10,
            spreadRadius: isHovered || isActive ? 5 : 1,
            offset: isHovered || isActive
                ? const Offset(0, 10)
                : const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isHovered || isActive
              ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      transform: isHovered || isActive
          ? (Matrix4.identity()..scale(1.03))
          : Matrix4.identity(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone de aspas decorativo
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.format_quote,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),

          // Depoimento
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '"$comment"',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Divisor
          Container(
            height: 1,
            width: 40,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          ),

          const SizedBox(height: 16),

          // Informações do usuário
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        ),
                      ),
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

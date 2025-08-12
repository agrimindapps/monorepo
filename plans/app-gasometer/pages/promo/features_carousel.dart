// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FeaturesCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> features;

  const FeaturesCarousel({super.key, required this.features});

  @override
  State<FeaturesCarousel> createState() => _FeaturesCarouselState();
}

class _FeaturesCarouselState extends State<FeaturesCarousel>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 0.85);
  late final AnimationController _animationController;

  // Cores para cada cartão de funcionalidade
  final List<Color> _cardColors = [
    Colors.blue.shade800,
    Colors.green.shade700,
    Colors.amber.shade700,
    Colors.purple.shade700,
  ];

  @override
  void initState() {
    super.initState();

    // Animação para elementos flutuantes
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Auto-scroll para o carrossel
    // Future.delayed(const Duration(seconds: 5), () {
    //   if (mounted) {
    //     _autoScroll();
    //   }
    // });
  }

  void _autoScroll() {
    if (!mounted) return;

    final nextPage = (_currentPage + 1) % widget.features.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );

    // Only schedule next auto-scroll if still mounted
    if (mounted) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) _autoScroll();
      });
    }
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : screenSize.width * 0.08,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // Título da seção
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Funcionalidades ',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                TextSpan(
                  text: 'Poderosas',
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
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
              'Descubra como o GasOMeter pode transformar o gerenciamento do seu veículo e otimizar seu controle',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 60),

          // Carrossel de funcionalidades
          isMobile ? _buildMobileCarousel() : _buildDesktopFeatureGrid(),
        ],
      ),
    );
  }

  Widget _buildDesktopFeatureGrid() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determinar número de colunas com base no tamanho da tela
    int crossAxisCount = 2;
    if (screenWidth > 1600) {
      crossAxisCount = 4;
    } else if (screenWidth > 1200) {
      crossAxisCount = 3;
    }

    return AlignedGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 30,
      crossAxisSpacing: 30,
      itemCount: widget.features.length,
      itemBuilder: (context, index) {
        return _buildFeatureCard(widget.features[index], index);
      },
    );
  }

  Widget _buildMobileCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 380,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.features.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return AnimatedPadding(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: _currentPage == index ? 0 : 20,
                ),
                child: _buildFeatureCard(widget.features[index], index),
              );
            },
          ),
        ),

        // Indicadores de página
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.features.length,
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
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 10,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: _currentPage == index
                      ? _cardColors[index % _cardColors.length]
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, int index) {
    final cardColor = _cardColors[index % _cardColors.length];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Cartão principal
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Círculo de ícone
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cardColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      size: 40,
                      color: cardColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título
                  Text(
                    feature['title'] as String,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  Text(
                    feature['description'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Elementos decorativos flutuantes
            Positioned(
              top: -10 +
                  10 *
                      math.sin(
                          _animationController.value * math.pi * 2 + index),
              right: -10,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -15 +
                  10 *
                      math.sin(
                          _animationController.value * math.pi * 2 + index + 2),
              left: 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Indicador "Destaque" para o primeiro item
            if (index == 0)
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'DESTAQUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

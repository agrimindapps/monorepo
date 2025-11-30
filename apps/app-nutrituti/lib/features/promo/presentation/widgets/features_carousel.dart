import 'dart:ui';
import 'package:flutter/material.dart';

class FeaturesCarousel extends StatefulWidget {
  const FeaturesCarousel({super.key, required this.features});
  final List<Map<String, dynamic>> features;

  @override
  State<FeaturesCarousel> createState() => _FeaturesCarouselState();
}

class _FeaturesCarouselState extends State<FeaturesCarousel> {
  int _currentPage = 0;
  final PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 0.85);
  
  // Hover state for desktop
  int? _hoveredIndex;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 900;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 100,
        horizontal: isMobile ? 20 : screenSize.width * 0.08,
      ),
      // Dark gradient background matching theme
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF047857), // Emerald 700
            Color(0xFF065F46), // Emerald 800
          ],
        ),
      ),
      child: Column(
        children: [
          _buildSectionHeader(isMobile),
          const SizedBox(height: 60),
          isMobile ? _buildMobileCarousel() : _buildDesktopFeatureGrid(),
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
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
          ),
          child: Text(
            'FUNCIONALIDADES',
            style: TextStyle(
              color: Colors.green[300],
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tudo o que você precisa',
          style: TextStyle(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        // Gradient text
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.green[300]!, Colors.teal[300]!],
          ).createShader(bounds),
          child: Text(
            'para uma vida saudável',
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Text(
            'O NutriTuti reúne todas as ferramentas essenciais para você alcançar seus objetivos nutricionais com praticidade e inteligência.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.green[100],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFeatureGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (screenWidth > 1600) {
      crossAxisCount = 4;
    } else if (screenWidth > 1200) {
      crossAxisCount = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 30,
        crossAxisSpacing: 30,
        childAspectRatio: 0.85,
      ),
      itemCount: widget.features.length,
      itemBuilder: (context, index) {
        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredIndex = index),
          onExit: (_) => setState(() => _hoveredIndex = null),
          child: _buildFeatureCard(widget.features[index], index, isHovered: _hoveredIndex == index),
        );
      },
    );
  }

  Widget _buildMobileCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 420,
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
                  horizontal: 10,
                  vertical: _currentPage == index ? 0 : 20,
                ),
                child: _buildFeatureCard(widget.features[index], index, isHovered: _currentPage == index),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
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
                width: _currentPage == index ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentPage == index
                      ? Colors.green[400]
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, int index, {bool isHovered = false}) {
    // Different accent colors for cards
    final List<Color> accentColors = [
      Colors.green,
      Colors.teal,
      Colors.cyan,
      Colors.lightGreen,
    ];
    final accentColor = accentColors[index % accentColors.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.translationValues(0.0, isHovered ? -10.0 : 0.0, 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isHovered 
                    ? accentColor.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
                width: isHovered ? 2 : 1,
              ),
              boxShadow: [
                if (isHovered)
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    size: 32,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  feature['title'] as String,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  feature['description'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[100],
                    height: 1.6,
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  opacity: isHovered ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      Text(
                        'Saiba mais',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

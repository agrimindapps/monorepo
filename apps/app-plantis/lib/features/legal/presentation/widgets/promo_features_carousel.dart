import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';

class PromoFeaturesCarousel extends StatefulWidget {
  const PromoFeaturesCarousel({super.key});

  @override
  State<PromoFeaturesCarousel> createState() => _PromoFeaturesCarouselState();
}

class _PromoFeaturesCarouselState extends State<PromoFeaturesCarousel>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.85,
  );
  late final AnimationController _animationController;

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.eco,
      'title': 'Registro Completo',
      'description':
          'Cadastre suas plantas com fotos, espécie, localização e configurações personalizadas de cuidados.',
      'color': PlantisColors.leaf,
    },
    {
      'icon': Icons.notifications_active,
      'title': 'Lembretes Inteligentes',
      'description':
          'Receba notificações automáticas para regar, adubar e cuidar das suas plantas no momento certo.',
      'color': PlantisColors.water,
    },
    {
      'icon': Icons.analytics,
      'title': 'Análise de Crescimento',
      'description':
          'Acompanhe o desenvolvimento das suas plantas com histórico fotográfico e estatísticas detalhadas.',
      'color': PlantisColors.sun,
    },
    {
      'icon': Icons.cloud_sync,
      'title': 'Sincronização na Nuvem',
      'description':
          'Seus dados seguros e sincronizados em todos os dispositivos com backup automático.',
      'color': PlantisColors.primary,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
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
                    color: PlantisColors.primary,
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
              'Descubra como o Plantis pode transformar o cuidado com suas plantas e ajudá-lo a criar um jardim saudável e vibrante',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),

          // Carousel de funcionalidades
          SizedBox(
            height: isMobile ? 320 : 350,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _features.length,
              itemBuilder: (context, index) {
                final feature = _features[index];
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0.0;
                    if (_pageController.position.haveDimensions) {
                      value = index.toDouble() - (_pageController.page ?? 0);
                      value = (value * 0.038).clamp(-1, 1);
                    }
                    return Center(
                      child: Transform.rotate(
                        angle: value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildFeatureCard(
                    feature,
                    index == _currentPage,
                    isMobile,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Indicadores de página
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _features.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? PlantisColors.primary
                      : PlantisColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    Map<String, dynamic> feature,
    bool isActive,
    bool isMobile,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isActive ? 0 : 20,
      ),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            feature['color'] as Color,
            (feature['color'] as Color).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (feature['color'] as Color).withValues(alpha: 0.4),
            blurRadius: isActive ? 30 : 15,
            offset: Offset(0, isActive ? 15 : 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              feature['icon'] as IconData,
              size: isMobile ? 48 : 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            feature['title'] as String,
            style: TextStyle(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            feature['description'] as String,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
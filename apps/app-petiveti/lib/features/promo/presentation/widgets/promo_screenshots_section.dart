import 'package:flutter/material.dart';
import '../../../../shared/constants/splash_constants.dart';

class PromoScreenshotsSection extends StatelessWidget {
  final dynamic screenshots; // Will be ignored, using placeholder screenshots
  final int currentIndex;
  final Function(int) onScreenshotChanged;

  const PromoScreenshotsSection({
    super.key,
    required this.screenshots,
    required this.currentIndex,
    required this.onScreenshotChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      height: isMobile ? 500 : 600,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xCC6A1B9A), // Purple 800 with opacity
            Color(0xFF6A1B9A), // Purple 800
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          _buildBackgroundElements(),
          _buildContent(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: 50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isMobile) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildSectionHeader(context, isMobile),
          const Spacer(),
          _buildScreenshotsCarousel(context, isMobile),
          const Spacer(),
          _buildCarouselIndicators(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Column(
        children: [
          Text(
            'Veja o PetiVeti em Ação',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              'Descubra como é fácil cuidar do seu pet com nossa interface intuitiva',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotsCarousel(BuildContext context, bool isMobile) {
    final screenshots = _getPlaceholderScreenshots();
    
    return SizedBox(
      height: isMobile ? 280 : 350,
      child: PageView.builder(
        onPageChanged: onScreenshotChanged,
        itemCount: screenshots.length,
        itemBuilder: (context, index) {
          final screenshot = screenshots[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildScreenshotCard(screenshot, isMobile),
          );
        },
      ),
    );
  }

  Widget _buildScreenshotCard(_ScreenshotData screenshot, bool isMobile) {
    return Container(
      width: isMobile ? 250 : 300,
      height: isMobile ? 280 : 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SplashColors.backgroundColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: SplashColors.primaryColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      screenshot.icon,
                      size: 48,
                      color: SplashColors.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      screenshot.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: SplashColors.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              screenshot.description,
              style: TextStyle(
                fontSize: 14,
                color: SplashColors.textColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    final screenshots = _getPlaceholderScreenshots();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(screenshots.length, (index) {
        final isActive = index == currentIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive 
                ? Colors.white 
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  List<_ScreenshotData> _getPlaceholderScreenshots() {
    return [
      const _ScreenshotData(
        icon: Icons.pets,
        title: 'Perfis de Pets',
        description: 'Gerencie todos os seus animais em um só lugar',
      ),
      const _ScreenshotData(
        icon: Icons.vaccines,
        title: 'Calendário de Vacinas',
        description: 'Nunca perca uma data importante de vacinação',
      ),
      const _ScreenshotData(
        icon: Icons.medication,
        title: 'Controle de Medicamentos',
        description: 'Organize horários e dosagens com facilidade',
      ),
      const _ScreenshotData(
        icon: Icons.monitor_weight,
        title: 'Acompanhamento do Peso',
        description: 'Monitore a saúde com gráficos detalhados',
      ),
    ];
  }
}

class _ScreenshotData {
  final IconData icon;
  final String title;
  final String description;

  const _ScreenshotData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
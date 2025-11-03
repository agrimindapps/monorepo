import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import 'promo_hero_countdown_badge.dart';

class PromoHeaderSection extends StatelessWidget {
  final bool comingSoon;
  final DateTime? launchDate;

  const PromoHeaderSection({
    this.comingSoon = false,
    this.launchDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primary,
            PlantisColors.secondary,
            PlantisColors.accent,
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 40,
              vertical: 80,
            ),
            child: isMobile
                ? _buildMobileContent(context)
                : _buildDesktopContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderText(),
              const SizedBox(height: 32),
              if (comingSoon && launchDate != null) ...[
                PromoHeroCountdownBadge(launchDate: launchDate!),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: _buildAppShowcase(),
        ),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderText(),
        const SizedBox(height: 24),
        if (comingSoon && launchDate != null) ...[
          PromoHeroCountdownBadge(launchDate: launchDate!),
          const SizedBox(height: 24),
        ],
        const SizedBox(height: 48),
        _buildAppShowcase(),
      ],
    );
  }

  Widget _buildHeaderText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuide das suas Plantas\ncom Amor e Tecnologia',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'O aplicativo mais completo para jardineiros apaixonados. Registre, acompanhe e receba lembretes inteligentes para manter suas plantas sempre saudáveis.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }


  Widget _buildAppShowcase() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 350,
          height: 350,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        Container(
          width: 280,
          height: 520,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 120,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      const Icon(
                        Icons.eco,
                        size: 60,
                        color: PlantisColors.primary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Plantis',
                        style: TextStyle(
                          color: PlantisColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildPlantCardMockup('Samambaia', PlantisColors.leaf),
                      const SizedBox(height: 12),
                      _buildPlantCardMockup('Suculenta', PlantisColors.water),
                      const SizedBox(height: 12),
                      _buildPlantCardMockup('Orquídea', PlantisColors.flower),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 40,
          child: _buildFloatingElement(Icons.water_drop, PlantisColors.water),
        ),
        Positioned(
          bottom: 80,
          left: 40,
          child: _buildFloatingElement(Icons.wb_sunny, PlantisColors.sun),
        ),
        Positioned(
          bottom: 180,
          right: 30,
          child: _buildFloatingElement(Icons.local_florist, PlantisColors.flower),
        ),
      ],
    );
  }

  Widget _buildPlantCardMockup(String plantName, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.eco, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plantName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    Icon(Icons.water_drop, size: 12, color: PlantisColors.water),
                    SizedBox(width: 4),
                    Text(
                      'Regar amanhã',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingElement(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

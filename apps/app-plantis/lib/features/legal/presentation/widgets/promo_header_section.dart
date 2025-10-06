import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/plantis_colors.dart';

class PromoHeaderSection extends StatelessWidget {
  const PromoHeaderSection({super.key});

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
              _buildActionButtons(context),
              const SizedBox(height: 24),
              _buildDownloadBadges(context),
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
        _buildActionButtons(context),
        const SizedBox(height: 20),
        _buildDownloadBadges(context),
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

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ElevatedButton(
          onPressed: () => context.go(AppRouter.login),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: PlantisColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.3),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Começar Agora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () {
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Ver Como Funciona',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadBadges(BuildContext context) {
    return Row(
      children: [
        _buildStoreBadge(
          icon: Icons.android,
          storeName: 'Google Play',
        ),
        const SizedBox(width: 12),
        _buildStoreBadge(
          icon: Icons.apple,
          storeName: 'App Store',
        ),
      ],
    );
  }

  Widget _buildStoreBadge({required IconData icon, required String storeName}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'DISPONÍVEL NA',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                storeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
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

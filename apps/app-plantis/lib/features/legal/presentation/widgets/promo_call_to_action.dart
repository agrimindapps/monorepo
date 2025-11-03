import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';

class PromoCallToAction extends StatelessWidget {
  const PromoCallToAction({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 24 : 40,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primary,
            PlantisColors.secondary,
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Icon(
                Icons.eco,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'Pronto para transformar seu jardim?',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Junte-se a milhares de jardineiros que já estão cuidando melhor de suas plantas com o Plantis',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Text(
                'Gratuito para sempre • Sem cartão de crédito',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 32),
              // Store download buttons (disabled)
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStoreButton(
                    icon: Icons.android,
                    label: 'Google Play',
                    enabled: false,
                    isMobile: isMobile,
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  _buildStoreButton(
                    icon: Icons.apple,
                    label: 'App Store',
                    enabled: false,
                    isMobile: isMobile,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required bool isMobile,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        height: isMobile ? 44 : 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: enabled ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: enabled ? 0.3 : 0.15),
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 20,
          vertical: 8,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
            SizedBox(width: isMobile ? 8 : 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'DISPONÍVEL NA',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: enabled ? 0.8 : 0.5),
                    fontSize: isMobile ? 8 : 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

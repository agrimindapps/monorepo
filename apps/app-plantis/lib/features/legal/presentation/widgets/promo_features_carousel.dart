import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';

/// Features section with grid layout showing 4 feature cards side by side
/// Replaces carousel for better visibility when features are few
class PromoFeaturesCarousel extends StatelessWidget {
  const PromoFeaturesCarousel({super.key});

  final List<Map<String, dynamic>> _features = const [
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
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width < 1024;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 16 : 40,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
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
          // Responsive grid layout
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: GridView.count(
                crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0, // Square cards with equal sizing
                children: _features.map((feature) {
                  return _buildFeatureCard(feature, isMobile);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    Map<String, dynamic> feature,
    bool isMobile,
  ) {
    return Container(
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
            blurRadius: 15,
            offset: const Offset(0, 8),
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
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              feature['description'] as String,
              style: TextStyle(
                fontSize: isMobile ? 13 : 15,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 6,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

class PromoFeaturesCarousel extends StatefulWidget {
  const PromoFeaturesCarousel({super.key});

  @override
  State<PromoFeaturesCarousel> createState() => _PromoFeaturesCarouselState();
}

class _PromoFeaturesCarouselState extends State<PromoFeaturesCarousel> {
  final List<Map<String, dynamic>> _features = const [
    {
      'icon': Icons.eco,
      'title': 'Registro Completo',
      'description':
          'Cadastre suas plantas com fotos, espécie, localização e configurações personalizadas de cuidados.',
      'color': Color(0xFF10B981), // Emerald
    },
    {
      'icon': Icons.notifications_active,
      'title': 'Lembretes Inteligentes',
      'description':
          'Receba notificações automáticas para regar, adubar e cuidar das suas plantas no momento certo.',
      'color': Color(0xFFF59E0B), // Sunlight Gold
    },
    {
      'icon': Icons.analytics,
      'title': 'Análise de Crescimento',
      'description':
          'Acompanhe o desenvolvimento das suas plantas com histórico fotográfico e estatísticas detalhadas.',
      'color': Color(0xFF3B82F6), // Sky Blue
    },
    {
      'icon': Icons.cloud_sync,
      'title': 'Sincronização na Nuvem',
      'description':
          'Seus dados seguros e sincronizados em todos os dispositivos com backup automático.',
      'color': Color(0xFF8B5CF6), // Violet
    },
  ];

  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width < 1024;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 100,
        horizontal: isMobile ? 16 : 40,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F2F21), // Deep Forest Green
            Color(0xFF0F172A), // Dark Slate (transition to next section)
          ],
        ),
      ),
      child: Column(
        children: [
          _buildSectionHeader(isMobile),
          const SizedBox(height: 60),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: AlignedGridView.count(
                crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _features.length,
                itemBuilder: (context, index) {
                  return _buildFeatureCard(_features[index], index, isMobile);
                },
              ),
            ),
          ),
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
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            'FUNCIONALIDADES',
            style: GoogleFonts.inter(
              color: const Color(0xFF10B981),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Tudo para seu ',
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: 'Jardim',
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981), // Emerald
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Text(
            'Descubra como o CantinhoVerde pode transformar o cuidado com suas plantas e ajudá-lo a criar um jardim saudável e vibrante.',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.grey[400],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    Map<String, dynamic> feature,
    int index,
    bool isMobile,
  ) {
    final isHovered = _hoveredIndex == index;
    final color = feature['color'] as Color;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0.0, isHovered ? -10.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isHovered
                      ? color.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        size: 32,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      feature['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      feature['description'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.grey[400],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

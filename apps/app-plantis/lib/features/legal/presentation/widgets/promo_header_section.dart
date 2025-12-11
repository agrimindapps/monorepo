import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'promo_hero_countdown_badge.dart';

class PromoHeaderSection extends StatefulWidget {
  final bool comingSoon;
  final DateTime? launchDate;

  const PromoHeaderSection({
    this.comingSoon = false,
    this.launchDate,
    super.key,
  });

  @override
  State<PromoHeaderSection> createState() => _PromoHeaderSectionState();
}

class _PromoHeaderSectionState extends State<PromoHeaderSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 900;

    return Stack(
      children: [
        // Animated Background
        Positioned.fill(
          child: CustomPaint(
            painter: _NatureBackgroundPainter(
              animation: _controller,
              color1: const Color(0xFF0F2F21), // Deep Forest Green
              color2: const Color(0xFF064E3B), // Dark Emerald
            ),
          ),
        ),

        // Content
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 40,
                vertical: isMobile ? 100 : 140,
              ),
              child: isMobile
                  ? _buildMobileContent(context)
                  : _buildDesktopContent(context),
            ),
          ),
        ),
      ],
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
              const SizedBox(height: 40),
              _buildActionButtons(),
              if (widget.comingSoon && widget.launchDate != null) ...[
                const SizedBox(height: 40),
                PromoHeroCountdownBadge(launchDate: widget.launchDate!),
              ],
              const SizedBox(height: 60),
              _buildStatsRow(),
            ],
          ),
        ),
        const SizedBox(width: 60),
        Expanded(flex: 5, child: _buildAppShowcase()),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHeaderText(textAlign: TextAlign.center),
        const SizedBox(height: 32),
        _buildActionButtons(isCentered: true),
        if (widget.comingSoon && widget.launchDate != null) ...[
          const SizedBox(height: 32),
          PromoHeroCountdownBadge(launchDate: widget.launchDate!),
        ],
        const SizedBox(height: 60),
        _buildAppShowcase(),
        const SizedBox(height: 60),
        _buildStatsRow(isCentered: true),
      ],
    );
  }

  Widget _buildHeaderText({TextAlign textAlign = TextAlign.start}) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.eco, color: Color(0xFF10B981), size: 16),
              const SizedBox(width: 8),
              Text(
                'O Futuro do Cuidado com Plantas',
                style: GoogleFonts.inter(
                  color: const Color(0xFF10B981), // Emerald
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          textAlign: textAlign,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Cultive seu Jardim com ',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              TextSpan(
                text: 'Inteligência',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF59E0B), // Sunlight Gold
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Transforme sua paixão por plantas em uma ciência exata. O Plantis combina tecnologia e natureza para garantir que seu jardim prospere.',
          style: GoogleFonts.inter(
            fontSize: 18,
            color: Colors.grey[300],
            height: 1.6,
          ),
          textAlign: textAlign,
        ),
      ],
    );
  }

  Widget _buildActionButtons({bool isCentered = false}) {
    return Row(
      mainAxisAlignment: isCentered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981), // Emerald
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: const Color(0xFF10B981).withValues(alpha: 0.5),
          ),
          child: const Text(
            'Começar Agora',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Saiba Mais',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow({bool isCentered = false}) {
    final stats = [
      {'value': '10k+', 'label': 'Plantas'},
      {'value': '4.8', 'label': 'Avaliação'},
      {'value': '100%', 'label': 'Gratuito'},
    ];

    return Row(
      mainAxisAlignment: isCentered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: stats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat['value']!,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  stat['label']!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            if (index < stats.length - 1)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 40,
                width: 1,
                color: Colors.white.withValues(alpha: 0.1),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAppShowcase() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF10B981).withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Phone Mockup
        Container(
          width: 300,
          height: 600,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                ColoredBox(
                  color: const Color(0xFFF8FAFC),
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F2F21),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(30),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Icon(
                                Icons.eco,
                                size: 150,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Olá, Jardineiro',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            'Minhas Plantas',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.notifications_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildMockupCard(
                              'Monstera Deliciosa',
                              'Regar hoje',
                              Icons.water_drop,
                              Colors.blue,
                            ),
                            const SizedBox(height: 16),
                            _buildMockupCard(
                              'Espada de São Jorge',
                              'Adubar em 2 dias',
                              Icons.eco,
                              Colors.green,
                            ),
                            const SizedBox(height: 16),
                            _buildMockupCard(
                              'Orquídea Phalaenopsis',
                              'Poda necessária',
                              Icons.cut,
                              Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Floating Cards
        Positioned(
          right: -20,
          top: 100,
          child: _buildFloatingCard(
            icon: Icons.wb_sunny,
            title: 'Luz Ideal',
            subtitle: 'Luz Indireta',
            color: Colors.amber,
          ),
        ),
        Positioned(
          left: -20,
          bottom: 150,
          child: _buildFloatingCard(
            icon: Icons.water_drop,
            title: 'Umidade',
            subtitle: '60% - 80%',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildMockupCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NatureBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color1;
  final Color color2;

  _NatureBackgroundPainter({
    required this.animation,
    required this.color1,
    required this.color2,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color1, color2],
      ).createShader(rect);

    canvas.drawRect(rect, paint);

    // Draw subtle organic shapes (leaves/particles)
    final random = math.Random(42); // Fixed seed for consistent pattern
    final particlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 100 + 50;
      final offset = animation.value * 50 * (i % 2 == 0 ? 1 : -1);

      canvas.drawCircle(Offset(x + offset, y + offset), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

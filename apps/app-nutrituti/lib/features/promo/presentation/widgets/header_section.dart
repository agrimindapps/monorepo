import 'dart:math' as math;
import 'package:flutter/material.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF064E3B), // Emerald 900
                  Color(0xFF065F46), // Emerald 800
                  Color(0xFF047857), // Emerald 700
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _BackgroundPainter(_controller.value),
              );
            },
          ),
        ),

        // Content
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 40,
                vertical: isMobile ? 60 : 100,
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
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadge(),
              const SizedBox(height: 24),
              _buildHeaderText(),
              const SizedBox(height: 32),
              _buildActionButtons(context),
              const SizedBox(height: 40),
              _buildStatsRow(),
            ],
          ),
        ),
        Expanded(
          flex: 6,
          child: Center(child: _buildAppShowcase()),
        ),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBadge(),
        const SizedBox(height: 24),
        _buildHeaderText(),
        const SizedBox(height: 32),
        _buildActionButtons(context),
        const SizedBox(height: 60),
        Center(child: _buildAppShowcase()),
        const SizedBox(height: 40),
        _buildStatsRow(),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco, color: Colors.green[300], size: 16),
          const SizedBox(width: 8),
          Text(
            'Nutrição Inteligente',
            style: TextStyle(
              color: Colors.green[300],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sua Saúde\nComeça Aqui',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -1.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        // Gradient text
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.green[300]!, Colors.teal[300]!],
          ).createShader(bounds),
          child: const Text(
            'com NutriTuti',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1.5,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Planeje suas refeições, acompanhe seus macros e alcance seus objetivos de saúde com a ajuda de inteligência nutricional.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.green[100],
            height: 1.6,
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
          onPressed: () {
            // TODO: Navigate to signup or waitlist
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[400],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: Colors.green.withValues(alpha: 0.4),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Começar Agora',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 12),
              Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () {
            // Scroll to features or video
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Saiba Mais',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem('10k+', 'Usuários'),
        Container(
          height: 40,
          width: 1,
          color: Colors.white.withValues(alpha: 0.1),
          margin: const EdgeInsets.symmetric(horizontal: 24),
        ),
        _buildStatItem('4.8', 'Avaliação'),
        Container(
          height: 40,
          width: 1,
          color: Colors.white.withValues(alpha: 0.1),
          margin: const EdgeInsets.symmetric(horizontal: 24),
        ),
        _buildStatItem('100%', 'Gratuito'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.green[200],
          ),
        ),
      ],
    );
  }

  Widget _buildAppShowcase() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Glow effect
        Container(
          width: 300,
          height: 500,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.green.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              radius: 0.7,
            ),
          ),
        ),
        // Phone Frame
        Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(-0.1)
            ..rotateZ(0.05),
          alignment: Alignment.center,
          child: Container(
            width: 280,
            height: 560,
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.grey[800]!, width: 8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 40,
                  offset: const Offset(20, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  // App UI Mockup
                  Container(
                    color: const Color(0xFFF0FDF4), // Green 50
                    child: Column(
                      children: [
                        // App Bar
                        Container(
                          height: 100,
                          padding:
                              const EdgeInsets.only(top: 40, left: 20, right: 20),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Olá, Nutricionista',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Sua Dieta',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.green[100],
                                child: Icon(Icons.person, color: Colors.green[800]),
                              ),
                            ],
                          ),
                        ),
                        // Dashboard Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildMockCard(
                                Icons.local_fire_department,
                                'Calorias Hoje',
                                '1,850 kcal',
                                Colors.orange,
                              ),
                              const SizedBox(height: 16),
                              _buildMockCard(
                                Icons.fitness_center,
                                'Proteínas',
                                '85g / 120g',
                                Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              _buildMockCard(
                                Icons.water_drop,
                                'Hidratação',
                                '1.5L / 2L',
                                Colors.cyan,
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
        ),
        // Floating Elements
        Positioned(
          right: -40,
          top: 100,
          child: _buildFloatingCard(
            icon: Icons.check_circle,
            title: 'Meta Atingida!',
            subtitle: 'Proteínas',
            color: Colors.green,
            delay: 0,
          ),
        ),
        Positioned(
          left: -40,
          bottom: 150,
          child: _buildFloatingCard(
            icon: Icons.trending_up,
            title: 'Progresso',
            subtitle: '+15% esta semana',
            color: Colors.blue,
            delay: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMockCard(
      IconData icon, String title, String value, MaterialColor color) {
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final yOffset = math.sin(_controller.value * 2 * math.pi + delay) * 10;
        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;

  _BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Draw animated grid lines
    for (var i = 0; i < width; i += 60) {
      final offset = math.sin((i / width + animationValue) * math.pi) * 20;
      path.moveTo(i.toDouble(), 0);
      path.quadraticBezierTo(
        i.toDouble() + offset,
        height / 2,
        i.toDouble(),
        height,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

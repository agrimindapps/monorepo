import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A237E).withValues(alpha: 0.95),
            const Color(0xFF311B92).withValues(alpha: 0.9),
            const Color(0xFF4A148C).withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Nebula background effect
          Positioned.fill(
            child: CustomPaint(
              painter: _NebulaPainter(),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 40,
                vertical: isSmallScreen ? 40 : 80,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo/Icon
                  Container(
                    width: isSmallScreen ? 80 : 120,
                    height: isSmallScreen ? 80 : 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.checklist_rounded,
                      size: isSmallScreen ? 40 : 60,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 40),
                  // Title
                  Text(
                    'NebulaList',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 36 : 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  // Subtitle
                  Text(
                    'Organize seu universo de tarefas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 24,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  // Description
                  Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Text(
                      'Listas inteligentes, sincronização em nuvem e organização como você nunca viu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 32 : 48),
                  // CTA Buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.push('/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1A237E),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 32 : 48,
                            vertical: isSmallScreen ? 16 : 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Começar Agora',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          // Scroll to features
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 32 : 48,
                            vertical: isSmallScreen ? 16 : 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Saiba Mais',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NebulaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    // Draw nebula circles
    final circles = [
      _NebulaCircle(
        offset: Offset(size.width * 0.2, size.height * 0.3),
        radius: 150,
        color: const Color(0xFF4A148C).withValues(alpha: 0.3),
      ),
      _NebulaCircle(
        offset: Offset(size.width * 0.7, size.height * 0.4),
        radius: 200,
        color: const Color(0xFF311B92).withValues(alpha: 0.2),
      ),
      _NebulaCircle(
        offset: Offset(size.width * 0.5, size.height * 0.7),
        radius: 180,
        color: const Color(0xFF1A237E).withValues(alpha: 0.25),
      ),
    ];

    for (final circle in circles) {
      paint.color = circle.color;
      canvas.drawCircle(circle.offset, circle.radius, paint);
    }

    // Draw stars
    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = (i * 37.5) % size.width;
      final y = (i * 53.7) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NebulaCircle {
  final Offset offset;
  final double radius;
  final Color color;

  _NebulaCircle({
    required this.offset,
    required this.radius,
    required this.color,
  });
}

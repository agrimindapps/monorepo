// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

class FooterSection extends StatefulWidget {
  const FooterSection({super.key});

  @override
  State<FooterSection> createState() => _FooterSectionState();
}

class _FooterSectionState extends State<FooterSection> {
  // Estado para controlar hover nos botões de redes sociais
  int _hoveredSocialIndex = -1;
  int _hoveredLinkIndex = -1;

  final List<Map<String, dynamic>> _legalLinks = [
    {'title': 'Termos de uso', 'onTap': null},
    {'title': 'Política de Privacidade', 'onTap': null},
    {'title': 'Cookies', 'onTap': null},
    {'title': 'Licenças', 'onTap': null},
  ];

  // Redes sociais
  final List<Map<String, dynamic>> _socialLinks = [
    {'icon': Icons.facebook, 'color': const Color(0xFF1877F2), 'onTap': null},
    {
      'icon': Icons.social_distance,
      'color': const Color(0xFF25D366),
      'onTap': null
    },
    {
      'icon': Icons.install_mobile,
      'color': const Color(0xFFE4405F),
      'onTap': null
    },
    {'icon': Icons.telegram, 'color': const Color(0xFF0088CC), 'onTap': null},
    {'icon': Icons.laptop, 'color': const Color(0xFF00ACEE), 'onTap': null},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFF161C24), // Cor escura para o footer
          ],
          stops: [0.0, 0.4],
        ),
      ),
      child: Column(
        children: [
          // Divisor decorativo
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.transparent],
              ),
            ),
            child: CustomPaint(
              painter: _WavyLinePainter(),
              child: Container(),
            ),
          ),

          // Container principal do footer com efeito de glassmorphism
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 60),
                color: const Color(0xFF161C24).withValues(alpha: 0.95),
                child: Column(
                  children: [
                    // Seção: Links legais
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildLinkColumn('Legal', _legalLinks),
                    ),

                    const SizedBox(height: 40),

                    Divider(
                        color: Colors.white.withValues(alpha: 0.1),
                        thickness: 1),

                    const SizedBox(height: 30),

                    // Seção: Redes sociais e copyright
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 800;

                          return isWide
                              ? _buildWideBottomSection()
                              : _buildNarrowBottomSection();
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // "Feito com amor"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Feito com',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'no Brasil',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Layout para a seção inferior em telas largas
  Widget _buildWideBottomSection() {
    return Row(
      children: [
        // Copyright
        Expanded(
          child: Text(
            '© ${DateTime.now().year} Calculei. Todos os direitos reservados.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ),

        // Redes sociais
        Row(
          children: _socialLinks.asMap().entries.map((entry) {
            final index = entry.key;
            final social = entry.value;
            return _buildSocialButton(
              icon: social['icon'] as IconData,
              color: social['color'] as Color,
              onTap: social['onTap'],
              isHovered: _hoveredSocialIndex == index,
              onHover: (isHovered) {
                setState(() {
                  _hoveredSocialIndex = isHovered ? index : -1;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Layout para a seção inferior em telas estreitas
  Widget _buildNarrowBottomSection() {
    return Column(
      children: [
        // Redes sociais
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _socialLinks.asMap().entries.map((entry) {
            final index = entry.key;
            final social = entry.value;
            return _buildSocialButton(
              icon: social['icon'] as IconData,
              color: social['color'] as Color,
              onTap: social['onTap'],
              isHovered: _hoveredSocialIndex == index,
              onHover: (isHovered) {
                setState(() {
                  _hoveredSocialIndex = isHovered ? index : -1;
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 30),

        // Copyright
        Text(
          '© ${DateTime.now().year} Calculei. Todos os direitos reservados.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Coluna de links
  Widget _buildLinkColumn(String title, List<Map<String, dynamic>> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: links.asMap().entries.map((entry) {
            final index = entry.key;
            final link = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hoveredLinkIndex = index),
                onExit: (_) => setState(() => _hoveredLinkIndex = -1),
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    link['title'] as String,
                    style: TextStyle(
                      color: _hoveredLinkIndex == index
                          ? Colors.white
                          : Colors.grey[400],
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Botão de rede social
  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required Function(bool)? onHover,
    required bool isHovered,
    required VoidCallback? onTap,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover?.call(true),
      onExit: (_) => onHover?.call(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isHovered
                ? color.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovered ? color : Colors.transparent,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isHovered ? color : Colors.grey[400],
            size: 20,
          ),
        ),
      ),
    );
  }
}

// Painter para linhas onduladas decorativas
class _WavyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Primeira linha ondulada
    final path1 = Path();
    path1.moveTo(0, height * 0.3);

    for (int i = 0; i < width.toInt(); i += 50) {
      path1.quadraticBezierTo(i + 25, height * 0.3 - 20, i + 50, height * 0.3);

      if (i + 50 < width.toInt()) {
        path1.quadraticBezierTo(
            i + 75, height * 0.3 + 20, i + 100, height * 0.3);
      }
    }

    canvas.drawPath(path1, paint);

    // Segunda linha ondulada
    paint.color = Colors.white.withValues(alpha: 0.02);
    final path2 = Path();
    path2.moveTo(0, height * 0.6);

    for (int i = 0; i < width.toInt(); i += 60) {
      path2.quadraticBezierTo(i + 30, height * 0.6 + 25, i + 60, height * 0.6);

      if (i + 60 < width.toInt()) {
        path2.quadraticBezierTo(
            i + 90, height * 0.6 - 25, i + 120, height * 0.6);
      }
    }

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

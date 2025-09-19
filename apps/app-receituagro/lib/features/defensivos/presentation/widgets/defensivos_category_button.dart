import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/design/design_tokens.dart';

/// Specialized category button for Defensivos statistics.
/// 
/// Features:
/// - Gradient background with shadow
/// - Icon and count display
/// - Touch feedback and accessibility
/// - Consistent styling across categories
/// 
/// Performance: Optimized with RepaintBoundary for complex decorations.
class DefensivosCategoryButton extends StatelessWidget {
  const DefensivosCategoryButton({
    super.key,
    required this.count,
    required this.title,
    required this.width,
    required this.onTap,
    this.icon,
    this.color,
  });

  final String count;
  final String title;
  final double width;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    
    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: ReceitaAgroDimensions.buttonHeight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.button),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    buttonColor.withValues(alpha: 0.7),
                    buttonColor.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.button),
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background decorative icon
                  Positioned(
                    right: -15,
                    bottom: -15,
                    child: FaIcon(
                      icon ?? FontAwesomeIcons.circle,
                      size: 70,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(ReceitaAgroSpacing.sm),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              icon ?? FontAwesomeIcons.circle,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                count,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 2.0,
                                color: theme.shadowColor.withValues(alpha: 0.3),
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Touch indicator
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Icon(
                      Icons.touch_app,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
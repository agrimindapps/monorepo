import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

/// Plant-themed branding sidebar for desktop
class PlantBrandingSide extends StatelessWidget {
  final Animation<double> logoAnimation;
  final Animation<double> backgroundAnimation;

  const PlantBrandingSide({
    required this.logoAnimation,
    required this.backgroundAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        bottomLeft: Radius.circular(24),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PlantisColors.primary,
              PlantisColors.primaryLight,
              Color(0xFF27AE60),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaleTransition(
                scale: logoAnimation,
                child: const ModernLogo(
                  isWhite: true,
                  size: 40,
                  color: PlantisColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Inside Garden',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Transforme seu lar em um jardim inteligente. Cuidado personalizado para cada planta.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: backgroundAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 +
                            (0.1 *
                                math.sin(
                                  backgroundAnimation.value * 2 * math.pi,
                                )),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 120,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.security_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Cuidado seguro e personalizado',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mobile branding with compact design
class MobileBranding extends StatelessWidget {
  final Animation<double> logoAnimation;
  final Color primaryColor;

  const MobileBranding({
    required this.logoAnimation,
    this.primaryColor = PlantisColors.primary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: logoAnimation,
      child: ModernLogo(
        isWhite: false,
        size: 32,
        color: primaryColor,
      ),
    );
  }
}

/// Compact branding for when keyboard is visible
class CompactBranding extends StatelessWidget {
  final Color primaryColor;

  const CompactBranding({
    this.primaryColor = PlantisColors.primary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withValues(alpha: 0.1),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(Icons.eco, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          'Inside Garden',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: primaryColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

/// Enhanced logo component
class ModernLogo extends StatelessWidget {
  final bool isWhite;
  final double size;
  final Color? color;

  const ModernLogo({
    required this.isWhite,
    required this.size,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = isWhite ? Colors.white : (color ?? PlantisColors.primary);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: logoColor.withValues(alpha: 0.1),
            border: Border.all(
              color: logoColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(Icons.eco, color: logoColor, size: size),
        ),
        const SizedBox(width: 12),
        Text(
          'Inside Garden',
          style: TextStyle(
            fontSize: size * 0.8,
            fontWeight: FontWeight.w700,
            color: logoColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

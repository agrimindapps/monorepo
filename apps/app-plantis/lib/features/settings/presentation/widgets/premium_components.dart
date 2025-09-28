import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/plantis_colors.dart';

/// Premium badge widget with plant-themed styling
class PremiumBadge extends StatelessWidget {
  final String text;
  final PremiumBadgeSize size;
  final bool animated;

  const PremiumBadge({
    super.key,
    this.text = 'PRO',
    this.size = PremiumBadgeSize.small,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = _getBadgeDimensions();

    Widget badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions.horizontalPadding,
        vertical: dimensions.verticalPadding,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PlantisColors.sun, PlantisColors.sunLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(dimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: PlantisColors.sun.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: dimensions.iconSize,
            color: Colors.white,
          ),
          SizedBox(width: dimensions.spacing),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: dimensions.fontSize,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
        ],
      ),
    );

    if (animated) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 2),
        tween: Tween(begin: 0.8, end: 1.2),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: badge,
          );
        },
      );
    }

    return badge;
  }

  _BadgeDimensions _getBadgeDimensions() {
    switch (size) {
      case PremiumBadgeSize.small:
        return const _BadgeDimensions(
          horizontalPadding: 6,
          verticalPadding: 2,
          borderRadius: 8,
          iconSize: 10,
          fontSize: 10,
          spacing: 2,
        );
      case PremiumBadgeSize.medium:
        return const _BadgeDimensions(
          horizontalPadding: 8,
          verticalPadding: 4,
          borderRadius: 10,
          iconSize: 14,
          fontSize: 12,
          spacing: 4,
        );
      case PremiumBadgeSize.large:
        return const _BadgeDimensions(
          horizontalPadding: 12,
          verticalPadding: 6,
          borderRadius: 12,
          iconSize: 16,
          fontSize: 14,
          spacing: 6,
        );
    }
  }
}

class _BadgeDimensions {
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final double iconSize;
  final double fontSize;
  final double spacing;

  const _BadgeDimensions({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
    required this.iconSize,
    required this.fontSize,
    required this.spacing,
  });
}

enum PremiumBadgeSize { small, medium, large }

/// Feature availability indicator with plant-themed icons
class FeatureAvailabilityIndicator extends StatelessWidget {
  final bool isAvailable;
  final bool isPremium;
  final String? tooltip;
  final VoidCallback? onTap;

  const FeatureAvailabilityIndicator({
    super.key,
    required this.isAvailable,
    required this.isPremium,
    this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget indicator = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          shape: BoxShape.circle,
          border: Border.all(
            color: _getBorderColor(),
            width: 2,
          ),
        ),
        child: Icon(
          _getIcon(),
          size: 12,
          color: _getIconColor(),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: indicator,
      );
    }

    return indicator;
  }

  Color _getBackgroundColor() {
    if (!isAvailable) {
      return Colors.grey.shade200;
    }
    if (isPremium) {
      return PlantisColors.sunLight;
    }
    return PlantisColors.leafLight;
  }

  Color _getBorderColor() {
    if (!isAvailable) {
      return Colors.grey.shade400;
    }
    if (isPremium) {
      return PlantisColors.sun;
    }
    return PlantisColors.leaf;
  }

  Color _getIconColor() {
    if (!isAvailable) {
      return Colors.grey.shade600;
    }
    if (isPremium) {
      return PlantisColors.sun;
    }
    return PlantisColors.leaf;
  }

  IconData _getIcon() {
    if (!isAvailable) {
      return Icons.close;
    }
    if (isPremium) {
      return Icons.star;
    }
    return Icons.eco; // Plant leaf icon for free features
  }
}

/// Upgrade prompt component with engaging plant-themed design
class UpgradePrompt extends StatefulWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onUpgrade;
  final VoidCallback? onDismiss;
  final List<String> features;
  final bool dismissible;

  const UpgradePrompt({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onUpgrade,
    this.onDismiss,
    this.features = const [],
    this.dismissible = true,
  });

  @override
  State<UpgradePrompt> createState() => _UpgradePromptState();
}

class _UpgradePromptState extends State<UpgradePrompt>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    PlantisColors.primary,
                    PlantisColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: PlantisColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with dismiss button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.dismissible && widget.onDismiss != null)
                        GestureDetector(
                          onTap: widget.onDismiss,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    widget.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  // Features list
                  if (widget.features.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...widget.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],

                  const SizedBox(height: 20),

                  // Upgrade button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onUpgrade();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: PlantisColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.star, size: 20),
                      label: Text(
                        widget.buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Plant-themed premium indicator with animated elements
class PlantThemedPremiumIndicator extends StatefulWidget {
  final bool isActive;
  final String label;
  final VoidCallback? onTap;

  const PlantThemedPremiumIndicator({
    super.key,
    required this.isActive,
    required this.label,
    this.onTap,
  });

  @override
  State<PlantThemedPremiumIndicator> createState() => _PlantThemedPremiumIndicatorState();
}

class _PlantThemedPremiumIndicatorState extends State<PlantThemedPremiumIndicator>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _rotateController;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    if (widget.isActive) {
      _glowController.repeat(reverse: true);
      _rotateController.repeat();
    }
  }

  @override
  void didUpdateWidget(PlantThemedPremiumIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _glowController.repeat(reverse: true);
        _rotateController.repeat();
      } else {
        _glowController.stop();
        _rotateController.stop();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: widget.isActive
              ? const LinearGradient(
                  colors: [PlantisColors.sun, PlantisColors.sunLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: widget.isActive ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isActive ? PlantisColors.sun : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: widget.isActive ? _rotateAnimation : const AlwaysStoppedAnimation(0),
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnimation.value * 2 * 3.14159,
                  child: AnimatedBuilder(
                    animation: widget.isActive ? _glowAnimation : const AlwaysStoppedAnimation(1),
                    builder: (context, child) {
                      return DecoratedBox(
                        decoration: widget.isActive
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: _glowAnimation.value * 0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              )
                            : const BoxDecoration(),
                        child: Icon(
                          Icons.eco,
                          size: 16,
                          color: widget.isActive ? Colors.white : Colors.grey.shade600,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.isActive ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
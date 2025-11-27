import 'package:flutter/material.dart';

import '../services/fitquest_constants.dart';

/// Widget de badge de nível
class LevelBadgeWidget extends StatelessWidget {
  const LevelBadgeWidget({
    super.key,
    required this.level,
    this.size = 64,
    this.showTitle = true,
    this.animated = true,
  });

  final int level;
  final double size;
  final bool showTitle;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final color = _getLevelColor(level);
    final emoji = _getLevelEmoji(level);
    final title = FitQuestConstants.levelTitles[level] ?? 'Iniciante';

    Widget badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color,
            color.withOpacity(0.9),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.08),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Emoji
          Text(
            emoji,
            style: TextStyle(fontSize: size * 0.4),
          ),
          // Level number
          Positioned(
            bottom: size * 0.08,
            right: size * 0.08,
            child: Container(
              padding: EdgeInsets.all(size * 0.06),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                '$level',
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (animated) {
      badge = _AnimatedBadge(child: badge);
    }

    if (!showTitle) return badge;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: size * 0.2,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getLevelColor(int level) {
    if (level <= 2) return Colors.green.shade600;
    if (level <= 4) return Colors.blue.shade600;
    if (level <= 6) return Colors.purple.shade600;
    if (level <= 8) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String _getLevelEmoji(int level) {
    switch (level) {
      case 1:
        return '🌱';
      case 2:
        return '📚';
      case 3:
        return '🏃';
      case 4:
        return '💪';
      case 5:
        return '⚔️';
      case 6:
        return '🏅';
      case 7:
        return '🎖️';
      case 8:
        return '👑';
      case 9:
        return '🏆';
      case 10:
        return '🌟';
      default:
        return '🌱';
    }
  }
}

class _AnimatedBadge extends StatefulWidget {
  const _AnimatedBadge({required this.child});

  final Widget child;

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Widget para animação de level up
class LevelUpAnimation extends StatefulWidget {
  const LevelUpAnimation({
    super.key,
    required this.oldLevel,
    required this.newLevel,
    required this.onComplete,
  });

  final int oldLevel;
  final int newLevel;
  final VoidCallback onComplete;

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await _fadeController.forward();
    await _scaleController.forward();
    await Future.delayed(const Duration(seconds: 2));
    await _fadeController.reverse();
    widget.onComplete();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 16),
                const Text(
                  'LEVEL UP!',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),
                LevelBadgeWidget(
                  level: widget.newLevel,
                  size: 100,
                  animated: false,
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.oldLevel} → ${widget.newLevel}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

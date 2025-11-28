import 'package:flutter/material.dart';

/// Displays lives (hearts) for Hardcore mode
class LivesDisplayWidget extends StatelessWidget {
  final int lives;
  final int maxLives;

  const LivesDisplayWidget({
    super.key,
    required this.lives,
    this.maxLives = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (index) {
        final isAlive = index < lives;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isAlive ? Icons.favorite : Icons.favorite_border,
              key: ValueKey('heart_${index}_$isAlive'),
              color: isAlive ? Colors.red : Colors.grey.shade400,
              size: 24,
            ),
          ),
        );
      }),
    );
  }
}

/// Compact lives display for the stats bar
class LivesStatWidget extends StatelessWidget {
  final int lives;
  final int maxLives;

  const LivesStatWidget({
    super.key,
    required this.lives,
    this.maxLives = 3,
  });

  @override
  Widget build(BuildContext context) {
    final color = lives <= 1 ? Colors.red : Colors.grey.shade700;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxLives, (index) {
            final isAlive = index < lives;
            return Icon(
              isAlive ? Icons.favorite : Icons.favorite_border,
              color: isAlive ? Colors.red : Colors.grey.shade300,
              size: 16,
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          'Vidas',
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Full hearts row with animation when losing a life
class AnimatedLivesWidget extends StatefulWidget {
  final int lives;
  final int maxLives;

  const AnimatedLivesWidget({
    super.key,
    required this.lives,
    this.maxLives = 3,
  });

  @override
  State<AnimatedLivesWidget> createState() => _AnimatedLivesWidgetState();
}

class _AnimatedLivesWidgetState extends State<AnimatedLivesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  int? _previousLives;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(AnimatedLivesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_previousLives != null && widget.lives < _previousLives!) {
      // Lost a life - shake animation
      _shakeController.forward().then((_) => _shakeController.reverse());
    }
    _previousLives = widget.lives;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: LivesDisplayWidget(
        lives: widget.lives,
        maxLives: widget.maxLives,
      ),
    );
  }
}

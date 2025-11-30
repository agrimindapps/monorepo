import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/gamification_provider.dart';

/// Widget de exibição de streak
class StreakWidget extends ConsumerWidget {
  const StreakWidget({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final theme = Theme.of(context);

    if (profile == null) return const SizedBox.shrink();

    final streak = profile.streakDays;
    final bestStreak = profile.bestStreak;
    final isOnFire = streak >= 3;

    if (compact) {
      return _buildCompactWidget(theme, streak, isOnFire);
    }

    return _buildFullWidget(theme, streak, bestStreak, isOnFire);
  }

  Widget _buildCompactWidget(ThemeData theme, int streak, bool isOnFire) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOnFire
              ? [Colors.orange.shade400, Colors.red.shade400]
              : [Colors.grey.shade300, Colors.grey.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isOnFire ? '🔥' : '📅',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidget(
    ThemeData theme,
    int streak,
    int bestStreak,
    bool isOnFire,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOnFire
              ? [
                  Colors.orange.shade300,
                  Colors.red.shade400,
                ]
              : [
                  Colors.grey.shade200,
                  Colors.grey.shade300,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isOnFire
            ? [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Fire animation
          _StreakFireAnimation(isOnFire: isOnFire, streak: streak),
          const SizedBox(width: 16),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnFire ? 'Você está pegando fogo! 🔥' : 'Mantenha a sequência!',
                  style: TextStyle(
                    color: isOnFire ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$streak dias',
                      style: TextStyle(
                        color: isOnFire ? Colors.white : Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (bestStreak > streak)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOnFire
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Recorde: $bestStreak',
                          style: TextStyle(
                            color: isOnFire ? Colors.white70 : Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakFireAnimation extends StatefulWidget {
  const _StreakFireAnimation({
    required this.isOnFire,
    required this.streak,
  });

  final bool isOnFire;
  final int streak;

  @override
  State<_StreakFireAnimation> createState() => _StreakFireAnimationState();
}

class _StreakFireAnimationState extends State<_StreakFireAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (widget.isOnFire) {
      _controller.repeat(reverse: true);
    }

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_StreakFireAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOnFire && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isOnFire && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isOnFire ? _scaleAnimation.value : 1.0,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.isOnFire
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.isOnFire ? '🔥' : '📅',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
        );
      },
    );
  }
}

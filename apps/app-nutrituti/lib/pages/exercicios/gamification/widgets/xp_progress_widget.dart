import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/gamification_provider.dart';
import '../services/fitquest_constants.dart';

/// Widget de barra de progresso de XP
class XpProgressWidget extends ConsumerWidget {
  const XpProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    if (profile == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final currentLevel = profile.currentLevel;
    final nextLevel = currentLevel < 10 ? currentLevel + 1 : 10;
    final progress = profile.levelProgressPercent;
    final currentXp = profile.currentLevelXp;
    final xpNeeded = profile.xpForNextLevel;

    // Get level colors
    final levelColor = _getLevelColor(currentLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: levelColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with level and title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          levelColor.withOpacity(0.8),
                          levelColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$currentLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FitQuestConstants.levelTitles[currentLevel] ??
                            'Iniciante',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Nível $currentLevel',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Total XP
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${profile.totalXp}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: levelColor,
                    ),
                  ),
                  Text(
                    'XP Total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    profile.isMaxLevel
                        ? 'Nível Máximo!'
                        : 'Próximo: Nível $nextLevel',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    profile.isMaxLevel
                        ? '🏆 MAX'
                        : '$currentXp / $xpNeeded XP',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: levelColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedXpBar(
                progress: progress,
                color: levelColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level <= 2) return Colors.green;
    if (level <= 4) return Colors.blue;
    if (level <= 6) return Colors.purple;
    if (level <= 8) return Colors.orange;
    return Colors.red;
  }
}

/// Barra de XP animada
class AnimatedXpBar extends StatefulWidget {
  const AnimatedXpBar({
    super.key,
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  State<AnimatedXpBar> createState() => _AnimatedXpBarState();
}

class _AnimatedXpBarState extends State<AnimatedXpBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedXpBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = oldWidget.progress;
      _animation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
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
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 12,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: _animation.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.8),
                        widget.color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

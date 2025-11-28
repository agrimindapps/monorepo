import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/achievement.dart';
import '../providers/achievement_provider.dart';

/// Dialog showing all Flappy Bird achievements organized by category
class FlappyAchievementsDialog extends ConsumerWidget {
  const FlappyAchievementsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(flappyAchievementsProvider);
    final stats = ref.watch(flappyAchievementStatsProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, stats),
            // Summary
            _buildSummary(stats),
            // Categories tabs
            Expanded(
              child: achievementsAsync.when(
                data: (achievements) => _buildTabs(context, achievements),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro: $e')),
              ),
            ),
            // Close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Fechar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FlappyAchievementStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.3),
            Colors.orange.withOpacity(0.2),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conquistas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${stats.unlocked}/${stats.total} desbloqueadas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Completion badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getCompletionColor(stats.completionPercent),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${stats.completionPercentInt}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(FlappyAchievementStats stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('XP Total', stats.totalXp.toString(), Icons.star),
          _buildStat(
            'Maior Raridade',
            stats.highestRarity?.label ?? '-',
            Icons.diamond,
            color: stats.highestRarity?.color,
          ),
          _buildStat(
              'Restantes', stats.remaining.toString(), Icons.lock_outline),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.amber, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(
      BuildContext context, List<FlappyAchievement> achievements) {
    return DefaultTabController(
      length: FlappyAchievementCategory.values.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.amber,
            tabs: FlappyAchievementCategory.values.map((cat) {
              final count = achievements
                  .where((a) => a.definition.category == cat && a.isUnlocked)
                  .length;
              final total =
                  FlappyAchievementDefinitions.getByCategory(cat).length;
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.emoji),
                    const SizedBox(width: 4),
                    Text('$count/$total'),
                  ],
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: FlappyAchievementCategory.values.map((cat) {
                final catAchievements = achievements
                    .where((a) => a.definition.category == cat)
                    .toList();
                return _buildCategoryList(catAchievements);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<FlappyAchievement> achievements) {
    // Sort: unlocked first, then by rarity
    achievements.sort((a, b) {
      if (a.isUnlocked != b.isUnlocked) {
        return a.isUnlocked ? -1 : 1;
      }
      return b.definition.rarity.index.compareTo(a.definition.rarity.index);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return FlappyAchievementCard(achievement: achievements[index]);
      },
    );
  }

  Color _getCompletionColor(double percent) {
    if (percent >= 1.0) return Colors.amber;
    if (percent >= 0.75) return Colors.green;
    if (percent >= 0.5) return Colors.blue;
    if (percent >= 0.25) return Colors.orange;
    return Colors.grey;
  }
}

/// Card showing a single Flappy Bird achievement
class FlappyAchievementCard extends StatelessWidget {
  final FlappyAchievement achievement;

  const FlappyAchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final def = achievement.definition;
    final isLocked = !achievement.isUnlocked;
    final isSecret = def.isSecret && isLocked;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey[850] : _getUnlockedColor(def.rarity),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isLocked ? Colors.grey[700]! : def.rarity.color.withOpacity(0.5),
          width: isLocked ? 1 : 2,
        ),
        boxShadow: !isLocked
            ? [
                BoxShadow(
                  color: def.rarity.color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Emoji or lock
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.grey[800]
                    : def.rarity.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: isSecret
                    ? const Text('❓', style: TextStyle(fontSize: 24))
                    : Text(
                        def.emoji,
                        style: TextStyle(
                          fontSize: 28,
                          color: isLocked ? Colors.grey : null,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isSecret ? '???' : def.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : Colors.white,
                          ),
                        ),
                      ),
                      // Rarity badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              def.rarity.color.withOpacity(isLocked ? 0.3 : 0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          def.rarity.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSecret ? 'Conquista secreta' : def.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLocked
                          ? Colors.grey[600]
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Progress bar or unlock date
                  if (isLocked && !isSecret)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: achievement.progressPercent,
                          backgroundColor: Colors.grey[800],
                          valueColor:
                              AlwaysStoppedAnimation(def.rarity.color),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${achievement.currentProgress}/${def.target}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    )
                  else if (!isLocked)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: def.rarity.color,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(achievement.unlockedAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '+${def.rarity.xpReward} XP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: def.rarity.color,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getUnlockedColor(FlappyAchievementRarity rarity) {
    return HSLColor.fromColor(rarity.color)
        .withLightness(0.15)
        .withSaturation(0.5)
        .toColor();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Dialog shown when Flappy Bird achievement is unlocked
class FlappyAchievementUnlockedDialog extends StatefulWidget {
  final FlappyAchievementDefinition achievement;

  const FlappyAchievementUnlockedDialog({
    super.key,
    required this.achievement,
  });

  @override
  State<FlappyAchievementUnlockedDialog> createState() =>
      _FlappyAchievementUnlockedDialogState();
}

class _FlappyAchievementUnlockedDialogState
    extends State<FlappyAchievementUnlockedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final def = widget.achievement;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                def.rarity.color.withOpacity(0.3),
                Colors.grey[900]!,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: def.rarity.color,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: def.rarity.color.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              // Title
              const Text(
                'CONQUISTA DESBLOQUEADA!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              // Achievement emoji
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: def.rarity.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: def.rarity.color, width: 3),
                ),
                child: Center(
                  child: Text(def.emoji, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 16),
              // Achievement title
              Text(
                def.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                def.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Rarity and XP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: def.rarity.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      def.rarity.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Text(
                      '+${def.rarity.xpReward} XP',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Close button
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: def.rarity.color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(150, 44),
                ),
                child: const Text('Incrível!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget showing multiple unlocked achievements in sequence
class FlappyAchievementsUnlockedOverlay extends StatefulWidget {
  final List<FlappyAchievementDefinition> achievements;
  final VoidCallback onComplete;

  const FlappyAchievementsUnlockedOverlay({
    super.key,
    required this.achievements,
    required this.onComplete,
  });

  @override
  State<FlappyAchievementsUnlockedOverlay> createState() =>
      _FlappyAchievementsUnlockedOverlayState();
}

class _FlappyAchievementsUnlockedOverlayState
    extends State<FlappyAchievementsUnlockedOverlay> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.achievements.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onComplete();
      });
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex++;
        });
      },
      child: FlappyAchievementUnlockedDialog(
        achievement: widget.achievements[_currentIndex],
      ),
    );
  }
}

/// Compact achievement badge for UI display
class FlappyAchievementBadge extends StatelessWidget {
  final FlappyAchievement achievement;
  final double size;

  const FlappyAchievementBadge({
    super.key,
    required this.achievement,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final def = achievement.definition;
    final isLocked = !achievement.isUnlocked;

    return Tooltip(
      message: isLocked ? 'Bloqueado' : def.title,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color:
              isLocked ? Colors.grey[800] : def.rarity.color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: isLocked ? Colors.grey[600]! : def.rarity.color,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            isLocked ? '🔒' : def.emoji,
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      ),
    );
  }
}

/// Progress indicator showing achievement completion
class FlappyAchievementsProgressIndicator extends ConsumerWidget {
  const FlappyAchievementsProgressIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionPercent =
        ref.watch(flappyAchievementsCompletionPercentProvider);
    final unlockedCount =
        ref.watch(flappyUnlockedAchievementsCountProvider);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => const FlappyAchievementsDialog(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              '$unlockedCount/${FlappyAchievementDefinitions.totalCount}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              child: LinearProgressIndicator(
                value: completionPercent / 100,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation(Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/water_achievement_entity.dart';
import '../providers/water_tracker_providers.dart';

/// Grid display of achievements with progress indicators
class AchievementsGrid extends ConsumerWidget {
  final bool showAll;
  final int? maxItems;

  const AchievementsGrid({
    super.key,
    this.showAll = true,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🏆 Conquistas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                achievementsAsync.maybeWhen(
                  data: (achievements) {
                    final unlocked = achievements.where((a) => a.isUnlocked).length;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unlocked/${achievements.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            achievementsAsync.when(
              data: (achievements) {
                var displayList = achievements;
                if (!showAll) {
                  displayList = achievements.where((a) => a.isUnlocked).toList();
                }
                if (maxItems != null) {
                  displayList = displayList.take(maxItems!).toList();
                }
                return _buildGrid(context, displayList);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Erro ao carregar conquistas'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<WaterAchievementEntity> achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _AchievementCard(achievement: achievements[index]);
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final WaterAchievementEntity achievement;

  const _AchievementCard({required this.achievement});

  String _getEmojiIcon() {
    switch (achievement.type) {
      case WaterAchievementType.firstDrop:
        return '💧';
      case WaterAchievementType.perfectWeek:
        return '🌊';
      case WaterAchievementType.hydratedMonth:
        return '🏆';
      case WaterAchievementType.earlyBird:
        return '🌅';
      case WaterAchievementType.superHydrated:
        return '💪';
      case WaterAchievementType.consistent:
        return '⭐';
      case WaterAchievementType.master:
        return '👑';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: () => _showAchievementDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : Colors.grey[300]!,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getEmojiIcon(),
                    style: TextStyle(
                      fontSize: 28,
                      color: isUnlocked ? null : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.title.replaceAll(RegExp(r'[^\w\s]+'), '').trim(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isUnlocked ? Colors.grey[800] : Colors.grey[500],
                    ),
                  ),
                  if (!isUnlocked && achievement.requiredValue != null) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: achievement.progressPercentage / 100,
                          backgroundColor: Colors.grey[300],
                          minHeight: 4,
                        ),
                      ),
                    ),
                    Text(
                      '${achievement.currentProgress}/${achievement.requiredValue}',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isUnlocked)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(_getEmojiIcon(), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                achievement.title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 16),
            if (achievement.isUnlocked) ...[
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Desbloqueado em ${_formatDate(achievement.unlockedAt!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ] else if (achievement.requiredValue != null) ...[
              LinearProgressIndicator(
                value: achievement.progressPercentage / 100,
              ),
              const SizedBox(height: 8),
              Text(
                'Progresso: ${achievement.currentProgress}/${achievement.requiredValue} (${achievement.progressPercentage.round()}%)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Faltam: ${achievement.remainingToUnlock}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

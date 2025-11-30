import 'package:flutter/material.dart';

import '../models/achievement_definition.dart';

/// Card de conquista para o sistema FitQuest
class AchievementCardWidget extends StatelessWidget {
  const AchievementCardWidget({
    super.key,
    required this.achievement,
    this.onTap,
    this.compact = false,
  });

  final AchievementWithProgress achievement;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final def = achievement.definition;
    final isUnlocked = achievement.isUnlocked;

    if (compact) {
      return _buildCompactCard(context, theme, def, isUnlocked);
    }

    return _buildFullCard(context, theme, def, isUnlocked);
  }

  Widget _buildCompactCard(
    BuildContext context,
    ThemeData theme,
    AchievementDefinition def,
    bool isUnlocked,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isUnlocked
              ? Colors.amber.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? Colors.amber.withValues(alpha: 0.5)
                : theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji with lock overlay
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  def.emoji,
                  style: TextStyle(
                    fontSize: 32,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
                if (!isUnlocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Progress indicator
            if (!isUnlocked)
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: achievement.progressPercent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard(
    BuildContext context,
    ThemeData theme,
    AchievementDefinition def,
    bool isUnlocked,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked
              ? Colors.amber.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? Colors.amber.withValues(alpha: 0.5)
                : theme.dividerColor.withValues(alpha: 0.2),
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Emoji badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.amber.withValues(alpha: 0.2)
                    : theme.dividerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    def.emoji,
                    style: TextStyle(
                      fontSize: 28,
                      color: isUnlocked ? null : Colors.grey,
                    ),
                  ),
                  if (!isUnlocked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    def.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    def.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (!isUnlocked) ...[
                    const SizedBox(height: 8),
                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: theme.dividerColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: achievement.progressPercent,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber.shade300,
                                      Colors.amber.shade600,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          achievement.progressText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ] else if (achievement.unlockedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Conquistado em ${_formatDate(achievement.unlockedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // XP reward
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.amber.withValues(alpha: 0.2)
                    : theme.dividerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt,
                    size: 16,
                    color: isUnlocked ? Colors.amber.shade700 : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${def.xpReward}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isUnlocked ? Colors.amber.shade700 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Lista de conquistas
class AchievementsList extends StatelessWidget {
  const AchievementsList({
    super.key,
    required this.achievements,
    this.title,
    this.emptyMessage = 'Nenhuma conquista',
    this.onAchievementTap,
  });

  final List<AchievementWithProgress> achievements;
  final String? title;
  final String emptyMessage;
  final void Function(AchievementWithProgress)? onAchievementTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (achievements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: achievements.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return AchievementCardWidget(
              achievement: achievement,
              onTap: onAchievementTap != null
                  ? () => onAchievementTap!(achievement)
                  : null,
            );
          },
        ),
      ],
    );
  }
}

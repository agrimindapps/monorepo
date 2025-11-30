import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/achievement_definition.dart';
import '../providers/gamification_provider.dart';
import '../widgets/index.dart';
import 'workout_session_page.dart';

/// Dashboard principal do FitQuest
class FitQuestDashboardPage extends ConsumerWidget {
  const FitQuestDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationState = ref.watch(gamificationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🎮'),
            const SizedBox(width: 8),
            const Text('FitQuest'),
          ],
        ),
        actions: [
          // Streak badge
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: StreakWidget(compact: true),
          ),
        ],
      ),
      body: gamificationState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(gamificationProvider),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
        data: (state) => _buildDashboard(context, ref, theme, state),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToWorkout(context),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Iniciar Treino'),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    GamificationState state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(gamificationProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level and XP Progress
            const XpProgressWidget(),
            const SizedBox(height: 16),

            // Streak
            const StreakWidget(),
            const SizedBox(height: 24),

            // Weekly Challenge
            _buildSectionTitle(theme, 'Desafio Semanal', Icons.flag),
            const SizedBox(height: 8),
            const WeeklyChallengeWidget(),
            const SizedBox(height: 24),

            // Stats Overview
            _buildSectionTitle(theme, 'Suas Estatísticas', Icons.bar_chart),
            const SizedBox(height: 8),
            _buildStatsGrid(context, theme, state),
            const SizedBox(height: 24),

            // Recent Achievements
            _buildSectionTitle(theme, 'Conquistas Recentes', Icons.emoji_events),
            const SizedBox(height: 8),
            _buildRecentAchievements(context, ref, theme, state),
            const SizedBox(height: 24),

            // Progress Achievements
            _buildSectionTitle(theme, 'Próximas Conquistas', Icons.trending_up),
            const SizedBox(height: 8),
            _buildProgressAchievements(context, theme, state),

            const SizedBox(height: 80), // FAB space
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    ThemeData theme,
    GamificationState state,
  ) {
    final stats = [
      _StatItem(
        icon: Icons.fitness_center,
        value: '${state.profile.totalWorkouts}',
        label: 'Treinos',
        color: Colors.blue,
      ),
      _StatItem(
        icon: Icons.timer,
        value: '${state.profile.totalMinutes}',
        label: 'Minutos',
        color: Colors.green,
      ),
      _StatItem(
        icon: Icons.local_fire_department,
        value: '${state.profile.totalCalories}',
        label: 'Calorias',
        color: Colors.orange,
      ),
      _StatItem(
        icon: Icons.category,
        value: '${state.profile.categoriesUsed.length}',
        label: 'Categorias',
        color: Colors.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: stat.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: stat.color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: stat.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat.icon, color: stat.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat.value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: stat.color,
                      ),
                    ),
                    Text(
                      stat.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentAchievements(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    GamificationState state,
  ) {
    final unlockedAchievements = ref.watch(unlockedAchievementsProvider);

    if (unlockedAchievements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma conquista ainda',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete treinos para desbloquear conquistas!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show up to 3 recent unlocked
    final recentUnlocked = unlockedAchievements.take(3).toList();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recentUnlocked.length + 1, // +1 for "see all"
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == recentUnlocked.length) {
            return GestureDetector(
              onTap: () => _showAllAchievements(context, state.achievements),
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.more_horiz,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ver todas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return AchievementCardWidget(
            achievement: recentUnlocked[index],
            compact: true,
          );
        },
      ),
    );
  }

  Widget _buildProgressAchievements(
    BuildContext context,
    ThemeData theme,
    GamificationState state,
  ) {
    final lockedAchievements = state.achievements
        .where((a) => !a.isUnlocked)
        .toList()
      ..sort((a, b) => b.progressPercent.compareTo(a.progressPercent));

    final nearestAchievements = lockedAchievements.take(3).toList();

    if (nearestAchievements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: const Column(
          children: [
            Text('🏆', style: TextStyle(fontSize: 48)),
            SizedBox(height: 8),
            Text(
              'Todas as conquistas desbloqueadas!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Column(
      children: nearestAchievements
          .map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AchievementCardWidget(achievement: a),
              ))
          .toList(),
    );
  }

  void _navigateToWorkout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WorkoutSessionPage()),
    );
  }

  void _showAllAchievements(
    BuildContext context,
    List<AchievementWithProgress> achievements,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Todas as Conquistas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AchievementsList(
                achievements: achievements,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}

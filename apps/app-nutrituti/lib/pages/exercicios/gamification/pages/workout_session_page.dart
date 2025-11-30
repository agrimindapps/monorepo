import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enums/exercicio_categoria.dart';
import '../providers/gamification_provider.dart';
import '../widgets/workout_timer_widget.dart';
import '../widgets/level_badge_widget.dart';

/// Página de sessão de treino FitQuest
class WorkoutSessionPage extends ConsumerStatefulWidget {
  const WorkoutSessionPage({super.key});

  @override
  ConsumerState<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends ConsumerState<WorkoutSessionPage> {
  String? _selectedExerciseType;
  ExercicioCategoria? _selectedCategoria;
  bool _showResults = false;

  @override
  Widget build(BuildContext context) {
    final gamificationState = ref.watch(gamificationProvider);
    final activeSession = ref.watch(activeSessionProvider);

    // Show level up animation
    final state = gamificationState.value;
    if (state?.didLevelUp == true && state?.oldLevel != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLevelUpDialog(context, state!.oldLevel!, state.profile.currentLevel);
        ref.read(gamificationProvider.notifier).clearNotifications();
      });
    }

    // Show newly unlocked achievements
    if ((state?.newlyUnlockedAchievements.isNotEmpty ?? false) && !_showResults) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAchievementsDialog(context, state!.newlyUnlockedAchievements);
        setState(() => _showResults = true);
      });
    }

    // Show XP gain
    if (state?.recentXpGain != null && activeSession == null && !_showResults) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showXpGainSnackbar(context, state!.recentXpGain!);
        ref.read(gamificationProvider.notifier).clearNotifications();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessão de Treino'),
        centerTitle: true,
        actions: [
          if (activeSession == null)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _showHistoryDialog(context),
            ),
        ],
      ),
      body: gamificationState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
        data: (state) {
          if (state.activeSession != null) {
            return _buildActiveSessionView(context);
          }
          return _buildSetupView(context);
        },
      ),
    );
  }

  Widget _buildSetupView(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise type input
          Text(
            'Tipo de Exercício',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Ex: Corrida, Musculação, Yoga...',
              prefixIcon: const Icon(Icons.fitness_center),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            onChanged: (value) => setState(() => _selectedExerciseType = value),
          ),
          const SizedBox(height: 24),

          // Category selection
          Text(
            'Categoria',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: ExercicioCategoria.values.length,
            itemBuilder: (context, index) {
              final categoria = ExercicioCategoria.values[index];
              final isSelected = _selectedCategoria == categoria;

              return GestureDetector(
                onTap: () => setState(() => _selectedCategoria = categoria),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? categoria.color.withValues(alpha: 0.15)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? categoria.color
                          : theme.dividerColor.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: categoria.color.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        categoria.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoria.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? categoria.color
                              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Calorie estimate
          if (_selectedCategoria != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedCategoria!.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: _selectedCategoria!.color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimativa de Calorias',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          '~${_selectedCategoria!.caloriasPorMinuto.toInt()} cal/min',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _selectedCategoria!.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),

          // Start button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _canStart ? _startWorkout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCategoria?.color ??
                    theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Iniciar Treino',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: const WorkoutTimerWidget(),
      ),
    );
  }

  bool get _canStart =>
      _selectedExerciseType != null &&
      _selectedExerciseType!.trim().isNotEmpty &&
      _selectedCategoria != null;

  void _startWorkout() {
    if (!_canStart) return;

    ref.read(gamificationProvider.notifier).startWorkoutSession(
          exerciseType: _selectedExerciseType!.trim(),
          categoria: _selectedCategoria!,
        );

    setState(() => _showResults = false);
  }

  void _showLevelUpDialog(BuildContext context, int oldLevel, int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: LevelUpAnimation(
          oldLevel: oldLevel,
          newLevel: newLevel,
          onComplete: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _showAchievementsDialog(BuildContext context, List achievements) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Text('Conquistas Desbloqueadas!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: achievements
              .map((a) => ListTile(
                    leading: Text(a.emoji, style: const TextStyle(fontSize: 24)),
                    title: Text(a.title),
                    subtitle: Text('+${a.xpReward} XP'),
                  ))
              .toList(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Incrível!'),
          ),
        ],
      ),
    );
  }

  void _showXpGainSnackbar(BuildContext context, int xp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.amber),
            const SizedBox(width: 8),
            Text('+$xp XP ganhos!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    // TODO: Implement workout history dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Histórico em desenvolvimento')),
    );
  }
}

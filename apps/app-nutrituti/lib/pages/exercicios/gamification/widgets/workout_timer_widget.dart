import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workout_session.dart';
import '../providers/gamification_provider.dart';

/// Widget de timer de treino interativo
class WorkoutTimerWidget extends ConsumerStatefulWidget {
  const WorkoutTimerWidget({super.key});

  @override
  ConsumerState<WorkoutTimerWidget> createState() => _WorkoutTimerWidgetState();
}

class _WorkoutTimerWidgetState extends ConsumerState<WorkoutTimerWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeSessionProvider);

    if (session == null || !session.isActive) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final duration = session.effectiveDuration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final calories = session.calculateCalories();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            session.categoria.color.withValues(alpha: 0.8),
            session.categoria.color,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: session.categoria.color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  session.categoria.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  session.exerciseType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Timer display with animation
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = session.isPaused
                  ? 1.0
                  : 1.0 + (_pulseController.value * 0.03);
              return Transform.scale(
                scale: scale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress circle
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: (minutes % 60) / 60,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    // Time display
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (session.isPaused)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'PAUSADO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.local_fire_department,
                value: calories.toString(),
                label: 'calorias',
              ),
              _buildStatItem(
                icon: Icons.timer,
                value: minutes.toString(),
                label: 'minutos',
              ),
              _buildStatItem(
                icon: Icons.bolt,
                value: _estimateXp(session).toString(),
                label: 'XP',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel button
              IconButton(
                onPressed: () => _showCancelDialog(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              const SizedBox(width: 16),

              // Play/Pause button
              GestureDetector(
                onTap: session.isPaused ? _resume : _pause,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    session.isPaused ? Icons.play_arrow : Icons.pause,
                    color: session.categoria.color,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Finish button
              IconButton(
                onPressed: () => _showFinishDialog(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
                icon: Icon(Icons.check, color: session.categoria.color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  int _estimateXp(WorkoutSession session) {
    final minutes = session.effectiveDuration.inMinutes;
    final calories = session.calculateCalories();
    final profile = ref.read(currentProfileProvider);
    final streakDays = profile?.streakDays ?? 0;
    return ref.read(gamificationServiceProvider).calculateXpForWorkout(
          durationMinutes: minutes,
          calories: calories,
          streakDays: streakDays,
        );
  }

  void _pause() {
    ref.read(gamificationProvider.notifier).pauseWorkout();
  }

  void _resume() {
    ref.read(gamificationProvider.notifier).resumeWorkout();
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Treino?'),
        content: const Text(
          'Seu progresso nesta sessão será perdido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(gamificationProvider.notifier).cancelWorkout();
    }
  }

  Future<void> _showFinishDialog(BuildContext context) async {
    final session = ref.read(activeSessionProvider);
    if (session == null) return;

    final minutes = session.effectiveDuration.inMinutes;

    if (minutes < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete pelo menos 1 minuto de treino!'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Treino?'),
        content: Text(
          'Você treinou por $minutes minutos.\n'
          'Calorias estimadas: ${session.calculateCalories()}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(gamificationProvider.notifier).finishWorkout();
    }
  }
}

import 'package:flutter/material.dart';

import '../../domain/entities/enums.dart';

/// Dialog for selecting game mode
class GameModeDialog extends StatelessWidget {
  final FlappyGameMode currentMode;
  final FlappyDifficulty currentDifficulty;
  final Function(FlappyGameMode mode) onModeSelected;
  final Function(FlappyDifficulty difficulty) onDifficultySelected;

  const GameModeDialog({
    super.key,
    required this.currentMode,
    required this.currentDifficulty,
    required this.onModeSelected,
    required this.onDifficultySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),
            const Divider(color: Colors.grey, height: 1),
            
            // Game Modes
            _buildSection('Modo de Jogo', _buildModeGrid(context)),
            const Divider(color: Colors.grey, height: 1),
            
            // Difficulty
            _buildSection('Dificuldade', _buildDifficultySelector(context)),
            
            // Play button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'JOGAR!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.purple.withOpacity(0.2),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Row(
        children: [
          Text('🎮', style: TextStyle(fontSize: 32)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Configurações de Jogo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildModeGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: FlappyGameMode.values.map((mode) {
        final isSelected = mode == currentMode;
        return _GameModeCard(
          mode: mode,
          isSelected: isSelected,
          onTap: () => onModeSelected(mode),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultySelector(BuildContext context) {
    return Row(
      children: FlappyDifficulty.values.map((difficulty) {
        final isSelected = difficulty == currentDifficulty;
        return Expanded(
          child: GestureDetector(
            onTap: () => onDifficultySelected(difficulty),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? _getDifficultyColor(difficulty)
                    : Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? _getDifficultyColor(difficulty)
                      : Colors.grey[600]!,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _getDifficultyEmoji(difficulty),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDifficultyName(difficulty),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getDifficultyColor(FlappyDifficulty difficulty) {
    switch (difficulty) {
      case FlappyDifficulty.easy:
        return Colors.green;
      case FlappyDifficulty.medium:
        return Colors.orange;
      case FlappyDifficulty.hard:
        return Colors.red;
    }
  }

  String _getDifficultyEmoji(FlappyDifficulty difficulty) {
    switch (difficulty) {
      case FlappyDifficulty.easy:
        return '🌱';
      case FlappyDifficulty.medium:
        return '🔥';
      case FlappyDifficulty.hard:
        return '💀';
    }
  }

  String _getDifficultyName(FlappyDifficulty difficulty) {
    switch (difficulty) {
      case FlappyDifficulty.easy:
        return 'Fácil';
      case FlappyDifficulty.medium:
        return 'Médio';
      case FlappyDifficulty.hard:
        return 'Difícil';
    }
  }
}

/// Card for game mode selection
class _GameModeCard extends StatelessWidget {
  final FlappyGameMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _GameModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? _getModeColor(mode).withOpacity(0.3) : Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _getModeColor(mode) : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _getModeColor(mode).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mode.emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                mode.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getModeColor(FlappyGameMode mode) {
    switch (mode) {
      case FlappyGameMode.classic:
        return Colors.blue;
      case FlappyGameMode.timeAttack:
        return Colors.orange;
      case FlappyGameMode.speedRun:
        return Colors.purple;
      case FlappyGameMode.nightMode:
        return Colors.indigo;
      case FlappyGameMode.hardcore:
        return Colors.red;
    }
  }
}

/// Game mode info card showing current mode details
class GameModeInfoCard extends StatelessWidget {
  final FlappyGameMode mode;
  final FlappyDifficulty difficulty;

  const GameModeInfoCard({
    super.key,
    required this.mode,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mode.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mode.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                _getDifficultyName(difficulty),
                style: TextStyle(
                  color: _getDifficultyColor(difficulty),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (mode == FlappyGameMode.timeAttack) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${mode.getTimeLimit(difficulty)}s',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getDifficultyColor(FlappyDifficulty difficulty) {
    switch (difficulty) {
      case FlappyDifficulty.easy:
        return Colors.green;
      case FlappyDifficulty.medium:
        return Colors.orange;
      case FlappyDifficulty.hard:
        return Colors.red;
    }
  }

  String _getDifficultyName(FlappyDifficulty difficulty) {
    switch (difficulty) {
      case FlappyDifficulty.easy:
        return 'Fácil';
      case FlappyDifficulty.medium:
        return 'Médio';
      case FlappyDifficulty.hard:
        return 'Difícil';
    }
  }
}

/// Timer display for Time Attack mode
class TimeAttackTimer extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const TimeAttackTimer({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final percent = remainingSeconds / totalSeconds;
    final color = percent > 0.5
        ? Colors.green
        : percent > 0.25
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            _formatTime(remainingSeconds),
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

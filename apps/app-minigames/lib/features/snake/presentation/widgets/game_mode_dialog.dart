// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Domain imports:
import '../../domain/entities/enums.dart';

/// Dialog for selecting game mode before starting
class GameModeDialog extends StatefulWidget {
  final SnakeGameMode currentMode;
  final SnakeDifficulty currentDifficulty;
  final Function(SnakeGameMode mode, SnakeDifficulty difficulty) onStart;

  const GameModeDialog({
    super.key,
    required this.currentMode,
    required this.currentDifficulty,
    required this.onStart,
  });

  @override
  State<GameModeDialog> createState() => _GameModeDialogState();
}

class _GameModeDialogState extends State<GameModeDialog> {
  late SnakeGameMode _selectedMode;
  late SnakeDifficulty _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentMode;
    _selectedDifficulty = widget.currentDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.greenAccent.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Center(
                  child: Text(
                    '🎮 NOVO JOGO',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Game Mode Selection
                const Text(
                  'MODO DE JOGO',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                ...SnakeGameMode.values.map((mode) => _buildModeOption(mode)),

                const SizedBox(height: 20),

                // Difficulty Selection
                const Text(
                  'DIFICULDADE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: SnakeDifficulty.values
                      .map((diff) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildDifficultyOption(diff),
                            ),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 24),

                // Start Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onStart(_selectedMode, _selectedDifficulty);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'INICIAR',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(
                      color: Colors.white54,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption(SnakeGameMode mode) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.greenAccent.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.greenAccent.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              mode.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    style: TextStyle(
                      color: isSelected ? Colors.greenAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    mode.description,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(SnakeDifficulty difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = difficulty),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? difficulty.color.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? difficulty.color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            difficulty.label,
            style: TextStyle(
              color: isSelected ? difficulty.color : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

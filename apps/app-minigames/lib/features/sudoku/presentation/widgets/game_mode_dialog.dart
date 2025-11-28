import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';

/// Dialog for selecting game mode and difficulty
class GameModeDialog extends StatefulWidget {
  final GameDifficulty initialDifficulty;
  final SudokuGameMode initialMode;
  final Function(GameDifficulty difficulty, SudokuGameMode mode) onStart;

  const GameModeDialog({
    super.key,
    this.initialDifficulty = GameDifficulty.medium,
    this.initialMode = SudokuGameMode.classic,
    required this.onStart,
  });

  @override
  State<GameModeDialog> createState() => _GameModeDialogState();
}

class _GameModeDialogState extends State<GameModeDialog> {
  late GameDifficulty _selectedDifficulty;
  late SudokuGameMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
    _selectedMode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              const Text(
                'Novo Jogo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Game Mode Section
              const Text(
                'Modo de Jogo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              // Mode Cards
              ...SudokuGameMode.values.map((mode) => _buildModeCard(mode)),

              const SizedBox(height: 24),

              // Difficulty Section
              const Text(
                'Dificuldade',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              // Difficulty Chips
              Wrap(
                spacing: 8,
                children: GameDifficulty.values
                    .map((diff) => _buildDifficultyChip(diff))
                    .toList(),
              ),

              const SizedBox(height: 24),

              // Mode Info
              _buildModeInfo(),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onStart(_selectedDifficulty, _selectedMode);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Iniciar Jogo',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(SudokuGameMode mode) {
    final isSelected = _selectedMode == mode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedMode = mode),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Emoji
              Text(
                mode.emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      mode.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Checkmark
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(GameDifficulty difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    return ChoiceChip(
      label: Text(difficulty.label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedDifficulty = difficulty),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildModeInfo() {
    String info = '';
    IconData icon = Icons.info_outline;
    Color color = Colors.blue;

    switch (_selectedMode) {
      case SudokuGameMode.classic:
        info = 'Jogue sem pressão. Sem limite de tempo.';
        icon = Icons.sports_score;
        color = Colors.green;
        break;
      case SudokuGameMode.timeAttack:
        final timeLimit = _selectedMode.getTimeLimit(_selectedDifficulty);
        final minutes = (timeLimit ?? 0) ~/ 60;
        info = 'Você terá $minutes minutos para completar!';
        icon = Icons.timer;
        color = Colors.orange;
        break;
      case SudokuGameMode.hardcore:
        info = 'Apenas 3 vidas! ${_selectedMode.maxMistakes} erros e game over.';
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case SudokuGameMode.zen:
        info = 'Relaxe. Sem timer, sem contagem de erros.';
        icon = Icons.spa;
        color = Colors.teal;
        break;
      case SudokuGameMode.speedRun:
        info = 'Complete ${_selectedMode.speedRunPuzzleCount} puzzles o mais rápido possível!';
        icon = Icons.speed;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              info,
              style: TextStyle(
                color: color.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on Color {
  Color get shade700 => HSLColor.fromColor(this).withLightness(0.3).toColor();
}

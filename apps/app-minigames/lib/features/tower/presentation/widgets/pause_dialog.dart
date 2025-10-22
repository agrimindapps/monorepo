import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';

/// Dialog shown when game is paused
class PauseDialog extends StatefulWidget {
  final int score;
  final int combo;
  final GameDifficulty currentDifficulty;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final Function(GameDifficulty) onDifficultyChanged;

  const PauseDialog({
    super.key,
    required this.score,
    required this.combo,
    required this.currentDifficulty,
    required this.onResume,
    required this.onRestart,
    required this.onDifficultyChanged,
  });

  @override
  State<PauseDialog> createState() => _PauseDialogState();
}

class _PauseDialogState extends State<PauseDialog> {
  late GameDifficulty _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.currentDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Jogo Pausado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Pontuação atual: ${widget.score}'),
          Text(
              'Combo atual: ${widget.combo > 1 ? widget.combo : "Nenhum"}'),
          const SizedBox(height: 10),
          DropdownButton<GameDifficulty>(
            value: _selectedDifficulty,
            items: GameDifficulty.values.map((difficulty) {
              return DropdownMenuItem(
                value: difficulty,
                child: Text(difficulty.label),
              );
            }).toList(),
            onChanged: (newDifficulty) {
              if (newDifficulty != null) {
                setState(() {
                  _selectedDifficulty = newDifficulty;
                });
                widget.onDifficultyChanged(newDifficulty);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onResume,
          child: const Text('Continuar'),
        ),
        TextButton(
          onPressed: widget.onRestart,
          child: const Text('Reiniciar'),
        ),
      ],
    );
  }
}

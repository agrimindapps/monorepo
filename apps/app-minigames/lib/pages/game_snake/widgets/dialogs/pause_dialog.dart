// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

/// Widget customizado para o diálogo de Pausa
/// 
/// Exibe pontuação atual, configurações de dificuldade e opções de controle do jogo
class PauseDialog extends StatefulWidget {
  final int score;
  final GameDifficulty difficulty;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final Function(GameDifficulty) onDifficultyChanged;

  const PauseDialog({
    super.key,
    required this.score,
    required this.difficulty,
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
    _selectedDifficulty = widget.difficulty;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.pause_circle_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Jogo Pausado'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreSection(context),
          const SizedBox(height: 24),
          _buildDifficultySection(context),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onRestart,
          child: const Text('Reiniciar'),
        ),
        FilledButton(
          onPressed: () {
            // Aplica mudança de dificuldade se houve alteração
            if (_selectedDifficulty != widget.difficulty) {
              widget.onDifficultyChanged(_selectedDifficulty);
            }
            widget.onResume();
          },
          child: const Text('Continuar'),
        ),
      ],
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pontuação atual',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            widget.score.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dificuldade',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<GameDifficulty>(
              value: _selectedDifficulty,
              isExpanded: true,
              items: GameDifficulty.values.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Row(
                    children: [
                      _getDifficultyIcon(difficulty),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            difficulty.label,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${difficulty.gameSpeed.inMilliseconds}ms',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDifficulty = newValue;
                  });
                }
              },
            ),
          ),
        ),
        if (_selectedDifficulty != widget.difficulty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'A nova dificuldade será aplicada quando continuar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _getDifficultyIcon(GameDifficulty difficulty) {
    IconData iconData;
    Color color;
    
    switch (difficulty) {
      case GameDifficulty.easy:
        iconData = Icons.sentiment_satisfied;
        color = Colors.green;
        break;
      case GameDifficulty.medium:
        iconData = Icons.sentiment_neutral;
        color = Colors.orange;
        break;
      case GameDifficulty.hard:
        iconData = Icons.sentiment_very_dissatisfied;
        color = Colors.red;
        break;
    }
    
    return Icon(iconData, color: color, size: 20);
  }
}

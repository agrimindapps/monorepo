import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';

class VictoryDialog extends StatelessWidget {
  final String time;
  final int moves;
  final int mistakes;
  final GameDifficulty difficulty;
  final bool isNewRecord;
  final VoidCallback onPlayAgain;
  final Function(GameDifficulty) onChangeDifficulty;

  const VictoryDialog({
    super.key,
    required this.time,
    required this.moves,
    required this.mistakes,
    required this.difficulty,
    required this.isNewRecord,
    required this.onPlayAgain,
    required this.onChangeDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
          const SizedBox(width: 8),
          const Text('Parabéns!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNewRecord)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    'Novo Recorde!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          if (isNewRecord) const SizedBox(height: 16),
          _buildStat('Dificuldade', difficulty.label),
          const SizedBox(height: 8),
          _buildStat('Tempo', time),
          const SizedBox(height: 8),
          _buildStat('Movimentos', moves.toString()),
          const SizedBox(height: 8),
          _buildStat('Erros', mistakes.toString()),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Fechar'),
        ),
        TextButton(
          onPressed: () => _showDifficultyPicker(context),
          child: const Text('Mudar Dificuldade'),
        ),
        ElevatedButton(
          onPressed: onPlayAgain,
          child: const Text('Jogar Novamente'),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showDifficultyPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Dificuldade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: GameDifficulty.values.map((diff) {
            return ListTile(
              title: Text(diff.label),
              subtitle: Text('${diff.cluesCount} pistas'),
              trailing: difficulty == diff
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.pop(context);
                onChangeDifficulty(diff);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

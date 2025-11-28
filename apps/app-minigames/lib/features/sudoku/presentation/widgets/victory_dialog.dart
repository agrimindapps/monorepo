import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/achievement.dart';

class VictoryDialog extends StatelessWidget {
  final String time;
  final int moves;
  final int mistakes;
  final GameDifficulty difficulty;
  final bool isNewRecord;
  final VoidCallback onPlayAgain;
  final Function(GameDifficulty) onChangeDifficulty;
  final List<SudokuAchievementDefinition> newAchievements;

  const VictoryDialog({
    super.key,
    required this.time,
    required this.moves,
    required this.mistakes,
    required this.difficulty,
    required this.isNewRecord,
    required this.onPlayAgain,
    required this.onChangeDifficulty,
    this.newAchievements = const [],
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
          // New achievements section
          if (newAchievements.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Conquistas Desbloqueadas! (${newAchievements.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...newAchievements.take(3).map((achievement) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(achievement.emoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    achievement.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '+${achievement.rarity.xpReward} XP',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: achievement.rarity.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (newAchievements.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '... e mais ${newAchievements.length - 3} conquista(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
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

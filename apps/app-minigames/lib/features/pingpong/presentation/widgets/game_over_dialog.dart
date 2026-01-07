import 'package:flutter/material.dart';
import '../../domain/entities/high_score_entity.dart';

class GameOverDialog extends StatelessWidget {
  final bool playerWon;
  final int finalScore;
  final Duration gameDuration;
  final HighScoreEntity? highScore;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const GameOverDialog({
    super.key,
    required this.playerWon,
    required this.finalScore,
    required this.gameDuration,
    this.highScore,
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  playerWon ? 'Você Venceu!' : 'Você Perdeu!',
                  style: TextStyle(
                    color: playerWon ? Colors.green : Colors.red,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                if (playerWon) ...[
                  Text(
                    'Pontuação: $finalScore',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tempo: ${gameDuration.inMinutes}:${(gameDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  if (highScore != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Novo Recorde!',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onExit,
                      icon: const Icon(Icons.home),
                      label: const Text('Sair'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: onPlayAgain,
                      icon: const Icon(Icons.replay),
                      label: const Text('Jogar Novamente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/pages/game_memory/constants/enums.dart';

/// Service responsável por gerenciar todos os diálogos do jogo da memória
///
/// Esta classe centraliza a lógica de exibição de diálogos, facilitando
/// manutenção e reutilização em outros jogos.
class DialogManager {
  /// Mostra o diálogo de fim de jogo com estatísticas e opções
  static Future<void> showGameOverDialog({
    required BuildContext context,
    required int elapsedTime,
    required int moves,
    required int score,
    required int bestScore,
    required bool isNewRecord,
    required VoidCallback onPlayAgain,
    required VoidCallback onExit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Parabéns!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Você completou o jogo!'),
            const SizedBox(height: 10),
            Text('Tempo: ${_formatTime(elapsedTime)}'),
            Text('Movimentos: $moves'),
            const SizedBox(height: 10),
            Text(
              'Pontuação: $score',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (isNewRecord)
              const Text(
                'Novo recorde!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onPlayAgain();
            },
            child: const Text('Jogar Novamente'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onExit();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  /// Mostra o diálogo de pausa com opções de configuração
  static Future<void> showPauseDialog({
    required BuildContext context,
    required int elapsedTime,
    required int moves,
    required GameDifficulty currentDifficulty,
    required Function(GameDifficulty) onDifficultyChanged,
    required VoidCallback onResume,
    required VoidCallback onRestart,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Jogo Pausado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tempo: ${_formatTime(elapsedTime)}'),
            Text('Movimentos: $moves'),
            const SizedBox(height: 20),
            const Text('Dificuldade:'),
            DropdownButton<GameDifficulty>(
              value: currentDifficulty,
              items: GameDifficulty.values.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.label),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null && newValue != currentDifficulty) {
                  onDifficultyChanged(newValue);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onResume();
            },
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRestart();
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  /// Mostra o diálogo de confirmação para mudança de dificuldade
  static Future<void> showDifficultyChangeDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mudar dificuldade'),
        content: const Text(
          'Mudar a dificuldade reiniciará o jogo. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  /// Formata o tempo em minutos e segundos
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Formata o tempo em minutos e segundos (método privado para uso interno)
  static String _formatTime(int seconds) => formatTime(seconds);
}

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/layout.dart';
import 'package:app_minigames/constants/strings.dart';

class VictoryDialog extends StatelessWidget {
  final GameDifficulty difficulty;
  final int wordsFound;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const VictoryDialog({
    super.key,
    required this.difficulty,
    required this.wordsFound,
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(GameStrings.victoryTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(GameStrings.victoryMessage),
          GameLayout.verticalSpacingLarge,
          Text(GameStrings.formatDifficulty(difficulty.label)),
          Text(GameStrings.formatWordsFound(wordsFound)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onPlayAgain();
          },
          child: const Text(GameStrings.playAgainButton),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onExit();
          },
          child: const Text(GameStrings.exitButton),
        ),
      ],
    );
  }

  /// Exibe o diálogo de vitória de forma segura
  static Future<void> show({
    required BuildContext context,
    required GameDifficulty difficulty,
    required int wordsFound,
    required VoidCallback onPlayAgain,
    required VoidCallback onExit,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    return Future.delayed(delay, () {
      if (context.mounted) {
        return showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => VictoryDialog(
            difficulty: difficulty,
            wordsFound: wordsFound,
            onPlayAgain: onPlayAgain,
            onExit: onExit,
          ),
        );
      }
    });
  }
}

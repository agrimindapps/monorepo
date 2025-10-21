// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/strings.dart';

class ConfirmDifficultyChangeDialog extends StatelessWidget {
  final GameDifficulty newDifficulty;
  final VoidCallback onConfirm;

  const ConfirmDifficultyChangeDialog({
    super.key,
    required this.newDifficulty,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(GameStrings.changeDifficultyTitle),
      content: const Text(GameStrings.changeDifficultyMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(GameStrings.cancelButton),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text(GameStrings.restartButton),
        ),
      ],
    );
  }

  /// Exibe o diálogo de confirmação para mudança de dificuldade
  static Future<void> show({
    required BuildContext context,
    required GameDifficulty newDifficulty,
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ConfirmDifficultyChangeDialog(
        newDifficulty: newDifficulty,
        onConfirm: onConfirm,
      ),
    );
  }
}

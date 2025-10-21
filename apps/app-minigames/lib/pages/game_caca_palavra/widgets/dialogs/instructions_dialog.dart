// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/layout.dart';
import 'package:app_minigames/constants/strings.dart';

class InstructionsDialog extends StatelessWidget {
  const InstructionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(GameStrings.instructionsTitle),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(GameStrings.instruction1),
            SizedBox(height: GameLayout.spacingMedium),
            Text(GameStrings.instruction2),
            SizedBox(height: GameLayout.spacingMedium),
            Text(GameStrings.instruction3),
            SizedBox(height: GameLayout.spacingMedium),
            Text(GameStrings.instruction4),
            SizedBox(height: GameLayout.spacingMedium),
            Text(GameStrings.instruction5),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(GameStrings.understoodButton),
        ),
      ],
    );
  }

  /// Exibe o diálogo de instruções
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const InstructionsDialog(),
    );
  }
}

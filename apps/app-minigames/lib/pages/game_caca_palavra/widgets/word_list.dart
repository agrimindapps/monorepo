// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/layout.dart';
import 'package:app_minigames/constants/strings.dart';
import 'package:app_minigames/models/word.dart';

class WordListWidget extends StatelessWidget {
  final List<Word> words;
  final Function(int index) onWordTap;

  const WordListWidget({
    super.key,
    required this.words,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameLayout.spacingMedium),
      decoration: GameLayout.wordListDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            GameStrings.wordsToFind,
            style: GameLayout.labelTextStyle,
          ),
          GameLayout.verticalSpacingMedium,
          Wrap(
            spacing: GameLayout.wordChipSpacing,
            runSpacing: GameLayout.wordChipSpacing,
            children: List.generate(words.length, (index) {
              return _WordChip(
                word: words[index],
                onTap: () => onWordTap(index),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final Word word;
  final VoidCallback onTap;

  const _WordChip({
    required this.word,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: GameLayout.wordChipPaddingHorizontal,
          vertical: GameLayout.wordChipPaddingVertical,
        ),
        decoration: GameLayout.wordChipDecoration(
          backgroundColor: _getBackgroundColor(),
          borderColor:
              word.isFound ? GameColors.foundWordText : Colors.grey.shade400,
        ),
        child: Text(
          word.text,
          style: TextStyle(
            color: _getTextColor(),
            fontWeight: word.isFound || word.isHighlighted
                ? FontWeight.bold
                : FontWeight.normal,
            decoration:
                word.isFound ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (word.isFound) {
      return GameColors.foundWord.withValues(alpha: 0.2);
    } else if (word.isHighlighted) {
      return GameColors.highlightedWord.withValues(alpha: 0.2);
    }
    return Colors.transparent;
  }

  Color _getTextColor() {
    if (word.isFound) {
      return GameColors.foundWordText;
    } else if (word.isHighlighted) {
      return GameColors.highlightedWord;
    }
    return GameColors.wordListText;
  }
}

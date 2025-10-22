import 'package:flutter/material.dart';
import '../../domain/entities/word_entity.dart';

/// Widget displaying the list of words to find
class WordListWidget extends StatelessWidget {
  final List<WordEntity> words;
  final Function(int index) onWordTap;

  const WordListWidget({
    super.key,
    required this.words,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Palavras para encontrar:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: words.length,
              itemBuilder: (context, index) {
                final word = words[index];
                return _WordListItem(
                  word: word,
                  onTap: () => onWordTap(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WordListItem extends StatelessWidget {
  final WordEntity word;
  final VoidCallback onTap;

  const _WordListItem({
    required this.word,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    TextDecoration? decoration;
    Color? backgroundColor;

    if (word.isFound) {
      textColor = Colors.green.shade700;
      decoration = TextDecoration.lineThrough;
      backgroundColor = Colors.green.shade50;
    } else if (word.isHighlighted) {
      textColor = Colors.blue.shade700;
      backgroundColor = Colors.blue.shade50;
    } else {
      textColor = Colors.black87;
    }

    return InkWell(
      onTap: word.isFound ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (word.isFound)
              Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 20,
              ),
            if (word.isFound) const SizedBox(width: 8),
            Text(
              word.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
                decoration: decoration,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

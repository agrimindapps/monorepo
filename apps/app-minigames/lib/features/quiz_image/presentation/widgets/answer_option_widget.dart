import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';

/// Widget for displaying a single answer option
/// Shows option letter, text, and state (unanswered/correct/incorrect)
class AnswerOptionWidget extends StatelessWidget {
  final String text;
  final int index;
  final AnswerState answerState;
  final bool isSelected;
  final bool isCorrectAnswer;
  final VoidCallback? onTap;

  const AnswerOptionWidget({
    super.key,
    required this.text,
    required this.index,
    required this.answerState,
    required this.isSelected,
    required this.isCorrectAnswer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnanswered = answerState == AnswerState.unanswered;
    final bool canTap = isUnanswered && onTap != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: InkWell(
        onTap: canTap ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Option letter (A, B, C, etc)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getBorderColor(),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, etc.
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getBorderColor(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Option text
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Icon (only for answered states)
              if (!isUnanswered && _shouldShowIcon())
                Icon(
                  _getIcon(),
                  color: _getIconColor(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (answerState == AnswerState.unanswered) {
      return Colors.white;
    }

    // Show correct answer in green
    if (isCorrectAnswer) {
      return Colors.green.shade100;
    }

    // Show selected incorrect answer in red
    if (isSelected && answerState == AnswerState.incorrect) {
      return Colors.red.shade100;
    }

    // Other options remain white
    return Colors.white;
  }

  Color _getBorderColor() {
    if (answerState == AnswerState.unanswered) {
      return Colors.blue.shade300;
    }

    // Correct answer
    if (isCorrectAnswer) {
      return Colors.green;
    }

    // Selected incorrect answer
    if (isSelected && answerState == AnswerState.incorrect) {
      return Colors.red;
    }

    // Other options
    return Colors.grey.shade300;
  }

  bool _shouldShowIcon() {
    return isCorrectAnswer || (isSelected && answerState == AnswerState.incorrect);
  }

  IconData _getIcon() {
    if (isCorrectAnswer) {
      return Icons.check_circle;
    }
    return Icons.cancel;
  }

  Color _getIconColor() {
    if (isCorrectAnswer) {
      return Colors.green;
    }
    return Colors.red;
  }
}

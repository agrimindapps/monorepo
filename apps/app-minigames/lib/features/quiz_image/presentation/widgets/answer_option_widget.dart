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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: canTap ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBorderColor(isDark),
              width: 2,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              if (isDark && (isCorrectAnswer || isSelected))
                BoxShadow(
                  color: _getBorderColor(isDark).withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Option letter (A, B, C, etc)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getLetterBackgroundColor(isDark),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getLetterBorderColor(isDark),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, etc.
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _getLetterTextColor(isDark),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Option text
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),

              // Icon (only for answered states)
              if (!isUnanswered && _shouldShowIcon())
                Icon(
                  _getIcon(),
                  color: _getIconColor(),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    if (answerState == AnswerState.unanswered) {
      return isDark 
          ? const Color(0xFF2A2D3E)
          : Colors.white;
    }

    // Show correct answer in green
    if (isCorrectAnswer) {
      return isDark
          ? Colors.green.withValues(alpha: 0.2)
          : Colors.green.shade100;
    }

    // Show selected incorrect answer in red
    if (isSelected && answerState == AnswerState.incorrect) {
      return isDark
          ? Colors.red.withValues(alpha: 0.2)
          : Colors.red.shade100;
    }

    // Other options remain default
    return isDark 
        ? const Color(0xFF2A2D3E)
        : Colors.white;
  }

  Color _getBorderColor(bool isDark) {
    if (answerState == AnswerState.unanswered) {
      return isDark
          ? const Color(0xFF3F51B5).withValues(alpha: 0.4)
          : Colors.blue.shade300;
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
    return isDark
        ? const Color(0xFF3E4152)
        : Colors.grey.shade300;
  }

  Color _getLetterBackgroundColor(bool isDark) {
    if (answerState == AnswerState.unanswered) {
      return isDark
          ? const Color(0xFF1A1D2E)
          : Colors.white;
    }
    
    if (isCorrectAnswer) {
      return Colors.green.withValues(alpha: isDark ? 0.3 : 0.2);
    }
    
    if (isSelected && answerState == AnswerState.incorrect) {
      return Colors.red.withValues(alpha: isDark ? 0.3 : 0.2);
    }
    
    return isDark
        ? const Color(0xFF1A1D2E)
        : Colors.white;
  }

  Color _getLetterBorderColor(bool isDark) {
    return _getBorderColor(isDark);
  }

  Color _getLetterTextColor(bool isDark) {
    if (answerState != AnswerState.unanswered) {
      if (isCorrectAnswer) return Colors.green;
      if (isSelected && answerState == AnswerState.incorrect) return Colors.red;
    }
    
    return isDark
        ? const Color(0xFF3F51B5)
        : Colors.blue.shade600;
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

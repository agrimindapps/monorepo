// Package imports:
import 'package:equatable/equatable.dart';

/// Entity representing a quiz question (text-based, no images)
class QuizQuestion extends Equatable {
  final int id;
  final String question; // Question text (description)
  final String correctAnswer; // Correct answer
  final List<String> options; // All answer options (always 4)

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.options,
  });

  /// Check if an answer is correct
  bool isCorrectAnswer(String answer) => answer == correctAnswer;

  /// Create a copy with modified fields
  QuizQuestion copyWith({
    int? id,
    String? question,
    String? correctAnswer,
    List<String>? options,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
    );
  }

  @override
  List<Object?> get props => [id, question, correctAnswer, options];
}

import 'package:equatable/equatable.dart';

/// Immutable entity representing a quiz question with an image
/// Contains question text, image URL, multiple choice options and correct answer
class QuizQuestion extends Equatable {
  final String id;
  final String question;
  final String imageUrl;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.imageUrl,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  /// Checks if the provided answer is correct
  bool isCorrect(String answer) => answer == correctAnswer;

  @override
  List<Object?> get props => [
        id,
        question,
        imageUrl,
        options,
        correctAnswer,
        explanation,
      ];
}

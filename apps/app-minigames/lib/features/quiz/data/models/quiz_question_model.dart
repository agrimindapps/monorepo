// Domain imports:
import '../../domain/entities/quiz_question.dart';

/// Model for QuizQuestion (extends entity, adds JSON serialization)
class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({
    required super.id,
    required super.question,
    required super.correctAnswer,
    required super.options,
  });

  /// Create from JSON
  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] as int,
      question: json['question'] as String,
      correctAnswer: json['correctAnswer'] as String,
      options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'correctAnswer': correctAnswer,
      'options': options,
    };
  }

  /// Create from entity
  factory QuizQuestionModel.fromEntity(QuizQuestion entity) {
    return QuizQuestionModel(
      id: entity.id,
      question: entity.question,
      correctAnswer: entity.correctAnswer,
      options: entity.options,
    );
  }
}

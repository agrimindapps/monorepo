import '../../domain/entities/quiz_question.dart';

/// Data model for QuizQuestion with JSON serialization
class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({
    required super.id,
    required super.question,
    required super.imageUrl,
    required super.options,
    required super.correctAnswer,
    super.explanation,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      imageUrl: json['imageUrl'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'imageUrl': imageUrl,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }

  factory QuizQuestionModel.fromEntity(QuizQuestion entity) {
    return QuizQuestionModel(
      id: entity.id,
      question: entity.question,
      imageUrl: entity.imageUrl,
      options: entity.options,
      correctAnswer: entity.correctAnswer,
      explanation: entity.explanation,
    );
  }
}

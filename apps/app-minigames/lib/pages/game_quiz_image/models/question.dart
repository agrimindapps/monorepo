// Project imports:
import 'package:app_minigames/constants/enums.dart';

// Modelo de uma pergunta do quiz
class QuizQuestion {
  final String id;
  final String question;
  final String imageUrl;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;

  // Estados adicionais
  AnswerState answerState = AnswerState.unanswered;
  int timeSpent = 0;
  String? selectedAnswer;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.imageUrl,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  // Construtor alternativo que aceita índice ao invés de resposta correta direta
  factory QuizQuestion.withIndex({
    required String imageUrl,
    required String question,
    required List<String> options,
    required int correctAnswerIndex,
    String? explanation,
  }) {
    return QuizQuestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: question,
      imageUrl: imageUrl,
      options: options,
      correctAnswer: options[correctAnswerIndex],
      explanation: explanation,
    );
  }

  // Construtor para criar a partir de um mapa (JSON)
  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String,
      question: map['question'] as String,
      imageUrl: map['imageUrl'] as String,
      options: List<String>.from(map['options'] as List),
      correctAnswer: map['correctAnswer'] as String,
      explanation: map['explanation'] as String?,
    );
  }

  // Método para converter para um mapa (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'imageUrl': imageUrl,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }

  // Verifica se a resposta fornecida está correta
  bool isCorrect(String answer) => answer == correctAnswer;

  // Cria uma cópia da questão com as opções embaralhadas
  QuizQuestion copyWithShuffledOptions() {
    final shuffledOptions = [...options]..shuffle();
    return QuizQuestion(
      id: id,
      question: question,
      imageUrl: imageUrl,
      options: shuffledOptions,
      correctAnswer: correctAnswer,
      explanation: explanation,
    );
  }

  // Seleciona uma resposta
  void selectAnswer(int index) {
    selectedAnswer = options[index];
    answerState = isCorrect(selectedAnswer!)
        ? AnswerState.correct
        : AnswerState.incorrect;
  }

  // Verifica se esta pergunta já foi respondida
  bool get isAnswered => answerState != AnswerState.unanswered;

  // Verifica se a resposta selecionada está correta
  bool get isSelectedCorrect => answerState == AnswerState.correct;
}

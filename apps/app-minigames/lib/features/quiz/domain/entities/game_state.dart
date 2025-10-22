// Package imports:
import 'package:equatable/equatable.dart';

// Domain imports:
import 'enums.dart';
import 'quiz_question.dart';

/// Entity representing the current state of the quiz game
class QuizGameState extends Equatable {
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final int score; // Sum of timeLeft from correct answers
  final int lives; // Starts at 3, -1 per error/timeout
  final int timeLeft; // Time remaining for current question
  final QuizGameStatus gameStatus;
  final AnswerState currentAnswerState; // none/correct/incorrect
  final QuizDifficulty difficulty;

  const QuizGameState({
    required this.questions,
    required this.currentQuestionIndex,
    required this.score,
    required this.lives,
    required this.timeLeft,
    required this.gameStatus,
    required this.currentAnswerState,
    required this.difficulty,
  });

  /// Initial state (loading)
  factory QuizGameState.initial({
    QuizDifficulty difficulty = QuizDifficulty.medium,
  }) {
    return QuizGameState(
      questions: const [],
      currentQuestionIndex: 0,
      score: 0,
      lives: 3,
      timeLeft: difficulty.timeInSeconds,
      gameStatus: QuizGameStatus.loading,
      currentAnswerState: AnswerState.none,
      difficulty: difficulty,
    );
  }

  /// Get current question
  QuizQuestion? get currentQuestion {
    if (currentQuestionIndex >= 0 && currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  /// Check if there are more questions
  bool get hasMoreQuestions => currentQuestionIndex < questions.length - 1;

  /// Check if game is over (no lives or no more questions)
  bool get isOver => lives <= 0 || (!hasMoreQuestions && currentAnswerState != AnswerState.none);

  /// Total number of questions
  int get totalQuestions => questions.length;

  /// Progress (0.0 to 1.0)
  double get progress {
    if (questions.isEmpty) return 0.0;
    return (currentQuestionIndex + 1) / questions.length;
  }

  /// Create a copy with modified fields
  QuizGameState copyWith({
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    int? score,
    int? lives,
    int? timeLeft,
    QuizGameStatus? gameStatus,
    AnswerState? currentAnswerState,
    QuizDifficulty? difficulty,
  }) {
    return QuizGameState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      timeLeft: timeLeft ?? this.timeLeft,
      gameStatus: gameStatus ?? this.gameStatus,
      currentAnswerState: currentAnswerState ?? this.currentAnswerState,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  List<Object?> get props => [
        questions,
        currentQuestionIndex,
        score,
        lives,
        timeLeft,
        gameStatus,
        currentAnswerState,
        difficulty,
      ];
}

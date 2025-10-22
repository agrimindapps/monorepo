import 'package:equatable/equatable.dart';
import 'quiz_question.dart';
import 'enums.dart';

/// Immutable entity representing the complete state of the quiz game
/// Contains questions, progress, score, timer state, and answer state
class QuizGameState extends Equatable {
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final int timeLeft;
  final int correctAnswers;
  final GameStateEnum gameState;
  final GameDifficulty difficulty;
  final String? currentSelectedAnswer;
  final AnswerState currentAnswerState;

  const QuizGameState({
    required this.questions,
    required this.currentQuestionIndex,
    required this.timeLeft,
    required this.correctAnswers,
    required this.gameState,
    required this.difficulty,
    this.currentSelectedAnswer,
    required this.currentAnswerState,
  });

  /// Factory constructor for initial game state
  factory QuizGameState.initial(GameDifficulty difficulty) {
    return QuizGameState(
      questions: const [],
      currentQuestionIndex: 0,
      timeLeft: difficulty.timeLimit,
      correctAnswers: 0,
      gameState: GameStateEnum.ready,
      difficulty: difficulty,
      currentSelectedAnswer: null,
      currentAnswerState: AnswerState.unanswered,
    );
  }

  // Helper computed properties (NOT business logic)

  /// Returns the current question being displayed
  QuizQuestion get currentQuestion => questions[currentQuestionIndex];

  /// Returns progress as a value between 0.0 and 1.0
  double get progress => (currentQuestionIndex + 1) / questions.length;

  /// Returns score as percentage (0-100)
  double get scorePercentage => correctAnswers / questions.length * 100;

  /// Checks if this is the last question
  bool get isLastQuestion => currentQuestionIndex >= questions.length - 1;

  /// Checks if game is in progress
  bool get isPlaying => gameState == GameStateEnum.playing;

  /// Checks if game is over
  bool get isGameOver => gameState == GameStateEnum.gameOver;

  /// Checks if current question has been answered
  bool get hasAnswered => currentAnswerState != AnswerState.unanswered;

  /// Creates a copy of this game state with updated fields
  QuizGameState copyWith({
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    int? timeLeft,
    int? correctAnswers,
    GameStateEnum? gameState,
    GameDifficulty? difficulty,
    String? currentSelectedAnswer,
    AnswerState? currentAnswerState,
  }) {
    return QuizGameState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      timeLeft: timeLeft ?? this.timeLeft,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      gameState: gameState ?? this.gameState,
      difficulty: difficulty ?? this.difficulty,
      currentSelectedAnswer: currentSelectedAnswer ?? this.currentSelectedAnswer,
      currentAnswerState: currentAnswerState ?? this.currentAnswerState,
    );
  }

  @override
  List<Object?> get props => [
        questions,
        currentQuestionIndex,
        timeLeft,
        correctAnswers,
        gameState,
        difficulty,
        currentSelectedAnswer,
        currentAnswerState,
      ];
}

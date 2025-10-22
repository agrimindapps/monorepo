import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/usecases/generate_game_questions_usecase.dart';
import '../../domain/usecases/start_game_usecase.dart';
import '../../domain/usecases/select_answer_usecase.dart';
import '../../domain/usecases/handle_timeout_usecase.dart';
import '../../domain/usecases/next_question_usecase.dart';
import '../../domain/usecases/update_timer_usecase.dart';
import '../../domain/usecases/restart_game_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';

part 'quiz_image_notifier.g.dart';

/// Riverpod notifier for Quiz Image game state management
/// Handles game flow, timer, answer selection, and high scores
@riverpod
class QuizImageNotifier extends _$QuizImageNotifier {
  // Use cases
  late final GenerateGameQuestionsUseCase _generateQuestionsUseCase;
  late final StartGameUseCase _startGameUseCase;
  late final SelectAnswerUseCase _selectAnswerUseCase;
  late final HandleTimeoutUseCase _handleTimeoutUseCase;
  late final NextQuestionUseCase _nextQuestionUseCase;
  late final UpdateTimerUseCase _updateTimerUseCase;
  late final RestartGameUseCase _restartGameUseCase;
  late final LoadHighScoreUseCase _loadHighScoreUseCase;
  late final SaveHighScoreUseCase _saveHighScoreUseCase;

  // Timer for countdown
  Timer? _timer;

  // High score tracking
  int _highScore = 0;

  @override
  Future<QuizGameState> build(GameDifficulty difficulty) async {
    // Inject use cases from GetIt
    _generateQuestionsUseCase = getIt<GenerateGameQuestionsUseCase>();
    _startGameUseCase = getIt<StartGameUseCase>();
    _selectAnswerUseCase = getIt<SelectAnswerUseCase>();
    _handleTimeoutUseCase = getIt<HandleTimeoutUseCase>();
    _nextQuestionUseCase = getIt<NextQuestionUseCase>();
    _updateTimerUseCase = getIt<UpdateTimerUseCase>();
    _restartGameUseCase = getIt<RestartGameUseCase>();
    _loadHighScoreUseCase = getIt<LoadHighScoreUseCase>();
    _saveHighScoreUseCase = getIt<SaveHighScoreUseCase>();

    // Cleanup on dispose
    ref.onDispose(() {
      _timer?.cancel();
    });

    // Load high score
    final highScoreResult = await _loadHighScoreUseCase();
    highScoreResult.fold(
      (failure) => _highScore = 0,
      (highScore) => _highScore = highScore.score,
    );

    // Generate questions
    final questionsResult = _generateQuestionsUseCase(difficulty);

    return questionsResult.fold(
      (failure) => throw failure,
      (questions) => QuizGameState.initial(difficulty).copyWith(
        questions: questions,
      ),
    );
  }

  /// Starts the quiz game
  void startGame() {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final startResult = _startGameUseCase(currentState);

    startResult.fold(
      (failure) {
        // Cannot start game - ignore
      },
      (newState) {
        state = AsyncValue.data(newState);
        _startTimer();
      },
    );
  }

  /// Starts the countdown timer (1 second intervals)
  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final currentState = state.valueOrNull;
      if (currentState == null || !currentState.isPlaying) {
        return;
      }

      // Update timer
      final updateResult = _updateTimerUseCase(currentState);

      updateResult.fold(
        (failure) {
          // Timer update failed - ignore
        },
        (newState) {
          state = AsyncValue.data(newState);

          // Check if time has run out
          if (newState.timeLeft <= 0 &&
              newState.currentAnswerState == AnswerState.unanswered) {
            _handleTimeout();
          }
        },
      );
    });
  }

  /// Handles timeout for current question
  void _handleTimeout() {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final timeoutResult = _handleTimeoutUseCase(currentState);

    timeoutResult.fold(
      (failure) {
        // Timeout handling failed - ignore
      },
      (newState) {
        state = AsyncValue.data(newState);

        // Wait 2 seconds before advancing
        Future.delayed(const Duration(seconds: 2), _nextQuestion);
      },
    );
  }

  /// Selects an answer for the current question
  Future<void> selectAnswer(String answer) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final selectResult = _selectAnswerUseCase(
      currentState: currentState,
      selectedAnswer: answer,
    );

    selectResult.fold(
      (failure) {
        // Selection failed - ignore (already answered or invalid)
      },
      (newState) {
        state = AsyncValue.data(newState);

        // Wait 2 seconds before advancing to next question
        Future.delayed(const Duration(seconds: 2), _nextQuestion);
      },
    );
  }

  /// Advances to next question or ends game
  void _nextQuestion() {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final nextResult = _nextQuestionUseCase(currentState);

    nextResult.fold(
      (failure) {
        // Next question failed - ignore
      },
      (newState) {
        state = AsyncValue.data(newState);

        if (newState.isGameOver) {
          _endGame();
        } else {
          // Continue timer for next question
          _startTimer();
        }
      },
    );
  }

  /// Ends the game and saves high score if needed
  Future<void> _endGame() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    _timer?.cancel();

    // Save high score if current score is higher
    final score = currentState.scorePercentage.round();
    if (score > _highScore) {
      final saveResult = await _saveHighScoreUseCase(score);
      saveResult.fold(
        (failure) {
          // Save failed - ignore
        },
        (_) {
          _highScore = score;
        },
      );
    }
  }

  /// Restarts the game with same difficulty
  void restartGame() {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    _timer?.cancel();

    final restartResult = _restartGameUseCase(
      difficulty: currentState.difficulty,
    );

    restartResult.fold(
      (failure) {
        // Restart failed - ignore
      },
      (newState) {
        // Generate new questions
        final questionsResult = _generateQuestionsUseCase(newState.difficulty);

        questionsResult.fold(
          (failure) {
            // Failed to generate questions - keep current state
          },
          (questions) {
            state = AsyncValue.data(newState.copyWith(questions: questions));
          },
        );
      },
    );
  }

  /// Exposes high score
  int get highScore => _highScore;
}

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Core imports:

// Domain imports:
import '../../domain/entities/game_state.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/generate_game_questions_usecase.dart';
import '../../domain/usecases/select_answer_usecase.dart';
import '../../domain/usecases/handle_timeout_usecase.dart';
import '../../domain/usecases/next_question_usecase.dart';
import '../../domain/usecases/update_timer_usecase.dart';
import '../../domain/usecases/start_game_usecase.dart';
import '../../domain/usecases/restart_game_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import 'quiz_providers.dart';

part 'quiz_game_notifier.g.dart';

@riverpod
class QuizGameNotifier extends _$QuizGameNotifier {
  // Use cases injected via GetIt
  late final GenerateGameQuestionsUseCase _generateGameQuestionsUseCase;
  late final SelectAnswerUseCase _selectAnswerUseCase;
  late final HandleTimeoutUseCase _handleTimeoutUseCase;
  late final NextQuestionUseCase _nextQuestionUseCase;
  late final UpdateTimerUseCase _updateTimerUseCase;
  late final StartGameUseCase _startGameUseCase;
  late final RestartGameUseCase _restartGameUseCase;
  late final LoadHighScoreUseCase _loadHighScoreUseCase;
  late final SaveHighScoreUseCase _saveHighScoreUseCase;

  // Timer for countdown
  Timer? _timer;

  // High score (cached)
  int _highScore = 0;

  // Mounted flag for race condition protection
  bool _isMounted = true;

  @override
  FutureOr<QuizGameState> build() async {
    // Inject use cases
    _generateGameQuestionsUseCase = ref.read(GenerateGameQuestionsUseCase>();
    _selectAnswerUseCase = ref.read(SelectAnswerUseCase>();
    _handleTimeoutUseCase = ref.read(HandleTimeoutUseCase>();
    _nextQuestionUseCase = ref.read(NextQuestionUseCase>();
    _updateTimerUseCase = ref.read(UpdateTimerUseCase>();
    _startGameUseCase = ref.read(StartGameUseCase>();
    _restartGameUseCase = ref.read(RestartGameUseCase>();
    _loadHighScoreUseCase = ref.read(LoadHighScoreUseCase>();
    _saveHighScoreUseCase = ref.read(SaveHighScoreUseCase>();

    // Cleanup on dispose
    ref.onDispose(() {
      _isMounted = false;
      _timer?.cancel();
    });

    // Load high score
    await _loadHighScore();

    // Start game automatically
    await _startNewGame();

    return state.requireValue;
  }

  /// Get current high score
  int get highScore => _highScore;

  /// Load high score
  Future<void> _loadHighScore() async {
    final result = await _loadHighScoreUseCase();
    result.fold(
      (failure) => _highScore = 0,
      (highScore) => _highScore = highScore.score,
    );
  }

  /// Save high score if current score is higher
  Future<void> _saveHighScore() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    if (currentState.score > _highScore) {
      final result = await _saveHighScoreUseCase(score: currentState.score);
      result.fold(
        (failure) {}, // Ignore failure
        (_) => _highScore = currentState.score,
      );
    }
  }

  /// Start a new game
  Future<void> _startNewGame() async {
    if (!_isMounted) return;

    // Cancel any existing timer
    _timer?.cancel();

    // Generate questions
    final questionsResult = await _generateGameQuestionsUseCase();
    if (!_isMounted) return;

    await questionsResult.fold(
      (failure) async {
        if (!_isMounted) return;
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (questions) async {
        if (!_isMounted) return;

        // Start game with questions
        final result = await _startGameUseCase(
          questions: questions,
          difficulty: state.valueOrNull?.difficulty ?? QuizDifficulty.medium,
        );
        if (!_isMounted) return;

        result.fold(
          (failure) {
            if (!_isMounted) return;
            state = AsyncValue.error(failure, StackTrace.current);
          },
          (newState) {
            if (!_isMounted) return;
            state = AsyncValue.data(newState);
            _startTimer();
          },
        );
      },
    );
  }

  /// Start countdown timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_isMounted) return;

      final currentState = state.valueOrNull;
      if (currentState == null || !currentState.gameStatus.isPlaying) {
        _timer?.cancel();
        return;
      }

      // Update timer
      final result = await _updateTimerUseCase(currentState: currentState);
      if (!_isMounted) return;

      result.fold(
        (failure) {}, // Ignore
        (newState) {
          if (!_isMounted) return;
          state = AsyncValue.data(newState);

          // Check timeout
          if (newState.timeLeft <= 0) {
            _handleTimeout();
          }
        },
      );
    });
  }

  /// Select an answer
  Future<void> selectAnswer(String answer) async {
    if (!_isMounted) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Cancel timer
    _timer?.cancel();

    // Process answer
    final result = await _selectAnswerUseCase(
      currentState: currentState,
      selectedAnswer: answer,
    );
    if (!_isMounted) return;

    result.fold(
      (failure) {
        if (!_isMounted) return;
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (newState) async {
        if (!_isMounted) return;
        state = AsyncValue.data(newState);

        // Wait 2 seconds before advancing
        await Future.delayed(const Duration(seconds: 2));
        if (!_isMounted) return;

        // Check if game is over
        if (newState.isOver) {
          _handleGameOver();
        } else {
          _advanceToNextQuestion();
        }
      },
    );
  }

  /// Handle timeout
  Future<void> _handleTimeout() async {
    if (!_isMounted) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    _timer?.cancel();

    final result = await _handleTimeoutUseCase(currentState: currentState);
    if (!_isMounted) return;

    result.fold(
      (failure) {
        if (!_isMounted) return;
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (newState) async {
        if (!_isMounted) return;
        state = AsyncValue.data(newState);

        // Wait 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (!_isMounted) return;

        // Check if game is over
        if (newState.isOver) {
          _handleGameOver();
        } else {
          _advanceToNextQuestion();
        }
      },
    );
  }

  /// Advance to next question
  Future<void> _advanceToNextQuestion() async {
    if (!_isMounted) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final result = await _nextQuestionUseCase(currentState: currentState);
    if (!_isMounted) return;

    result.fold(
      (failure) {
        if (!_isMounted) return;
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (newState) {
        if (!_isMounted) return;
        state = AsyncValue.data(newState);

        if (!newState.gameStatus.isGameOver) {
          _startTimer();
        } else {
          _handleGameOver();
        }
      },
    );
  }

  /// Handle game over
  Future<void> _handleGameOver() async {
    _timer?.cancel();
    await _saveHighScore();
  }

  /// Restart game
  Future<void> restartGame() async {
    if (!_isMounted) return;

    _timer?.cancel();

    final result = await _restartGameUseCase(
      difficulty: state.valueOrNull?.difficulty ?? QuizDifficulty.medium,
    );
    if (!_isMounted) return;

    result.fold(
      (failure) {
        if (!_isMounted) return;
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (newState) async {
        if (!_isMounted) return;
        state = AsyncValue.data(newState);
        await _startNewGame();
      },
    );
  }

  /// Change difficulty
  Future<void> changeDifficulty(QuizDifficulty newDifficulty) async {
    if (!_isMounted) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    if (currentState.difficulty != newDifficulty) {
      _timer?.cancel();

      final result = await _restartGameUseCase(difficulty: newDifficulty);
      if (!_isMounted) return;

      result.fold(
        (failure) {
          if (!_isMounted) return;
          state = AsyncValue.error(failure, StackTrace.current);
        },
        (newState) async {
          if (!_isMounted) return;
          state = AsyncValue.data(newState);
          await _startNewGame();
        },
      );
    }
  }

}

import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../domain/entities/high_score_entity.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/start_game_usecase.dart';
import '../../domain/usecases/update_ball_usecase.dart';
import '../../domain/usecases/update_player_paddle_usecase.dart';
import '../../domain/usecases/update_ai_paddle_usecase.dart';
import '../../domain/usecases/check_collision_usecase.dart';
import '../../domain/usecases/check_score_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';

part 'pingpong_notifier.g.dart';

@riverpod
class PingpongGame extends _$PingpongGame {
  Timer? _gameLoop;
  bool _isMounted = true;
  late StartGameUseCase _startGameUseCase;
  late UpdateBallUseCase _updateBallUseCase;
  late UpdatePlayerPaddleUseCase _updatePlayerPaddleUseCase;
  late UpdateAiPaddleUseCase _updateAiPaddleUseCase;
  late CheckCollisionUseCase _checkCollisionUseCase;
  late CheckScoreUseCase _checkScoreUseCase;
  late LoadHighScoreUseCase _loadHighScoreUseCase;
  late SaveHighScoreUseCase _saveHighScoreUseCase;

  @override
  GameStateEntity build() {
    _initializeUseCases();
    ref.onDispose(() {
      _isMounted = false;
      _gameLoop?.cancel();
    });
    _loadHighScore(GameDifficulty.medium);
    return GameStateEntity.initial();
  }

  void _initializeUseCases() {
    _startGameUseCase = GetIt.I<StartGameUseCase>();
    _updateBallUseCase = GetIt.I<UpdateBallUseCase>();
    _updatePlayerPaddleUseCase = GetIt.I<UpdatePlayerPaddleUseCase>();
    _updateAiPaddleUseCase = GetIt.I<UpdateAiPaddleUseCase>();
    _checkCollisionUseCase = GetIt.I<CheckCollisionUseCase>();
    _checkScoreUseCase = GetIt.I<CheckScoreUseCase>();
  }

  void setUseCases({
    required LoadHighScoreUseCase loadHighScoreUseCase,
    required SaveHighScoreUseCase saveHighScoreUseCase,
  }) {
    _loadHighScoreUseCase = loadHighScoreUseCase;
    _saveHighScoreUseCase = saveHighScoreUseCase;
  }

  Future<void> _loadHighScore(GameDifficulty difficulty) async {
    final result = await _loadHighScoreUseCase(difficulty);
    result.fold((_) {}, (highScore) {
      if (highScore != null) {
        state = state.copyWith(highScore: highScore);
      }
    });
  }

  Future<void> startGame(GameDifficulty difficulty) async {
    final result = await _startGameUseCase(state, difficulty);
    result.fold((_) {}, (newState) {
      state = newState;
      _startGameLoop();
    });
  }

  void _startGameLoop() {
    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _updateGame();
    });
  }

  Future<void> _updateGame() async {
    if (!_isMounted) return;
    if (!state.canPlay) return;

    var result = await _updateBallUseCase(state);
    if (!_isMounted) return;
    result.fold((_) {}, (s) {
      if (!_isMounted) return;
      state = s;
    });

    result = await _checkCollisionUseCase(state);
    if (!_isMounted) return;
    result.fold((_) {}, (s) {
      if (!_isMounted) return;
      state = s;
    });

    result = await _updateAiPaddleUseCase(state);
    if (!_isMounted) return;
    result.fold((_) {}, (s) {
      if (!_isMounted) return;
      state = s;
    });

    result = await _checkScoreUseCase(state);
    if (!_isMounted) return;
    result.fold((_) {}, (s) {
      if (!_isMounted) return;
      state = s;
      if (s.isGameOver) {
        _gameLoop?.cancel();
        _handleGameOver();
      }
    });
  }

  Future<void> _handleGameOver() async {
    if (!state.playerWon) return;

    final finalScore = state.calculateFinalScore();
    final newHighScore = HighScoreEntity(
      score: finalScore,
      difficulty: state.difficulty,
      date: DateTime.now(),
      gameDuration: state.elapsedTime ?? Duration.zero,
      totalHits: state.totalHits,
    );

    if (state.highScore == null ||
        newHighScore.isBetterThan(state.highScore!)) {
      await _saveHighScoreUseCase(newHighScore);
      state = state.copyWith(highScore: newHighScore);
    }
  }

  Future<void> movePaddle(PaddleDirection direction) async {
    final result = await _updatePlayerPaddleUseCase(state, direction);
    result.fold((_) {}, (s) => state = s);
  }

  void pauseGame() {
    _gameLoop?.cancel();
    state = state.copyWith(status: GameStatus.paused);
  }

  void resumeGame() {
    if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
      _startGameLoop();
    }
  }

  void resetGame() {
    _gameLoop?.cancel();
    state = GameStateEntity.initial().copyWith(highScore: state.highScore);
  }
}

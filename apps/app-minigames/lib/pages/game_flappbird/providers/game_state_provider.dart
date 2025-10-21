// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/game_logic.dart';
import 'package:app_minigames/models/game_state.dart';

class GameStateProvider extends ChangeNotifier {
  GameStateModel _gameState = GameStateModel.initial;
  FlappyBirdLogic? _gameLogic;
  Ticker? _gameTicker;
  Duration? _lastFrameTime;
  TickerProvider? _tickerProvider;

  // Animation controllers for UI feedback
  AnimationController? _flapController;
  Animation<double>? _flapAnimation;

  GameStateModel get gameState => _gameState;
  FlappyBirdLogic? get gameLogic => _gameLogic;
  Animation<double>? get flapAnimation => _flapAnimation;
  AnimationController? get flapController => _flapController;

  void setAnimationController(AnimationController controller, Animation<double> animation, TickerProvider tickerProvider) {
    _flapController = controller;
    _flapAnimation = animation;
    _tickerProvider = tickerProvider;
  }

  void initialize({
    required double screenWidth,
    required double screenHeight,
    GameDifficulty? difficulty,
  }) {
    if (_gameState.isInitialized) return;

    _gameLogic = FlappyBirdLogic(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      difficulty: difficulty ?? _gameState.difficulty,
    );

    _gameState = _gameState.copyWith(
      isInitialized: true,
      difficulty: difficulty ?? _gameState.difficulty,
      gameState: GameState.ready,
      score: 0,
    );

    notifyListeners();
  }

  void updateScreenDimensions({
    required double screenWidth,
    required double screenHeight,
  }) {
    if (_gameLogic == null) return;

    _gameLogic!.updateScreenDimensions(screenWidth, screenHeight);
    notifyListeners();
  }

  void jump() {
    if (_gameLogic == null) return;

    HapticFeedback.selectionClick();
    
    final oldState = _gameLogic!.gameState;
    _gameLogic!.jump();
    
    // Trigger flap animation
    _flapController?.forward();

    // Update state model
    _gameState = _gameState.copyWith(
      gameState: _gameLogic!.gameState,
      score: _gameLogic!.score,
      highScore: _gameLogic!.highScore,
    );

    // Start game loop if state changed to playing
    if (oldState != GameState.playing && _gameLogic!.gameState == GameState.playing) {
      _startGameLoop();
    }

    notifyListeners();
  }

  void changeDifficulty(GameDifficulty newDifficulty) {
    if (_gameLogic == null) return;

    _gameLogic!.changeDifficulty(newDifficulty);

    _gameState = _gameState.copyWith(
      difficulty: newDifficulty,
      gameState: _gameLogic!.gameState,
      score: _gameLogic!.score,
      highScore: _gameLogic!.highScore,
    );

    if (_gameLogic!.gameState == GameState.playing) {
      _startGameLoop();
    }

    // Show difficulty change feedback
    _showDifficultyChangeFeedback(newDifficulty);

    notifyListeners();
  }

  void pauseGame() {
    if (_gameLogic?.gameState == GameState.playing && !_gameState.isPaused) {
      _stopGameLoop();
      _gameState = _gameState.copyWith(isPaused: true);
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_gameLogic?.gameState == GameState.playing && _gameState.isPaused) {
      _startGameLoop();
      _gameState = _gameState.copyWith(isPaused: false);
      notifyListeners();
    }
  }

  void restartGame() {
    if (_gameLogic == null) return;

    _gameLogic!.restartGame();
    
    _gameState = _gameState.copyWith(
      gameState: _gameLogic!.gameState,
      score: _gameLogic!.score,
      isPaused: false,
    );

    _startGameLoop();
    notifyListeners();
  }

  void _startGameLoop() {
    _stopGameLoop();
    _lastFrameTime = null;

    _gameTicker = _tickerProvider!.createTicker((elapsed) {
      if (_gameLogic == null) return;

      // Calculate delta time
      double deltaTime = 0.016; // Default 60fps fallback
      if (_lastFrameTime != null) {
        deltaTime = (elapsed - _lastFrameTime!).inMicroseconds / Duration.microsecondsPerSecond;
        // Cap delta time to prevent large jumps (max 30fps)
        deltaTime = deltaTime.clamp(0.0, 0.033);
      }
      _lastFrameTime = elapsed;

      final oldScore = _gameLogic!.score;
      final oldGameState = _gameLogic!.gameState;
      
      // Pass delta time to update for frame-independent movement
      _gameLogic!.updateWithDeltaTime(deltaTime);

      // Check for state changes
      bool shouldNotify = false;
      
      if (_gameLogic!.score != oldScore || _gameLogic!.gameState != oldGameState) {
        _gameState = _gameState.copyWith(
          gameState: _gameLogic!.gameState,
          score: _gameLogic!.score,
          highScore: _gameLogic!.highScore,
        );
        shouldNotify = true;
      }

      // Stop game loop if game is over
      if (_gameLogic!.gameState != GameState.playing) {
        _stopGameLoop();
        shouldNotify = true;
      }

      if (shouldNotify) {
        notifyListeners();
      }
    });

    _gameTicker!.start();
  }

  void _stopGameLoop() {
    _gameTicker?.stop();
    _gameTicker?.dispose();
    _gameTicker = null;
    _lastFrameTime = null;
  }

  void _showDifficultyChangeFeedback(GameDifficulty difficulty) {
    // This could trigger a snackbar or other UI feedback
    // For now, we just ensure the state is updated
    debugPrint('Dificuldade alterada para: ${difficulty.label}');
  }

  @override
  void dispose() {
    _stopGameLoop();
    super.dispose();
  }
}

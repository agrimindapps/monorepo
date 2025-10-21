// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/game_logic.dart';

class GameController extends ChangeNotifier {
  late FlappyBirdLogic _gameLogic;
  Timer? _gameTimer;
  bool _isInitialized = false;

  FlappyBirdLogic get gameLogic => _gameLogic;
  bool get isInitialized => _isInitialized;

  void initialize({
    required double screenWidth,
    required double screenHeight,
    GameDifficulty difficulty = GameDifficulty.medium,
  }) {
    if (_isInitialized) return;
    
    _gameLogic = FlappyBirdLogic(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      difficulty: difficulty,
    );
    _isInitialized = true;
    notifyListeners();
  }

  void updateScreenDimensions({
    required double screenWidth,
    required double screenHeight,
  }) {
    if (!_isInitialized) return;
    
    _gameLogic.updateScreenDimensions(screenWidth, screenHeight);
    notifyListeners();
  }

  void startGameLoop() {
    _gameTimer?.cancel();
    
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _gameLogic.update();
      notifyListeners();
    });
  }

  void stopGameLoop() {
    _gameTimer?.cancel();
  }

  void jump() {
    _gameLogic.jump();
    
    if (_gameLogic.gameState == GameState.playing) {
      startGameLoop();
    }
    
    notifyListeners();
  }

  void changeDifficulty(GameDifficulty newDifficulty) {
    _gameLogic.changeDifficulty(newDifficulty);
    
    if (_gameLogic.gameState == GameState.playing) {
      startGameLoop();
    }
    
    notifyListeners();
  }

  void pauseGame() {
    if (_gameLogic.gameState == GameState.playing) {
      stopGameLoop();
    }
  }

  void resumeGame() {
    if (_gameLogic.gameState == GameState.playing) {
      startGameLoop();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}

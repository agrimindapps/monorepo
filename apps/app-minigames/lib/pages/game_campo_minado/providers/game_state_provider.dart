// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/cell.dart';
import 'package:app_minigames/models/game_state.dart';
import 'package:app_minigames/models/minefield_logic.dart';
import 'package:app_minigames/services/logger_service.dart';

/// Provider for managing Minesweeper game state
class GameStateProvider extends ChangeNotifier {
  final MinefieldLogic _logic;
  GameStateModel _gameState;
  Timer? _gameTimer;

  GameStateProvider({
    GameDifficulty difficulty = GameDifficulty.beginner,
    GameConfig? customConfig,
  }) : _logic = MinefieldLogic(difficulty: difficulty, customConfig: customConfig),
       _gameState = GameStateModel.initial.copyWith(
         difficulty: difficulty,
         config: customConfig ?? difficulty.config,
         remainingMines: customConfig?.mines ?? difficulty.config.mines,
       ) {
    _startTimer();
    LoggerService.info('GameStateProvider initialized with ${difficulty.label} difficulty');
  }

  // Getters
  GameStateModel get gameState => _gameState;
  GameConfig get config => _gameState.config;
  List<List<Cell>> get grid => _logic.grid;
  GameDifficulty get difficulty => _gameState.difficulty;
  bool get isGameActive => _gameState.isGameActive;
  bool get isGameOver => _gameState.isGameOver;
  int get timeSeconds => _gameState.timeSeconds;
  int get flaggedCells => _gameState.flaggedCells;
  int get revealedCells => _gameState.revealedCells;
  int get remainingMines => _gameState.remainingMines;
  String get formattedTime => _gameState.formattedTime;

  // Statistics getters
  int get bestTime => _logic.bestTime;
  int get totalGames => _logic.totalGames;
  int get totalWins => _logic.totalWins;
  int get currentStreak => _logic.currentStreak;
  int get bestStreak => _logic.bestStreak;
  double get winRate => _logic.winRate;
  String get formattedBestTime => _logic.formattedBestTime;

  /// Reveals a cell at the given position
  bool revealCell(int row, int col) {
    if (!_gameState.canInteract) return false;

    final success = _logic.revealCell(row, col);
    if (success) {
      _updateGameState();
      
      // Start the game timer on first move
      if (_logic.gameState == GameState.playing && _gameState.isFirstClick) {
        _gameState = _gameState.copyWith(isFirstClick: false);
        _startTimer();
      }
      
      // Handle game over
      if (_logic.isGameOver) {
        _stopTimer();
      }
    }
    
    return success;
  }

  /// Toggles flag on a cell
  bool toggleFlag(int row, int col) {
    if (!_gameState.canInteract) return false;

    final success = _logic.toggleFlag(row, col);
    if (success) {
      _updateGameState();
    }
    
    return success;
  }

  /// Performs chord click (reveals neighbors if flag count matches)
  bool chordClick(int row, int col) {
    if (!_gameState.canInteract) return false;

    final success = _logic.chordClick(row, col);
    if (success) {
      _updateGameState();
      
      // Handle game over
      if (_logic.isGameOver) {
        _stopTimer();
      }
    }
    
    return success;
  }

  /// Restarts the current game
  void restartGame() {
    _stopTimer();
    _logic.restart();
    _resetGameState();
    _startTimer();
    LoggerService.info('Game restarted');
  }

  /// Changes game difficulty and restarts
  void changeDifficulty(GameDifficulty newDifficulty, {GameConfig? customConfig}) {
    _stopTimer();
    _logic.changeDifficulty(newDifficulty, customConfig: customConfig);
    
    final config = customConfig ?? newDifficulty.config;
    _gameState = GameStateModel.initial.copyWith(
      difficulty: newDifficulty,
      config: config,
      remainingMines: config.mines,
    );
    
    _startTimer();
    notifyListeners();
    LoggerService.info('Difficulty changed to ${newDifficulty.label}');
  }

  /// Pauses or resumes the game
  void togglePause() {
    if (_gameState.isGameOver) return;

    final newPausedState = !_gameState.isPaused;
    _gameState = _gameState.copyWith(isPaused: newPausedState);
    
    if (newPausedState) {
      _stopTimer();
      LoggerService.info('Game paused');
    } else {
      _startTimer();
      LoggerService.info('Game resumed');
    }
    
    notifyListeners();
  }

  /// Gets a cell at the specified position
  Cell? getCellAt(int row, int col) {
    return _logic.getCellAt(row, col);
  }

  /// Updates the game state from the logic
  void _updateGameState() {
    _gameState = _gameState.copyWith(
      gameState: _logic.gameState,
      flaggedCells: _logic.flaggedCells,
      revealedCells: _logic.revealedCells,
      remainingMines: _logic.remainingMines,
      timeSeconds: _logic.timeSeconds,
    );
    
    notifyListeners();
  }

  /// Resets the game state to initial values
  void _resetGameState() {
    _gameState = _gameState.copyWith(
      gameState: GameState.ready,
      timeSeconds: 0,
      flaggedCells: 0,
      revealedCells: 0,
      remainingMines: _gameState.config.mines,
      isFirstClick: true,
      isPaused: false,
    );
    
    notifyListeners();
  }

  /// Starts the game timer
  void _startTimer() {
    _stopTimer(); // Ensure no duplicate timers
    
    if (_gameState.isGameOver || _gameState.isPaused) return;
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_logic.isGameActive && !_gameState.isPaused) {
        _logic.updateTimer();
        _gameState = _gameState.copyWith(timeSeconds: _logic.timeSeconds);
        notifyListeners();
      }
    });
  }

  /// Stops the game timer
  void _stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

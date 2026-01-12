import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/tetromino.dart';
import '../../domain/entities/tetris_score.dart';
import 'tetris_data_providers.dart';

part 'tetris_controller.g.dart';

class TetrisState {
  final List<List<Color?>> board;
  final Tetromino? currentPiece;
  final Tetromino? nextPiece;
  final int score;
  final int lines;
  final int level;
  final bool isGameOver;
  final bool isPaused;
  final DateTime? gameStartTime;
  final int tetrisCount; // Contador de Tetris (4 linhas de uma vez)
  
  static const int boardWidth = 10;
  static const int boardHeight = 20;
  
  TetrisState({
    required this.board,
    this.currentPiece,
    this.nextPiece,
    this.score = 0,
    this.lines = 0,
    this.level = 1,
    this.isGameOver = false,
    this.isPaused = false,
    this.gameStartTime,
    this.tetrisCount = 0,
  });
  
  factory TetrisState.initial() {
    return TetrisState(
      board: List.generate(
        boardHeight,
        (_) => List.generate(boardWidth, (_) => null),
      ),
      gameStartTime: DateTime.now(),
    );
  }
  
  TetrisState copyWith({
    List<List<Color?>>? board,
    Tetromino? currentPiece,
    Tetromino? nextPiece,
    int? score,
    int? lines,
    int? level,
    bool? isGameOver,
    bool? isPaused,
    DateTime? gameStartTime,
    int? tetrisCount,
    bool clearCurrentPiece = false,
  }) {
    return TetrisState(
      board: board ?? this.board,
      currentPiece: clearCurrentPiece ? null : (currentPiece ?? this.currentPiece),
      nextPiece: nextPiece ?? this.nextPiece,
      score: score ?? this.score,
      lines: lines ?? this.lines,
      level: level ?? this.level,
      isGameOver: isGameOver ?? this.isGameOver,
      isPaused: isPaused ?? this.isPaused,
      gameStartTime: gameStartTime ?? this.gameStartTime,
      tetrisCount: tetrisCount ?? this.tetrisCount,
    );
  }
  
  /// Duração do jogo
  Duration get gameDuration {
    if (gameStartTime == null) return Duration.zero;
    return DateTime.now().difference(gameStartTime!);
  }
}

@riverpod
class TetrisController extends _$TetrisController {
  Timer? _gameTimer;
  final Random _random = Random();
  
  @override
  TetrisState build() {
    ref.onDispose(() {
      _gameTimer?.cancel();
    });
    return TetrisState.initial();
  }
  
  void startGame() {
    _gameTimer?.cancel();
    
    state = TetrisState.initial();
    _spawnPiece();
    _startGameLoop();
  }
  
  void _startGameLoop() {
    final speed = Duration(milliseconds: 1000 - (state.level - 1) * 100);
    _gameTimer = Timer.periodic(speed.clamp(const Duration(milliseconds: 100), const Duration(milliseconds: 1000)), (_) {
      if (!state.isPaused && !state.isGameOver) {
        _moveDown();
      }
    });
  }
  
  void _spawnPiece() {
    final nextType = TetrominoType.values[_random.nextInt(TetrominoType.values.length)];
    final newPiece = state.nextPiece ?? Tetromino.create(
      TetrominoType.values[_random.nextInt(TetrominoType.values.length)],
    );
    
    newPiece.x = (TetrisState.boardWidth - newPiece.shape[0].length) ~/ 2;
    newPiece.y = 0;
    
    if (!_canPlace(newPiece, newPiece.x, newPiece.y)) {
      state = state.copyWith(isGameOver: true);
      _gameTimer?.cancel();
      _saveScore(); // Salva o score quando o jogo termina
      return;
    }
    
    state = state.copyWith(
      currentPiece: newPiece,
      nextPiece: Tetromino.create(nextType),
    );
  }
  
  bool _canPlace(Tetromino piece, int x, int y) {
    for (int row = 0; row < piece.shape.length; row++) {
      for (int col = 0; col < piece.shape[row].length; col++) {
        if (piece.shape[row][col] == 1) {
          final boardX = x + col;
          final boardY = y + row;
          
          if (boardX < 0 || boardX >= TetrisState.boardWidth) return false;
          if (boardY >= TetrisState.boardHeight) return false;
          if (boardY >= 0 && state.board[boardY][boardX] != null) return false;
        }
      }
    }
    return true;
  }
  
  void _lockPiece() {
    if (state.currentPiece == null) return;
    
    final piece = state.currentPiece!;
    final newBoard = state.board.map((row) => List<Color?>.from(row)).toList();
    
    for (int row = 0; row < piece.shape.length; row++) {
      for (int col = 0; col < piece.shape[row].length; col++) {
        if (piece.shape[row][col] == 1) {
          final boardX = piece.x + col;
          final boardY = piece.y + row;
          
          if (boardY >= 0 && boardY < TetrisState.boardHeight &&
              boardX >= 0 && boardX < TetrisState.boardWidth) {
            newBoard[boardY][boardX] = piece.color;
          }
        }
      }
    }
    
    state = state.copyWith(board: newBoard, clearCurrentPiece: true);
    _clearLines();
    _spawnPiece();
  }
  
  void _clearLines() {
    final newBoard = state.board.map((row) => List<Color?>.from(row)).toList();
    int linesCleared = 0;
    
    for (int row = TetrisState.boardHeight - 1; row >= 0; row--) {
      if (newBoard[row].every((cell) => cell != null)) {
        newBoard.removeAt(row);
        newBoard.insert(0, List.generate(TetrisState.boardWidth, (_) => null));
        linesCleared++;
        row++; // Check same row again
      }
    }
    
    if (linesCleared > 0) {
      final points = [0, 100, 300, 500, 800][linesCleared];
      final newLines = state.lines + linesCleared;
      final newLevel = (newLines ~/ 10) + 1;
      final isTetris = linesCleared == 4;
      
      state = state.copyWith(
        board: newBoard,
        score: state.score + points * state.level,
        lines: newLines,
        level: newLevel,
        tetrisCount: isTetris ? state.tetrisCount + 1 : state.tetrisCount,
      );
      
      if (newLevel != state.level) {
        _gameTimer?.cancel();
        _startGameLoop();
      }
    }
  }
  
  void _moveDown() {
    if (state.currentPiece == null) return;
    
    final piece = state.currentPiece!;
    if (_canPlace(piece, piece.x, piece.y + 1)) {
      state = state.copyWith(
        currentPiece: piece.copy()..y = piece.y + 1,
      );
    } else {
      _lockPiece();
    }
  }
  
  void moveLeft() {
    if (state.currentPiece == null || state.isGameOver || state.isPaused) return;
    
    final piece = state.currentPiece!;
    if (_canPlace(piece, piece.x - 1, piece.y)) {
      state = state.copyWith(
        currentPiece: piece.copy()..x = piece.x - 1,
      );
    }
  }
  
  void moveRight() {
    if (state.currentPiece == null || state.isGameOver || state.isPaused) return;
    
    final piece = state.currentPiece!;
    if (_canPlace(piece, piece.x + 1, piece.y)) {
      state = state.copyWith(
        currentPiece: piece.copy()..x = piece.x + 1,
      );
    }
  }
  
  void softDrop() {
    if (state.isGameOver || state.isPaused) return;
    _moveDown();
  }
  
  void hardDrop() {
    if (state.currentPiece == null || state.isGameOver || state.isPaused) return;
    
    final piece = state.currentPiece!;
    int newY = piece.y;
    
    while (_canPlace(piece, piece.x, newY + 1)) {
      newY++;
    }
    
    state = state.copyWith(
      currentPiece: piece.copy()..y = newY,
    );
    _lockPiece();
  }
  
  void rotate() {
    if (state.currentPiece == null || state.isGameOver || state.isPaused) return;
    
    final piece = state.currentPiece!.copy();
    piece.rotateClockwise();
    
    // Wall kick - try moving piece if rotation causes collision
    final kicks = [0, -1, 1, -2, 2];
    for (final kick in kicks) {
      if (_canPlace(piece, piece.x + kick, piece.y)) {
        piece.x += kick;
        state = state.copyWith(currentPiece: piece);
        return;
      }
    }
  }
  
  void togglePause() {
    if (state.isGameOver) return;
    state = state.copyWith(isPaused: !state.isPaused);
  }
  
  void restart() {
    startGame();
  }
  
  /// Salva o score quando o jogo termina
  Future<void> _saveScore() async {
    if (state.score == 0) return; // Não salva scores zero
    
    final score = TetrisScore.create(
      score: state.score,
      lines: state.lines,
      level: state.level,
      duration: state.gameDuration,
    );
    
    try {
      final scoreActions = ref.read(tetrisScoreActionsProvider.notifier);
      await scoreActions.saveScore(score, tetrisCount: state.tetrisCount);
    } catch (e) {
      // Ignora erros de salvamento para não afetar o jogo
      debugPrint('Failed to save score: $e');
    }
  }
}

extension on Duration {
  Duration clamp(Duration min, Duration max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

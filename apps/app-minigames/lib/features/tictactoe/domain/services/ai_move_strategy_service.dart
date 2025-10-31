import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../entities/enums.dart';
import 'game_result_validation_service.dart';

/// Service responsible for AI move strategy selection
///
/// Handles:
/// - Strategy selection based on difficulty
/// - Smart move calculation (winning, blocking, center, corners)
/// - Random move generation
/// - Move prioritization
@lazySingleton
class AIMoveStrategyService {
  final GameResultValidationService _gameValidation;
  final Random _random;

  AIMoveStrategyService(this._gameValidation) : _random = Random();

  // For testing purposes
  @visibleForTesting
  AIMoveStrategyService.withRandom(
    GameResultValidationService gameValidation,
    Random random,
  )   : _gameValidation = gameValidation,
        _random = random;

  // ============================================================================
  // Strategy Selection
  // ============================================================================

  /// Gets best move based on difficulty level
  MoveResult? getBestMove({
    required List<List<Player>> board,
    required Player currentPlayer,
    required Difficulty difficulty,
  }) {
    final availableMoves = _getAvailableMoves(board);

    if (availableMoves.isEmpty) {
      return null;
    }

    switch (difficulty) {
      case Difficulty.easy:
        return _getRandomMove(availableMoves);

      case Difficulty.medium:
        // 50% chance of smart move, 50% random
        return _random.nextBool()
            ? _getSmartMove(
                board: board,
                currentPlayer: currentPlayer,
                availableMoves: availableMoves,
              )
            : _getRandomMove(availableMoves);

      case Difficulty.hard:
        return _getSmartMove(
          board: board,
          currentPlayer: currentPlayer,
          availableMoves: availableMoves,
        );
    }
  }

  // ============================================================================
  // Random Strategy
  // ============================================================================

  /// Gets a random move from available moves
  MoveResult _getRandomMove(List<(int, int)> availableMoves) {
    final randomIndex = _random.nextInt(availableMoves.length);
    final (row, col) = availableMoves[randomIndex];

    return MoveResult(
      row: row,
      col: col,
      strategy: MoveStrategy.random,
      confidence: 0.5,
    );
  }

  // ============================================================================
  // Smart Strategy
  // ============================================================================

  /// Gets optimal move using prioritized strategy
  MoveResult _getSmartMove({
    required List<List<Player>> board,
    required Player currentPlayer,
    required List<(int, int)> availableMoves,
  }) {
    // Priority 1: Find winning move
    final winningMove = _findWinningMove(
      board: board,
      player: currentPlayer,
      availableMoves: availableMoves,
    );
    if (winningMove != null) return winningMove;

    // Priority 2: Block opponent's winning move
    final blockingMove = _findBlockingMove(
      board: board,
      player: currentPlayer,
      availableMoves: availableMoves,
    );
    if (blockingMove != null) return blockingMove;

    // Priority 3: Take center if available
    if (_isCellAvailable(board, 1, 1)) {
      return MoveResult(
        row: 1,
        col: 1,
        strategy: MoveStrategy.center,
        confidence: 0.8,
      );
    }

    // Priority 4: Take a corner
    final cornerMove = _findCornerMove(board, availableMoves);
    if (cornerMove != null) return cornerMove;

    // Priority 5: Take any available edge
    final edgeMove = _findEdgeMove(board, availableMoves);
    if (edgeMove != null) return edgeMove;

    // Fallback: Random move
    return _getRandomMove(availableMoves);
  }

  // ============================================================================
  // Winning Move Detection
  // ============================================================================

  /// Finds a move that would win the game immediately
  MoveResult? _findWinningMove({
    required List<List<Player>> board,
    required Player player,
    required List<(int, int)> availableMoves,
  }) {
    for (final (row, col) in availableMoves) {
      if (_gameValidation.wouldMoveWin(
        board: board,
        row: row,
        col: col,
        player: player,
      )) {
        return MoveResult(
          row: row,
          col: col,
          strategy: MoveStrategy.winning,
          confidence: 1.0,
        );
      }
    }
    return null;
  }

  // ============================================================================
  // Blocking Move Detection
  // ============================================================================

  /// Finds a move that blocks opponent from winning
  MoveResult? _findBlockingMove({
    required List<List<Player>> board,
    required Player player,
    required List<(int, int)> availableMoves,
  }) {
    final opponent = player.opponent;

    for (final (row, col) in availableMoves) {
      if (_gameValidation.wouldMoveWin(
        board: board,
        row: row,
        col: col,
        player: opponent,
      )) {
        return MoveResult(
          row: row,
          col: col,
          strategy: MoveStrategy.blocking,
          confidence: 0.95,
        );
      }
    }
    return null;
  }

  // ============================================================================
  // Position Strategy
  // ============================================================================

  /// Finds an available corner move
  MoveResult? _findCornerMove(
    List<List<Player>> board,
    List<(int, int)> availableMoves,
  ) {
    const corners = [
      (0, 0),
      (0, 2),
      (2, 0),
      (2, 2),
    ];

    for (final corner in corners) {
      if (availableMoves.contains(corner)) {
        return MoveResult(
          row: corner.$1,
          col: corner.$2,
          strategy: MoveStrategy.corner,
          confidence: 0.75,
        );
      }
    }

    return null;
  }

  /// Finds an available edge move
  MoveResult? _findEdgeMove(
    List<List<Player>> board,
    List<(int, int)> availableMoves,
  ) {
    const edges = [
      (0, 1),
      (1, 0),
      (1, 2),
      (2, 1),
    ];

    for (final edge in edges) {
      if (availableMoves.contains(edge)) {
        return MoveResult(
          row: edge.$1,
          col: edge.$2,
          strategy: MoveStrategy.edge,
          confidence: 0.6,
        );
      }
    }

    return null;
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Gets all available moves
  List<(int, int)> _getAvailableMoves(List<List<Player>> board) {
    final moves = <(int, int)>[];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          moves.add((i, j));
        }
      }
    }

    return moves;
  }

  /// Checks if a cell is available
  bool _isCellAvailable(List<List<Player>> board, int row, int col) {
    return board[row][col] == Player.none;
  }

  // ============================================================================
  // Move Analysis
  // ============================================================================

  /// Analyzes all available moves and their quality
  List<MoveAnalysis> analyzeAllMoves({
    required List<List<Player>> board,
    required Player currentPlayer,
  }) {
    final availableMoves = _getAvailableMoves(board);
    final analyses = <MoveAnalysis>[];

    for (final (row, col) in availableMoves) {
      final quality = _evaluateMoveQuality(
        board: board,
        row: row,
        col: col,
        player: currentPlayer,
      );

      analyses.add(MoveAnalysis(
        row: row,
        col: col,
        quality: quality,
        isWinning: _gameValidation.wouldMoveWin(
          board: board,
          row: row,
          col: col,
          player: currentPlayer,
        ),
        isBlocking: _gameValidation.wouldMoveWin(
          board: board,
          row: row,
          col: col,
          player: currentPlayer.opponent,
        ),
        isCenter: row == 1 && col == 1,
        isCorner: _isCorner(row, col),
        isEdge: _isEdge(row, col),
      ));
    }

    // Sort by quality (descending)
    analyses.sort((a, b) => b.quality.compareTo(a.quality));

    return analyses;
  }

  /// Evaluates move quality (0.0 to 1.0)
  double _evaluateMoveQuality({
    required List<List<Player>> board,
    required int row,
    required int col,
    required Player player,
  }) {
    // Winning move: highest quality
    if (_gameValidation.wouldMoveWin(
      board: board,
      row: row,
      col: col,
      player: player,
    )) {
      return 1.0;
    }

    // Blocking move: second highest
    if (_gameValidation.wouldMoveWin(
      board: board,
      row: row,
      col: col,
      player: player.opponent,
    )) {
      return 0.95;
    }

    // Center: good strategic position
    if (row == 1 && col == 1) {
      return 0.8;
    }

    // Corner: decent strategic position
    if (_isCorner(row, col)) {
      return 0.7;
    }

    // Edge: lower priority
    if (_isEdge(row, col)) {
      return 0.5;
    }

    return 0.3;
  }

  /// Checks if position is a corner
  bool _isCorner(int row, int col) {
    return (row == 0 || row == 2) && (col == 0 || col == 2);
  }

  /// Checks if position is an edge
  bool _isEdge(int row, int col) {
    return (row == 1 && (col == 0 || col == 2)) ||
        (col == 1 && (row == 0 || row == 2));
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets strategy statistics
  StrategyStatistics getStatistics({
    required List<List<Player>> board,
    required Player currentPlayer,
  }) {
    final availableMoves = _getAvailableMoves(board);
    final analyses = analyzeAllMoves(
      board: board,
      currentPlayer: currentPlayer,
    );

    final winningMoves = analyses.where((a) => a.isWinning).length;
    final blockingMoves = analyses.where((a) => a.isBlocking).length;
    final centerAvailable = _isCellAvailable(board, 1, 1);
    final cornersAvailable = analyses.where((a) => a.isCorner).length;

    final averageQuality = analyses.isEmpty
        ? 0.0
        : analyses.fold<double>(0, (sum, a) => sum + a.quality) /
            analyses.length;

    return StrategyStatistics(
      totalMoves: availableMoves.length,
      winningMoves: winningMoves,
      blockingMoves: blockingMoves,
      centerAvailable: centerAvailable,
      cornersAvailable: cornersAvailable,
      averageQuality: averageQuality,
      bestMoveQuality: analyses.isEmpty ? 0.0 : analyses.first.quality,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Move result with strategy information
class MoveResult {
  final int row;
  final int col;
  final MoveStrategy strategy;
  final double confidence; // 0.0 to 1.0

  const MoveResult({
    required this.row,
    required this.col,
    required this.strategy,
    required this.confidence,
  });

  /// Gets position as tuple
  (int, int) get position => (row, col);

  /// Gets confidence as percentage
  double get confidencePercentage => confidence * 100;
}

/// Move strategy type
enum MoveStrategy {
  winning,
  blocking,
  center,
  corner,
  edge,
  random;

  String get label {
    switch (this) {
      case MoveStrategy.winning:
        return 'Jogada Vencedora';
      case MoveStrategy.blocking:
        return 'Bloqueio';
      case MoveStrategy.center:
        return 'Centro';
      case MoveStrategy.corner:
        return 'Canto';
      case MoveStrategy.edge:
        return 'Borda';
      case MoveStrategy.random:
        return 'Aleatória';
    }
  }

  String get emoji {
    switch (this) {
      case MoveStrategy.winning:
        return '🏆';
      case MoveStrategy.blocking:
        return '🛡️';
      case MoveStrategy.center:
        return '🎯';
      case MoveStrategy.corner:
        return '📐';
      case MoveStrategy.edge:
        return '📏';
      case MoveStrategy.random:
        return '🎲';
    }
  }
}

/// Move analysis with quality metrics
class MoveAnalysis {
  final int row;
  final int col;
  final double quality;
  final bool isWinning;
  final bool isBlocking;
  final bool isCenter;
  final bool isCorner;
  final bool isEdge;

  const MoveAnalysis({
    required this.row,
    required this.col,
    required this.quality,
    required this.isWinning,
    required this.isBlocking,
    required this.isCenter,
    required this.isCorner,
    required this.isEdge,
  });

  /// Gets position as tuple
  (int, int) get position => (row, col);

  /// Gets primary characteristic
  String get primaryCharacteristic {
    if (isWinning) return 'Vencedora';
    if (isBlocking) return 'Bloqueio';
    if (isCenter) return 'Centro';
    if (isCorner) return 'Canto';
    if (isEdge) return 'Borda';
    return 'Padrão';
  }

  /// Gets quality level
  MoveQuality get qualityLevel {
    if (quality >= 0.95) {
      return MoveQuality.excellent;
    } else if (quality >= 0.8) {
      return MoveQuality.good;
    } else if (quality >= 0.6) {
      return MoveQuality.fair;
    } else {
      return MoveQuality.poor;
    }
  }
}

/// Move quality classification
enum MoveQuality {
  excellent,
  good,
  fair,
  poor;

  String get label {
    switch (this) {
      case MoveQuality.excellent:
        return 'Excelente';
      case MoveQuality.good:
        return 'Boa';
      case MoveQuality.fair:
        return 'Razoável';
      case MoveQuality.poor:
        return 'Fraca';
    }
  }

  String get emoji {
    switch (this) {
      case MoveQuality.excellent:
        return '⭐⭐⭐';
      case MoveQuality.good:
        return '⭐⭐';
      case MoveQuality.fair:
        return '⭐';
      case MoveQuality.poor:
        return '💭';
    }
  }
}

/// Strategy statistics
class StrategyStatistics {
  final int totalMoves;
  final int winningMoves;
  final int blockingMoves;
  final bool centerAvailable;
  final int cornersAvailable;
  final double averageQuality;
  final double bestMoveQuality;

  const StrategyStatistics({
    required this.totalMoves,
    required this.winningMoves,
    required this.blockingMoves,
    required this.centerAvailable,
    required this.cornersAvailable,
    required this.averageQuality,
    required this.bestMoveQuality,
  });

  /// Checks if there are critical moves (winning or blocking)
  bool get hasCriticalMoves => winningMoves > 0 || blockingMoves > 0;

  /// Gets move availability status
  String get availabilityStatus {
    if (winningMoves > 0) {
      return '$winningMoves jogada(s) vencedora(s) disponível(eis)';
    } else if (blockingMoves > 0) {
      return '$blockingMoves bloqueio(s) necessário(s)';
    } else if (centerAvailable) {
      return 'Centro disponível';
    } else if (cornersAvailable > 0) {
      return '$cornersAvailable canto(s) disponível(eis)';
    } else {
      return '$totalMoves jogada(s) disponível(eis)';
    }
  }
}

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../entities/position_entity.dart';
import '../entities/sudoku_grid_entity.dart';
import 'grid_validation_service.dart';

/// Service responsible for hint generation and management
///
/// Handles:
/// - Finding valid numbers for positions
/// - Hint selection strategies
/// - Hint validation
/// - Hint statistics
class HintGeneratorService {
  final GridValidationService _gridValidation;
  final Random _random;

  HintGeneratorService(this._gridValidation) : _random = Random();

  // For testing purposes
  @visibleForTesting
  HintGeneratorService.withRandom(
    GridValidationService gridValidation,
    Random random,
  )   : _gridValidation = gridValidation,
        _random = random;

  // ============================================================================
  // Valid Numbers Discovery
  // ============================================================================

  /// Finds all valid numbers that can be placed at position
  List<int> findValidNumbers({
    required SudokuGridEntity grid,
    required int row,
    required int col,
  }) {
    final validNumbers = <int>[];

    for (int num = 1; num <= 9; num++) {
      if (_gridValidation.isValidPlacement(
        grid: grid,
        row: row,
        col: col,
        value: num,
      )) {
        validNumbers.add(num);
      }
    }

    return validNumbers;
  }

  /// Gets all cells with their valid numbers
  Map<PositionEntity, List<int>> findAllValidNumbers(SudokuGridEntity grid) {
    final result = <PositionEntity, List<int>>{};

    for (final cell in grid.getEmptyCells()) {
      final validNumbers = findValidNumbers(
        grid: grid,
        row: cell.row,
        col: cell.col,
      );

      if (validNumbers.isNotEmpty) {
        result[cell.position] = validNumbers;
      }
    }

    return result;
  }

  // ============================================================================
  // Hint Selection
  // ============================================================================

  /// Gets a random hint from available options
  HintResult? getRandomHint(SudokuGridEntity grid) {
    final cellsWithMoves = _getCellsWithValidMoves(grid);

    if (cellsWithMoves.isEmpty) {
      return null;
    }

    // Select random cell
    final randomIndex = _random.nextInt(cellsWithMoves.length);
    final (position, validNumbers) = cellsWithMoves[randomIndex];

    // Select first valid number (could be randomized)
    final hintValue = validNumbers.first;

    return HintResult(
      position: position,
      value: hintValue,
      strategy: HintStrategy.random,
      validNumbers: validNumbers,
      alternativeCount: validNumbers.length - 1,
    );
  }

  /// Gets easiest hint (cell with fewest valid numbers)
  HintResult? getEasiestHint(SudokuGridEntity grid) {
    final cellsWithMoves = _getCellsWithValidMoves(grid);

    if (cellsWithMoves.isEmpty) {
      return null;
    }

    // Sort by number of valid moves (ascending)
    cellsWithMoves.sort((a, b) => a.$2.length.compareTo(b.$2.length));

    // Get cell with fewest options
    final (position, validNumbers) = cellsWithMoves.first;
    final hintValue = validNumbers.first;

    return HintResult(
      position: position,
      value: hintValue,
      strategy: HintStrategy.easiest,
      validNumbers: validNumbers,
      alternativeCount: validNumbers.length - 1,
    );
  }

  /// Gets strategic hint (prioritizes cells with single valid number)
  HintResult? getStrategicHint(SudokuGridEntity grid) {
    final cellsWithMoves = _getCellsWithValidMoves(grid);

    if (cellsWithMoves.isEmpty) {
      return null;
    }

    // First: Try to find cells with only one valid number (naked singles)
    final nakedSingles = cellsWithMoves.where((entry) {
      return entry.$2.length == 1;
    }).toList();

    if (nakedSingles.isNotEmpty) {
      // Random from naked singles
      final randomIndex = _random.nextInt(nakedSingles.length);
      final (position, validNumbers) = nakedSingles[randomIndex];

      return HintResult(
        position: position,
        value: validNumbers.first,
        strategy: HintStrategy.nakedSingle,
        validNumbers: validNumbers,
        alternativeCount: 0,
      );
    }

    // Second: Try cells with few options (2-3 options)
    final fewOptions = cellsWithMoves.where((entry) {
      return entry.$2.length >= 2 && entry.$2.length <= 3;
    }).toList();

    if (fewOptions.isNotEmpty) {
      // Sort by fewest options
      fewOptions.sort((a, b) => a.$2.length.compareTo(b.$2.length));
      final (position, validNumbers) = fewOptions.first;

      return HintResult(
        position: position,
        value: validNumbers.first,
        strategy: HintStrategy.fewOptions,
        validNumbers: validNumbers,
        alternativeCount: validNumbers.length - 1,
      );
    }

    // Fallback: Random cell
    return getRandomHint(grid);
  }

  /// Gets hint at specific position
  HintResult? getHintAtPosition({
    required SudokuGridEntity grid,
    required int row,
    required int col,
  }) {
    final cell = grid.getCell(row, col);

    if (!cell.isEmpty) {
      return null;
    }

    final validNumbers = findValidNumbers(
      grid: grid,
      row: row,
      col: col,
    );

    if (validNumbers.isEmpty) {
      return null;
    }

    return HintResult(
      position: cell.position,
      value: validNumbers.first,
      strategy: HintStrategy.specific,
      validNumbers: validNumbers,
      alternativeCount: validNumbers.length - 1,
    );
  }

  // ============================================================================
  // Hint Validation
  // ============================================================================

  /// Checks if hints are available
  bool hasHintsAvailable(SudokuGridEntity grid) {
    final cellsWithMoves = _getCellsWithValidMoves(grid);
    return cellsWithMoves.isNotEmpty;
  }

  /// Gets count of available hints
  int getHintCount(SudokuGridEntity grid) {
    final cellsWithMoves = _getCellsWithValidMoves(grid);
    return cellsWithMoves.length;
  }

  /// Validates if hint is needed
  HintNeedAssessment assessHintNeed(SudokuGridEntity grid) {
    final emptyCells = grid.getEmptyCells().length;
    final cellsWithMoves = _getCellsWithValidMoves(grid);
    final nakedSingles = cellsWithMoves.where((e) => e.$2.length == 1).length;

    final needLevel = _calculateNeedLevel(
      emptyCells: emptyCells,
      cellsWithMoves: cellsWithMoves.length,
      nakedSingles: nakedSingles,
    );

    return HintNeedAssessment(
      needLevel: needLevel,
      emptyCells: emptyCells,
      cellsWithMoves: cellsWithMoves.length,
      nakedSingles: nakedSingles,
      isStuck: cellsWithMoves.isEmpty && emptyCells > 0,
    );
  }

  /// Calculates hint need level
  HintNeedLevel _calculateNeedLevel({
    required int emptyCells,
    required int cellsWithMoves,
    required int nakedSingles,
  }) {
    // Stuck: no moves available
    if (cellsWithMoves == 0 && emptyCells > 0) {
      return HintNeedLevel.stuck;
    }

    // Critical: very few moves, many empty cells
    if (cellsWithMoves <= 3 && emptyCells > 20) {
      return HintNeedLevel.critical;
    }

    // High: naked singles available (obvious moves)
    if (nakedSingles > 0) {
      return HintNeedLevel.low;
    }

    // Medium: moderate difficulty
    if (emptyCells > 30) {
      return HintNeedLevel.medium;
    }

    return HintNeedLevel.low;
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Gets all cells with valid moves
  List<(PositionEntity, List<int>)> _getCellsWithValidMoves(
    SudokuGridEntity grid,
  ) {
    final cellsWithMoves = <(PositionEntity, List<int>)>[];

    for (final cell in grid.getEmptyCells()) {
      final validNumbers = findValidNumbers(
        grid: grid,
        row: cell.row,
        col: cell.col,
      );

      if (validNumbers.isNotEmpty) {
        cellsWithMoves.add((cell.position, validNumbers));
      }
    }

    return cellsWithMoves;
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets hint statistics
  HintStatistics getStatistics(SudokuGridEntity grid) {
    final cellsWithMoves = _getCellsWithValidMoves(grid);
    final nakedSingles = cellsWithMoves.where((e) => e.$2.length == 1).length;
    final hiddenSingles = cellsWithMoves.where((e) => e.$2.length >= 2).length;

    final totalValidMoves =
        cellsWithMoves.fold<int>(0, (sum, e) => sum + e.$2.length);

    final averageOptions =
        cellsWithMoves.isEmpty ? 0.0 : totalValidMoves / cellsWithMoves.length;

    final needAssessment = assessHintNeed(grid);

    return HintStatistics(
      totalHintsAvailable: cellsWithMoves.length,
      nakedSingles: nakedSingles,
      hiddenSingles: hiddenSingles,
      totalValidMoves: totalValidMoves,
      averageOptionsPerCell: averageOptions,
      needLevel: needAssessment.needLevel,
      isStuck: needAssessment.isStuck,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Hint result
class HintResult {
  final PositionEntity position;
  final int value;
  final HintStrategy strategy;
  final List<int> validNumbers;
  final int alternativeCount;

  const HintResult({
    required this.position,
    required this.value,
    required this.strategy,
    required this.validNumbers,
    required this.alternativeCount,
  });

  /// Gets row
  int get row => position.row;

  /// Gets column
  int get col => position.col;

  /// Checks if hint is definitive (only one option)
  bool get isDefinitive => validNumbers.length == 1;

  /// Gets difficulty of hint (based on alternatives)
  HintDifficulty get difficulty {
    if (alternativeCount == 0) {
      return HintDifficulty.easy;
    } else if (alternativeCount <= 2) {
      return HintDifficulty.medium;
    } else if (alternativeCount <= 5) {
      return HintDifficulty.hard;
    } else {
      return HintDifficulty.veryHard;
    }
  }
}

/// Hint strategy
enum HintStrategy {
  random,
  easiest,
  nakedSingle,
  fewOptions,
  specific;

  String get label {
    switch (this) {
      case HintStrategy.random:
        return 'Aleatório';
      case HintStrategy.easiest:
        return 'Mais Fácil';
      case HintStrategy.nakedSingle:
        return 'Número Único';
      case HintStrategy.fewOptions:
        return 'Poucas Opções';
      case HintStrategy.specific:
        return 'Específico';
    }
  }
}

/// Hint difficulty
enum HintDifficulty {
  easy,
  medium,
  hard,
  veryHard;

  String get label {
    switch (this) {
      case HintDifficulty.easy:
        return 'Fácil';
      case HintDifficulty.medium:
        return 'Médio';
      case HintDifficulty.hard:
        return 'Difícil';
      case HintDifficulty.veryHard:
        return 'Muito Difícil';
    }
  }
}

/// Hint need assessment
class HintNeedAssessment {
  final HintNeedLevel needLevel;
  final int emptyCells;
  final int cellsWithMoves;
  final int nakedSingles;
  final bool isStuck;

  const HintNeedAssessment({
    required this.needLevel,
    required this.emptyCells,
    required this.cellsWithMoves,
    required this.nakedSingles,
    required this.isStuck,
  });

  /// Gets recommendation message
  String get recommendation {
    switch (needLevel) {
      case HintNeedLevel.stuck:
        return 'Puzzle sem solução! Considere reiniciar.';
      case HintNeedLevel.critical:
        return 'Situação crítica! Use uma dica.';
      case HintNeedLevel.high:
        return 'Considere usar uma dica.';
      case HintNeedLevel.medium:
        return 'Dica disponível se necessário.';
      case HintNeedLevel.low:
        return 'Continue! Há movimentos óbvios.';
    }
  }
}

/// Hint need level
enum HintNeedLevel {
  stuck,
  critical,
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case HintNeedLevel.stuck:
        return 'Travado';
      case HintNeedLevel.critical:
        return 'Crítico';
      case HintNeedLevel.high:
        return 'Alto';
      case HintNeedLevel.medium:
        return 'Médio';
      case HintNeedLevel.low:
        return 'Baixo';
    }
  }
}

/// Hint statistics
class HintStatistics {
  final int totalHintsAvailable;
  final int nakedSingles;
  final int hiddenSingles;
  final int totalValidMoves;
  final double averageOptionsPerCell;
  final HintNeedLevel needLevel;
  final bool isStuck;

  const HintStatistics({
    required this.totalHintsAvailable,
    required this.nakedSingles,
    required this.hiddenSingles,
    required this.totalValidMoves,
    required this.averageOptionsPerCell,
    required this.needLevel,
    required this.isStuck,
  });

  /// Gets hint availability status
  String get availabilityStatus {
    if (isStuck) {
      return 'Sem dicas disponíveis';
    } else if (nakedSingles > 0) {
      return '$nakedSingles dicas óbvias disponíveis';
    } else if (totalHintsAvailable > 0) {
      return '$totalHintsAvailable dicas disponíveis';
    } else {
      return 'Nenhuma dica disponível';
    }
  }
}

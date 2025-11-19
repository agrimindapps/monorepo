import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:core/core.dart';
import '../entities/enums.dart';
import '../entities/sudoku_grid_entity.dart';
import '../services/puzzle_generator_service.dart';

/// Use case for generating a new Sudoku puzzle
///
/// Delegates generation logic to [PuzzleGeneratorService]
@injectable
class GeneratePuzzleUseCase {
  final PuzzleGeneratorService _puzzleGeneratorService;

  GeneratePuzzleUseCase(this._puzzleGeneratorService);

  /// Generate a new puzzle
  /// Returns Either<Failure, SudokuGridEntity>
  Future<Either<Failure, SudokuGridEntity>> call(
    GameDifficulty difficulty,
  ) async {
    try {
      final puzzle = _puzzleGeneratorService.generatePuzzle(
        difficulty: difficulty,
      );

      if (puzzle == null) {
        return const Left(UnexpectedFailure('Failed to generate puzzle'));
      }

      return Right(puzzle);
    } catch (e) {
      return Left(UnexpectedFailure('Error generating puzzle: $e'));
    }
  }
}

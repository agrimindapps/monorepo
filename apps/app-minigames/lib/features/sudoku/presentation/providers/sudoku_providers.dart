import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/sudoku_local_datasource.dart';
import '../../data/repositories/sudoku_repository_impl.dart';
import '../../domain/repositories/sudoku_repository.dart';
import '../../domain/services/conflict_manager_service.dart';
import '../../domain/services/grid_validation_service.dart';
import '../../domain/services/hint_generator_service.dart';
import '../../domain/services/puzzle_generator_service.dart';
import '../../domain/usecases/check_completion_usecase.dart';
import '../../domain/usecases/generate_puzzle_usecase.dart';
import '../../domain/usecases/get_hint_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/place_number_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import '../../domain/usecases/toggle_notes_usecase.dart';
import '../../domain/usecases/update_conflicts_usecase.dart';
import '../../domain/usecases/validate_move_usecase.dart';

part 'sudoku_providers.g.dart';

// Data Sources

@riverpod
SudokuLocalDataSource sudokuLocalDataSource(SudokuLocalDataSourceRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SudokuLocalDataSource(prefs);
}

// Repositories

@Riverpod(keepAlive: true)
SudokuRepository sudokuRepository(SudokuRepositoryRef ref) {
  final dataSource = ref.watch(sudokuLocalDataSourceProvider);
  return SudokuRepositoryImpl(dataSource);
}

// Services

@riverpod
PuzzleGeneratorService puzzleGeneratorService(
  PuzzleGeneratorServiceRef ref,
) {
  return PuzzleGeneratorService();
}

@riverpod
GridValidationService gridValidationService(GridValidationServiceRef ref) {
  return GridValidationService();
}

@riverpod
ConflictManagerService conflictManagerService(
  ConflictManagerServiceRef ref,
) {
  final gridValidation = ref.watch(gridValidationServiceProvider);
  return ConflictManagerService(gridValidation);
}

@riverpod
HintGeneratorService hintGeneratorService(HintGeneratorServiceRef ref) {
  final gridValidation = ref.watch(gridValidationServiceProvider);
  return HintGeneratorService(gridValidation);
}

// Use Cases - Pure logic

@riverpod
UpdateConflictsUseCase updateConflictsUseCase(
  UpdateConflictsUseCaseRef ref,
) {
  return UpdateConflictsUseCase();
}

@riverpod
ToggleNotesUseCase toggleNotesUseCase(ToggleNotesUseCaseRef ref) {
  return ToggleNotesUseCase();
}

@riverpod
GetHintUseCase getHintUseCase(GetHintUseCaseRef ref) {
  return GetHintUseCase();
}

@riverpod
CheckCompletionUseCase checkCompletionUseCase(
  CheckCompletionUseCaseRef ref,
) {
  return CheckCompletionUseCase();
}

// Use Cases - With dependencies

@riverpod
GeneratePuzzleUseCase generatePuzzleUseCase(GeneratePuzzleUseCaseRef ref) {
  final service = ref.watch(puzzleGeneratorServiceProvider);
  return GeneratePuzzleUseCase(service);
}

@riverpod
ValidateMoveUseCase validateMoveUseCase(ValidateMoveUseCaseRef ref) {
  final service = ref.watch(gridValidationServiceProvider);
  return ValidateMoveUseCase(service);
}

@riverpod
PlaceNumberUseCase placeNumberUseCase(PlaceNumberUseCaseRef ref) {
  final validateMoveUseCase = ref.watch(validateMoveUseCaseProvider);
  final updateConflictsUseCase = ref.watch(updateConflictsUseCaseProvider);
  return PlaceNumberUseCase(validateMoveUseCase, updateConflictsUseCase);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(LoadHighScoreUseCaseRef ref) {
  final repository = ref.watch(sudokuRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(SaveHighScoreUseCaseRef ref) {
  final repository = ref.watch(sudokuRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

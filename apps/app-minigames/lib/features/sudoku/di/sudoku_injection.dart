import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/sudoku_local_datasource.dart';
import '../data/repositories/sudoku_repository_impl.dart';
import '../domain/repositories/sudoku_repository.dart';
import '../domain/services/grid_validation_service.dart';
import '../domain/services/puzzle_generator_service.dart';
import '../domain/usecases/check_completion_usecase.dart';
import '../domain/usecases/generate_puzzle_usecase.dart';
import '../domain/usecases/get_hint_usecase.dart';
import '../domain/usecases/load_high_score_usecase.dart';
import '../domain/usecases/place_number_usecase.dart';
import '../domain/usecases/save_high_score_usecase.dart';
import '../domain/usecases/toggle_notes_usecase.dart';
import '../domain/usecases/update_conflicts_usecase.dart';
import '../domain/usecases/validate_move_usecase.dart';

@module
abstract class SudokuModule {
  // Data Sources
  @singleton
  SudokuLocalDataSource sudokuLocalDataSource(SharedPreferences prefs) {
    return SudokuLocalDataSource(prefs);
  }

  // Repositories
  @Singleton(as: SudokuRepository)
  SudokuRepositoryImpl sudokuRepository(SudokuLocalDataSource dataSource) {
    return SudokuRepositoryImpl(dataSource);
  }

  // Use Cases - Pure logic (no dependencies)
  @injectable
  UpdateConflictsUseCase get updateConflictsUseCase => UpdateConflictsUseCase();

  @injectable
  ToggleNotesUseCase get toggleNotesUseCase => ToggleNotesUseCase();

  @injectable
  GetHintUseCase get getHintUseCase => GetHintUseCase();

  @injectable
  CheckCompletionUseCase get checkCompletionUseCase => CheckCompletionUseCase();

  // Use Cases - With repository dependencies
  @injectable
  PlaceNumberUseCase placeNumberUseCase(
    ValidateMoveUseCase validateMoveUseCase,
    UpdateConflictsUseCase updateConflictsUseCase,
  ) {
    return PlaceNumberUseCase(validateMoveUseCase, updateConflictsUseCase);
  }

  @injectable
  LoadHighScoreUseCase loadHighScoreUseCase(SudokuRepository repository) {
    return LoadHighScoreUseCase(repository);
  }

  @injectable
  SaveHighScoreUseCase saveHighScoreUseCase(SudokuRepository repository) {
    return SaveHighScoreUseCase(repository);
  }
}

/// Initialize Sudoku feature dependencies
Future<void> initSudokuDependencies(GetIt getIt) async {
  // Register SharedPreferences if not already registered
  if (!getIt.isRegistered<SharedPreferences>()) {
    final prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);
  }

  // Data Sources
  getIt.registerSingleton<SudokuLocalDataSource>(
    SudokuLocalDataSource(getIt<SharedPreferences>()),
  );

  // Repositories
  getIt.registerSingleton<SudokuRepository>(
    SudokuRepositoryImpl(getIt<SudokuLocalDataSource>()),
  );

  // Services
  getIt.registerLazySingleton<PuzzleGeneratorService>(
    () => PuzzleGeneratorService(),
  );
  getIt.registerLazySingleton<GridValidationService>(
    () => GridValidationService(),
  );

  // Use Cases - Pure logic
  getIt.registerFactory<GeneratePuzzleUseCase>(
    () => GeneratePuzzleUseCase(getIt<PuzzleGeneratorService>()),
  );
  getIt.registerFactory<ValidateMoveUseCase>(
    () => ValidateMoveUseCase(getIt<GridValidationService>()),
  );
  getIt.registerFactory<UpdateConflictsUseCase>(() => UpdateConflictsUseCase());
  getIt.registerFactory<ToggleNotesUseCase>(() => ToggleNotesUseCase());
  getIt.registerFactory<GetHintUseCase>(() => GetHintUseCase());
  getIt.registerFactory<CheckCompletionUseCase>(() => CheckCompletionUseCase());

  // Use Cases - With dependencies
  getIt.registerFactory<PlaceNumberUseCase>(
    () => PlaceNumberUseCase(
      getIt<ValidateMoveUseCase>(),
      getIt<UpdateConflictsUseCase>(),
    ),
  );

  getIt.registerFactory<LoadHighScoreUseCase>(
    () => LoadHighScoreUseCase(getIt<SudokuRepository>()),
  );

  getIt.registerFactory<SaveHighScoreUseCase>(
    () => SaveHighScoreUseCase(getIt<SudokuRepository>()),
  );
}

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/caca_palavra_local_data_source.dart';
import '../data/repositories/caca_palavra_repository_impl.dart';
import '../domain/repositories/caca_palavra_repository.dart';
import '../domain/usecases/generate_grid_usecase.dart';
import '../domain/usecases/select_cell_usecase.dart';
import '../domain/usecases/check_word_match_usecase.dart';
import '../domain/usecases/toggle_word_highlight_usecase.dart';
import '../domain/usecases/restart_game_usecase.dart';
import '../domain/usecases/load_high_score_usecase.dart';
import '../domain/usecases/save_high_score_usecase.dart';

/// Registers all dependencies for Caça Palavra feature
@module
abstract class CacaPalavraModule {
  // Data Sources
  @lazySingleton
  CacaPalavraLocalDataSource provideLocalDataSource(
    SharedPreferences prefs,
  ) =>
      CacaPalavraLocalDataSource(prefs);

  // Repositories
  @LazySingleton(as: CacaPalavraRepository)
  CacaPalavraRepositoryImpl provideRepository(
    CacaPalavraLocalDataSource localDataSource,
  ) =>
      CacaPalavraRepositoryImpl(localDataSource);

  // Use Cases
  @lazySingleton
  GenerateGridUseCase provideGenerateGridUseCase(
    CacaPalavraRepository repository,
  ) =>
      GenerateGridUseCase(repository);

  @lazySingleton
  SelectCellUseCase provideSelectCellUseCase() => SelectCellUseCase();

  @lazySingleton
  CheckWordMatchUseCase provideCheckWordMatchUseCase() =>
      CheckWordMatchUseCase();

  @lazySingleton
  ToggleWordHighlightUseCase provideToggleWordHighlightUseCase() =>
      ToggleWordHighlightUseCase();

  @lazySingleton
  RestartGameUseCase provideRestartGameUseCase(
    CacaPalavraRepository repository,
    GenerateGridUseCase generateGridUseCase,
  ) =>
      RestartGameUseCase(repository, generateGridUseCase);

  @lazySingleton
  LoadHighScoreUseCase provideLoadHighScoreUseCase(
    CacaPalavraRepository repository,
  ) =>
      LoadHighScoreUseCase(repository);

  @lazySingleton
  SaveHighScoreUseCase provideSaveHighScoreUseCase(
    CacaPalavraRepository repository,
  ) =>
      SaveHighScoreUseCase(repository);
}

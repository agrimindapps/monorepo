import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/caca_palavra_local_data_source.dart';
import '../../data/repositories/caca_palavra_repository_impl.dart';
import '../../domain/repositories/caca_palavra_repository.dart';
import '../../domain/services/grid_generator_service.dart';
import '../../domain/services/word_dictionary_service.dart';
import '../../domain/services/word_selection_service.dart';
import '../../domain/usecases/check_word_match_usecase.dart';
import '../../domain/usecases/generate_grid_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/restart_game_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import '../../domain/usecases/select_cell_usecase.dart';
import '../../domain/usecases/toggle_word_highlight_usecase.dart';

part 'caca_palavra_providers.g.dart';

// Data Sources

@riverpod
CacaPalavraLocalDataSource cacaPalavraLocalDataSource(
  CacaPalavraLocalDataSourceRef ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CacaPalavraLocalDataSource(prefs);
}

// Repositories

@Riverpod(keepAlive: true)
CacaPalavraRepository cacaPalavraRepository(CacaPalavraRepositoryRef ref) {
  final dataSource = ref.watch(cacaPalavraLocalDataSourceProvider);
  return CacaPalavraRepositoryImpl(dataSource);
}

// Services

@riverpod
WordDictionaryService wordDictionaryService(WordDictionaryServiceRef ref) {
  return WordDictionaryService();
}

@riverpod
WordSelectionService wordSelectionService(WordSelectionServiceRef ref) {
  return WordSelectionService();
}

@riverpod
GridGeneratorService gridGeneratorService(GridGeneratorServiceRef ref) {
  return GridGeneratorService();
}

// Use Cases

@riverpod
GenerateGridUseCase generateGridUseCase(GenerateGridUseCaseRef ref) {
  final repository = ref.watch(cacaPalavraRepositoryProvider);
  return GenerateGridUseCase(repository);
}

@riverpod
SelectCellUseCase selectCellUseCase(SelectCellUseCaseRef ref) {
  return SelectCellUseCase();
}

@riverpod
CheckWordMatchUseCase checkWordMatchUseCase(CheckWordMatchUseCaseRef ref) {
  return CheckWordMatchUseCase();
}

@riverpod
ToggleWordHighlightUseCase toggleWordHighlightUseCase(
  ToggleWordHighlightUseCaseRef ref,
) {
  return ToggleWordHighlightUseCase();
}

@riverpod
RestartGameUseCase restartGameUseCase(RestartGameUseCaseRef ref) {
  final repository = ref.watch(cacaPalavraRepositoryProvider);
  final generateGridUseCase = ref.watch(generateGridUseCaseProvider);
  return RestartGameUseCase(repository, generateGridUseCase);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(LoadHighScoreUseCaseRef ref) {
  final repository = ref.watch(cacaPalavraRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(SaveHighScoreUseCaseRef ref) {
  final repository = ref.watch(cacaPalavraRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

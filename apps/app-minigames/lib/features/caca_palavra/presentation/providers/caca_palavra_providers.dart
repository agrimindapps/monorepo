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
CacaPalavraLocalDataSource cacaPalavraLocalDataSource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CacaPalavraLocalDataSource(prefs);
}

// Repositories

@Riverpod(keepAlive: true)
CacaPalavraRepository cacaPalavraRepository(Ref ref) {
  final dataSource = ref.watch(cacaPalavraLocalDataSourceProvider);
  return CacaPalavraRepositoryImpl(dataSource);
}

// Services

@riverpod
WordDictionaryService wordDictionaryService(Ref ref) {
  return WordDictionaryService();
}

@riverpod
WordSelectionService wordSelectionService(Ref ref) {
  return WordSelectionService();
}

@riverpod
GridGeneratorService gridGeneratorService(Ref ref) {
  return GridGeneratorService();
}

// Use Cases

@riverpod
GenerateGridUseCase generateGridUseCase(Ref ref) {
  final repository = ref.watch(cacaPalavraRepositoryProvider);
  return GenerateGridUseCase(repository);
}

@riverpod
SelectCellUseCase selectCellUseCase(Ref ref) {
  return SelectCellUseCase();
}

@riverpod
CheckWordMatchUseCase checkWordMatchUseCase(Ref ref) {
  return CheckWordMatchUseCase();
}

@riverpod
ToggleWordHighlightUseCase toggleWordHighlightUseCase(Ref ref) {
  return ToggleWordHighlightUseCase();
}

@riverpod
RestartGameUseCase restartGameUseCase(Ref ref) {
  final repository = ref.watch(cacaPalavraRepositoryProvider);
  final generateGridUseCase = ref.watch(generateGridUseCaseProvider);
  return RestartGameUseCase(repository, generateGridUseCase);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(Ref ref) {
  final repository = ref.watch(cacaPalavraRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(Ref ref) {
  final repository = ref.watch(cacaPalavraRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

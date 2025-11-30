import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/memory_local_datasource.dart';
import '../../data/repositories/memory_repository_impl.dart';
import '../../domain/repositories/memory_repository.dart';
import '../../domain/usecases/check_match_usecase.dart';
import '../../domain/usecases/flip_card_usecase.dart';
import '../../domain/usecases/generate_cards_usecase.dart';
import '../../domain/usecases/load_high_score_usecase.dart';
import '../../domain/usecases/restart_game_usecase.dart';
import '../../domain/usecases/save_high_score_usecase.dart';
import '../../../../core/providers/core_providers.dart';

part 'memory_providers.g.dart';

// =========================================================================
// DATA SOURCES
// =========================================================================

@riverpod
MemoryLocalDataSource memoryLocalDataSource(Ref ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return MemoryLocalDataSourceImpl(sharedPrefs);
}

// =========================================================================
// REPOSITORIES
// =========================================================================

@riverpod
MemoryRepository memoryRepository(Ref ref) {
  final dataSource = ref.watch(memoryLocalDataSourceProvider);
  return MemoryRepositoryImpl(dataSource);
}

// =========================================================================
// USE CASES
// =========================================================================

@riverpod
GenerateCardsUseCase generateCardsUseCase(Ref ref) {
  return GenerateCardsUseCase();
}

@riverpod
FlipCardUseCase flipCardUseCase(Ref ref) {
  return FlipCardUseCase();
}

@riverpod
CheckMatchUseCase checkMatchUseCase(Ref ref) {
  return CheckMatchUseCase();
}

@riverpod
RestartGameUseCase restartGameUseCase(Ref ref) {
  final generateCards = ref.watch(generateCardsUseCaseProvider);
  return RestartGameUseCase(generateCards);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(Ref ref) {
  final repository = ref.watch(memoryRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(Ref ref) {
  final repository = ref.watch(memoryRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

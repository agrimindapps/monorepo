import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
MemoryLocalDataSource memoryLocalDataSource(MemoryLocalDataSourceRef ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return MemoryLocalDataSourceImpl(sharedPrefs);
}

// =========================================================================
// REPOSITORIES
// =========================================================================

@riverpod
MemoryRepository memoryRepository(MemoryRepositoryRef ref) {
  final dataSource = ref.watch(memoryLocalDataSourceProvider);
  return MemoryRepositoryImpl(dataSource);
}

// =========================================================================
// USE CASES
// =========================================================================

@riverpod
GenerateCardsUseCase generateCardsUseCase(GenerateCardsUseCaseRef ref) {
  return GenerateCardsUseCase();
}

@riverpod
FlipCardUseCase flipCardUseCase(FlipCardUseCaseRef ref) {
  return FlipCardUseCase();
}

@riverpod
CheckMatchUseCase checkMatchUseCase(CheckMatchUseCaseRef ref) {
  return CheckMatchUseCase();
}

@riverpod
RestartGameUseCase restartGameUseCase(RestartGameUseCaseRef ref) {
  final generateCards = ref.watch(generateCardsUseCaseProvider);
  return RestartGameUseCase(generateCards);
}

@riverpod
LoadHighScoreUseCase loadHighScoreUseCase(LoadHighScoreUseCaseRef ref) {
  final repository = ref.watch(memoryRepositoryProvider);
  return LoadHighScoreUseCase(repository);
}

@riverpod
SaveHighScoreUseCase saveHighScoreUseCase(SaveHighScoreUseCaseRef ref) {
  final repository = ref.watch(memoryRepositoryProvider);
  return SaveHighScoreUseCase(repository);
}

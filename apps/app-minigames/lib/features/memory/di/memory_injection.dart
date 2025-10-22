import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/memory_local_datasource.dart';
import '../data/repositories/memory_repository_impl.dart';
import '../domain/repositories/memory_repository.dart';
import '../domain/usecases/check_match_usecase.dart';
import '../domain/usecases/flip_card_usecase.dart';
import '../domain/usecases/generate_cards_usecase.dart';
import '../domain/usecases/load_high_score_usecase.dart';
import '../domain/usecases/restart_game_usecase.dart';
import '../domain/usecases/save_high_score_usecase.dart';

@module
abstract class MemoryModule {
  @lazySingleton
  MemoryLocalDataSource memoryLocalDataSource(SharedPreferences prefs) {
    return MemoryLocalDataSourceImpl(prefs);
  }

  @lazySingleton
  MemoryRepository memoryRepository(MemoryLocalDataSource dataSource) {
    return MemoryRepositoryImpl(dataSource);
  }

  @lazySingleton
  GenerateCardsUseCase generateCardsUseCase() {
    return GenerateCardsUseCase();
  }

  @lazySingleton
  FlipCardUseCase flipCardUseCase() {
    return FlipCardUseCase();
  }

  @lazySingleton
  CheckMatchUseCase checkMatchUseCase() {
    return CheckMatchUseCase();
  }

  @lazySingleton
  RestartGameUseCase restartGameUseCase(GenerateCardsUseCase generateCards) {
    return RestartGameUseCase(generateCards);
  }

  @lazySingleton
  LoadHighScoreUseCase loadHighScoreUseCase(MemoryRepository repository) {
    return LoadHighScoreUseCase(repository);
  }

  @lazySingleton
  SaveHighScoreUseCase saveHighScoreUseCase(MemoryRepository repository) {
    return SaveHighScoreUseCase(repository);
  }
}

Future<void> initMemoryDI(GetIt sl) async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<MemoryLocalDataSource>(
    () => MemoryLocalDataSourceImpl(prefs),
  );

  sl.registerLazySingleton<MemoryRepository>(
    () => MemoryRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GenerateCardsUseCase());
  sl.registerLazySingleton(() => FlipCardUseCase());
  sl.registerLazySingleton(() => CheckMatchUseCase());
  sl.registerLazySingleton(() => RestartGameUseCase(sl()));
  sl.registerLazySingleton(() => LoadHighScoreUseCase(sl()));
  sl.registerLazySingleton(() => SaveHighScoreUseCase(sl()));
}

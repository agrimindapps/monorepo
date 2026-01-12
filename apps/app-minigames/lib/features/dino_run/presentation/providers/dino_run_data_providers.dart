import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/dino_run_local_datasource.dart';
import '../../data/repositories/dino_run_score_repository_impl.dart';
import '../../data/repositories/dino_run_stats_repository_impl.dart';
import '../../data/repositories/dino_run_settings_repository_impl.dart';
import '../../domain/entities/dino_run_score.dart';
import '../../domain/entities/dino_run_stats.dart';
import '../../domain/entities/dino_run_settings.dart';
import '../../domain/repositories/i_dino_run_score_repository.dart';
import '../../domain/repositories/i_dino_run_stats_repository.dart';
import '../../domain/repositories/i_dino_run_settings_repository.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/manage_settings_usecase.dart';
import '../../domain/usecases/save_score_usecase.dart';
import 'dino_run_dependencies.dart';

part 'dino_run_data_providers.g.dart';

@riverpod
DinoRunLocalDatasource dinoRunLocalDatasource(Ref ref) {
  final prefs = ref.watch(dinoRunSharedPreferencesProvider);
  return DinoRunLocalDatasource(prefs);
}

@riverpod
IDinoRunScoreRepository dinoRunScoreRepository(Ref ref) {
  final datasource = ref.watch(dinoRunLocalDatasourceProvider);
  return DinoRunScoreRepositoryImpl(datasource);
}

@riverpod
IDinoRunStatsRepository dinoRunStatsRepository(Ref ref) {
  final datasource = ref.watch(dinoRunLocalDatasourceProvider);
  return DinoRunStatsRepositoryImpl(datasource);
}

@riverpod
IDinoRunSettingsRepository dinoRunSettingsRepository(Ref ref) {
  final datasource = ref.watch(dinoRunLocalDatasourceProvider);
  return DinoRunSettingsRepositoryImpl(datasource);
}

@riverpod
SaveScoreUseCase saveScoreUseCase(Ref ref) {
  final scoreRepo = ref.watch(dinoRunScoreRepositoryProvider);
  final statsRepo = ref.watch(dinoRunStatsRepositoryProvider);
  return SaveScoreUseCase(scoreRepo, statsRepo);
}

@riverpod
GetHighScoresUseCase getHighScoresUseCase(Ref ref) {
  final repo = ref.watch(dinoRunScoreRepositoryProvider);
  return GetHighScoresUseCase(repo);
}

@riverpod
GetStatsUseCase getStatsUseCase(Ref ref) {
  final repo = ref.watch(dinoRunStatsRepositoryProvider);
  return GetStatsUseCase(repo);
}

@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  final repo = ref.watch(dinoRunSettingsRepositoryProvider);
  return ManageSettingsUseCase(repo);
}

@riverpod
Future<List<DinoRunScore>> dinoRunHighScores(Ref ref) async {
  final useCase = ref.watch(getHighScoresUseCaseProvider);
  return useCase();
}

@riverpod
Future<DinoRunStats> dinoRunStats(Ref ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return useCase();
}

@riverpod
Future<DinoRunSettings> dinoRunSettings(Ref ref) async {
  final useCase = ref.watch(manageSettingsUseCaseProvider);
  return useCase.getSettings();
}

@riverpod
class DinoRunScoreSaver extends _$DinoRunScoreSaver {
  @override
  FutureOr<void> build() {}

  Future<void> saveScore(DinoRunScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(saveScoreUseCaseProvider);
      await useCase(score);
      ref.invalidate(dinoRunHighScoresProvider);
      ref.invalidate(dinoRunStatsProvider);
    });
  }
}

@riverpod
class DinoRunScoreDeleter extends _$DinoRunScoreDeleter {
  @override
  FutureOr<void> build() {}

  Future<void> deleteScore(DinoRunScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(dinoRunScoreRepositoryProvider);
      await repo.deleteScore(score);
      ref.invalidate(dinoRunHighScoresProvider);
    });
  }
}

@riverpod
class DinoRunSettingsUpdater extends _$DinoRunSettingsUpdater {
  @override
  FutureOr<void> build() {}

  Future<void> updateSettings(DinoRunSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.saveSettings(settings);
      ref.invalidate(dinoRunSettingsProvider);
    });
  }
}

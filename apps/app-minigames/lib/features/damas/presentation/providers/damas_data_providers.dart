import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/damas_local_datasource.dart';
import '../../data/repositories/damas_score_repository_impl.dart';
import '../../data/repositories/damas_stats_repository_impl.dart';
import '../../data/repositories/damas_settings_repository_impl.dart';
import '../../domain/entities/damas_score.dart';
import '../../domain/entities/damas_stats.dart';
import '../../domain/entities/damas_settings.dart';
import '../../domain/repositories/i_damas_score_repository.dart';
import '../../domain/repositories/i_damas_stats_repository.dart';
import '../../domain/repositories/i_damas_settings_repository.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/manage_settings_usecase.dart';
import '../../domain/usecases/save_score_usecase.dart';
import 'damas_dependencies.dart';

part 'damas_data_providers.g.dart';

@riverpod
DamasLocalDatasource damasLocalDatasource(Ref ref) {
  final prefs = ref.watch(damasSharedPreferencesProvider);
  return DamasLocalDatasource(prefs);
}

@riverpod
IDamasScoreRepository damasScoreRepository(Ref ref) {
  final datasource = ref.watch(damasLocalDatasourceProvider);
  return DamasScoreRepositoryImpl(datasource);
}

@riverpod
IDamasStatsRepository damasStatsRepository(Ref ref) {
  final datasource = ref.watch(damasLocalDatasourceProvider);
  return DamasStatsRepositoryImpl(datasource);
}

@riverpod
IDamasSettingsRepository damasSettingsRepository(Ref ref) {
  final datasource = ref.watch(damasLocalDatasourceProvider);
  return DamasSettingsRepositoryImpl(datasource);
}

@riverpod
SaveScoreUseCase saveScoreUseCase(Ref ref) {
  final scoreRepo = ref.watch(damasScoreRepositoryProvider);
  final statsRepo = ref.watch(damasStatsRepositoryProvider);
  return SaveScoreUseCase(scoreRepo, statsRepo);
}

@riverpod
GetHighScoresUseCase getHighScoresUseCase(Ref ref) {
  final repo = ref.watch(damasScoreRepositoryProvider);
  return GetHighScoresUseCase(repo);
}

@riverpod
GetStatsUseCase getStatsUseCase(Ref ref) {
  final repo = ref.watch(damasStatsRepositoryProvider);
  return GetStatsUseCase(repo);
}

@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  final repo = ref.watch(damasSettingsRepositoryProvider);
  return ManageSettingsUseCase(repo);
}

@riverpod
Future<List<DamasScore>> damasHighScores(Ref ref) async {
  final useCase = ref.watch(getHighScoresUseCaseProvider);
  return useCase();
}

@riverpod
Future<DamasStats> damasStats(Ref ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return useCase();
}

@riverpod
Future<DamasSettings> damasSettings(Ref ref) async {
  final useCase = ref.watch(manageSettingsUseCaseProvider);
  return useCase.getSettings();
}

@riverpod
class DamasScoreSaver extends _$DamasScoreSaver {
  @override
  FutureOr<void> build() {}

  Future<void> saveScore(DamasScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(saveScoreUseCaseProvider);
      await useCase(score);
      ref.invalidate(damasHighScoresProvider);
      ref.invalidate(damasStatsProvider);
    });
  }
}

@riverpod
class DamasScoreDeleter extends _$DamasScoreDeleter {
  @override
  FutureOr<void> build() {}

  Future<void> deleteScore(DamasScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(damasScoreRepositoryProvider);
      await repo.deleteScore(score);
      ref.invalidate(damasHighScoresProvider);
    });
  }
}

@riverpod
class DamasSettingsUpdater extends _$DamasSettingsUpdater {
  @override
  FutureOr<void> build() {}

  Future<void> updateSettings(DamasSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.saveSettings(settings);
      ref.invalidate(damasSettingsProvider);
    });
  }
}

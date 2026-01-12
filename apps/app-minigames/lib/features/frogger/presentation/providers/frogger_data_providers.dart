import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/frogger_local_datasource.dart';
import '../../data/repositories/frogger_score_repository_impl.dart';
import '../../data/repositories/frogger_stats_repository_impl.dart';
import '../../data/repositories/frogger_settings_repository_impl.dart';
import '../../domain/entities/frogger_score.dart';
import '../../domain/entities/frogger_stats.dart';
import '../../domain/entities/frogger_settings.dart';
import '../../domain/repositories/i_frogger_score_repository.dart';
import '../../domain/repositories/i_frogger_stats_repository.dart';
import '../../domain/repositories/i_frogger_settings_repository.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/manage_settings_usecase.dart';
import '../../domain/usecases/save_score_usecase.dart';
import 'frogger_dependencies.dart';

part 'frogger_data_providers.g.dart';

@riverpod
FroggerLocalDatasource froggerLocalDatasource(Ref ref) {
  final prefs = ref.watch(froggerSharedPreferencesProvider);
  return FroggerLocalDatasource(prefs);
}

@riverpod
IFroggerScoreRepository froggerScoreRepository(Ref ref) {
  final datasource = ref.watch(froggerLocalDatasourceProvider);
  return FroggerScoreRepositoryImpl(datasource);
}

@riverpod
IFroggerStatsRepository froggerStatsRepository(Ref ref) {
  final datasource = ref.watch(froggerLocalDatasourceProvider);
  return FroggerStatsRepositoryImpl(datasource);
}

@riverpod
IFroggerSettingsRepository froggerSettingsRepository(Ref ref) {
  final datasource = ref.watch(froggerLocalDatasourceProvider);
  return FroggerSettingsRepositoryImpl(datasource);
}

@riverpod
SaveScoreUseCase saveScoreUseCase(Ref ref) {
  final scoreRepo = ref.watch(froggerScoreRepositoryProvider);
  final statsRepo = ref.watch(froggerStatsRepositoryProvider);
  return SaveScoreUseCase(scoreRepo, statsRepo);
}

@riverpod
GetHighScoresUseCase getHighScoresUseCase(Ref ref) {
  final repo = ref.watch(froggerScoreRepositoryProvider);
  return GetHighScoresUseCase(repo);
}

@riverpod
GetStatsUseCase getStatsUseCase(Ref ref) {
  final repo = ref.watch(froggerStatsRepositoryProvider);
  return GetStatsUseCase(repo);
}

@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  final repo = ref.watch(froggerSettingsRepositoryProvider);
  return ManageSettingsUseCase(repo);
}

@riverpod
Future<List<FroggerScore>> froggerHighScores(Ref ref) async {
  final useCase = ref.watch(getHighScoresUseCaseProvider);
  return useCase();
}

@riverpod
Future<FroggerStats> froggerStats(Ref ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return useCase();
}

@riverpod
Future<FroggerSettings> froggerSettings(Ref ref) async {
  final useCase = ref.watch(manageSettingsUseCaseProvider);
  return useCase.getSettings();
}

@riverpod
class FroggerScoreSaver extends _$FroggerScoreSaver {
  @override
  FutureOr<void> build() {}

  Future<void> saveScore(FroggerScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(saveScoreUseCaseProvider);
      await useCase(score);
      ref.invalidate(froggerHighScoresProvider);
      ref.invalidate(froggerStatsProvider);
    });
  }
}

@riverpod
class FroggerScoreDeleter extends _$FroggerScoreDeleter {
  @override
  FutureOr<void> build() {}

  Future<void> deleteScore(FroggerScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(froggerScoreRepositoryProvider);
      await repo.deleteScore(score);
      ref.invalidate(froggerHighScoresProvider);
    });
  }
}

@riverpod
class FroggerSettingsUpdater extends _$FroggerSettingsUpdater {
  @override
  FutureOr<void> build() {}

  Future<void> updateSettings(FroggerSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.saveSettings(settings);
      ref.invalidate(froggerSettingsProvider);
    });
  }
}

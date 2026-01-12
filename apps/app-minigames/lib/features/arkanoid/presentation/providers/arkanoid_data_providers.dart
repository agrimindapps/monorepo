import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/arkanoid_local_datasource.dart';
import '../../data/repositories/arkanoid_score_repository_impl.dart';
import '../../data/repositories/arkanoid_stats_repository_impl.dart';
import '../../data/repositories/arkanoid_settings_repository_impl.dart';
import '../../domain/entities/arkanoid_score.dart';
import '../../domain/entities/arkanoid_stats.dart';
import '../../domain/entities/arkanoid_settings.dart';
import '../../domain/repositories/i_arkanoid_score_repository.dart';
import '../../domain/repositories/i_arkanoid_stats_repository.dart';
import '../../domain/repositories/i_arkanoid_settings_repository.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/manage_settings_usecase.dart';
import '../../domain/usecases/save_score_usecase.dart';
import 'arkanoid_dependencies.dart';

part 'arkanoid_data_providers.g.dart';

@riverpod
ArkanoidLocalDatasource arkanoidLocalDatasource(Ref ref) {
  final prefs = ref.watch(arkanoidSharedPreferencesProvider);
  return ArkanoidLocalDatasource(prefs);
}

@riverpod
IArkanoidScoreRepository arkanoidScoreRepository(Ref ref) {
  final datasource = ref.watch(arkanoidLocalDatasourceProvider);
  return ArkanoidScoreRepositoryImpl(datasource);
}

@riverpod
IArkanoidStatsRepository arkanoidStatsRepository(Ref ref) {
  final datasource = ref.watch(arkanoidLocalDatasourceProvider);
  return ArkanoidStatsRepositoryImpl(datasource);
}

@riverpod
IArkanoidSettingsRepository arkanoidSettingsRepository(Ref ref) {
  final datasource = ref.watch(arkanoidLocalDatasourceProvider);
  return ArkanoidSettingsRepositoryImpl(datasource);
}

@riverpod
SaveScoreUseCase saveScoreUseCase(Ref ref) {
  final scoreRepo = ref.watch(arkanoidScoreRepositoryProvider);
  final statsRepo = ref.watch(arkanoidStatsRepositoryProvider);
  return SaveScoreUseCase(scoreRepo, statsRepo);
}

@riverpod
GetHighScoresUseCase getHighScoresUseCase(Ref ref) {
  final repo = ref.watch(arkanoidScoreRepositoryProvider);
  return GetHighScoresUseCase(repo);
}

@riverpod
GetStatsUseCase getStatsUseCase(Ref ref) {
  final repo = ref.watch(arkanoidStatsRepositoryProvider);
  return GetStatsUseCase(repo);
}

@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  final repo = ref.watch(arkanoidSettingsRepositoryProvider);
  return ManageSettingsUseCase(repo);
}

@riverpod
Future<List<ArkanoidScore>> arkanoidHighScores(Ref ref) async {
  final useCase = ref.watch(getHighScoresUseCaseProvider);
  return useCase();
}

@riverpod
Future<ArkanoidStats> arkanoidStats(Ref ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return useCase();
}

@riverpod
Future<ArkanoidSettings> arkanoidSettings(Ref ref) async {
  final useCase = ref.watch(manageSettingsUseCaseProvider);
  return useCase.getSettings();
}

@riverpod
class ArkanoidScoreSaver extends _$ArkanoidScoreSaver {
  @override
  FutureOr<void> build() {}

  Future<void> saveScore(ArkanoidScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(saveScoreUseCaseProvider);
      await useCase(score);
      ref.invalidate(arkanoidHighScoresProvider);
      ref.invalidate(arkanoidStatsProvider);
    });
  }
}

@riverpod
class ArkanoidScoreDeleter extends _$ArkanoidScoreDeleter {
  @override
  FutureOr<void> build() {}

  Future<void> deleteScore(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(arkanoidScoreRepositoryProvider);
      await repo.deleteScore(id);
      ref.invalidate(arkanoidHighScoresProvider);
    });
  }
}

@riverpod
class ArkanoidSettingsUpdater extends _$ArkanoidSettingsUpdater {
  @override
  FutureOr<void> build() {}

  Future<void> updateSettings(ArkanoidSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.saveSettings(settings);
      ref.invalidate(arkanoidSettingsProvider);
    });
  }
}

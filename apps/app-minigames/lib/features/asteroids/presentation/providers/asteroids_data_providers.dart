import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/asteroids_local_datasource.dart';
import '../../data/repositories/asteroids_score_repository_impl.dart';
import '../../data/repositories/asteroids_stats_repository_impl.dart';
import '../../data/repositories/asteroids_settings_repository_impl.dart';
import '../../domain/entities/asteroids_score.dart';
import '../../domain/entities/asteroids_stats.dart';
import '../../domain/entities/asteroids_settings.dart';
import '../../domain/repositories/i_asteroids_score_repository.dart';
import '../../domain/repositories/i_asteroids_stats_repository.dart';
import '../../domain/repositories/i_asteroids_settings_repository.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/manage_settings_usecase.dart';
import '../../domain/usecases/save_score_usecase.dart';
import 'asteroids_dependencies.dart';

part 'asteroids_data_providers.g.dart';

@riverpod
AsteroidsLocalDatasource asteroidsLocalDatasource(Ref ref) {
  final prefs = ref.watch(asteroidsSharedPreferencesProvider);
  return AsteroidsLocalDatasource(prefs);
}

@riverpod
IAsteroidsScoreRepository asteroidsScoreRepository(Ref ref) {
  final datasource = ref.watch(asteroidsLocalDatasourceProvider);
  return AsteroidsScoreRepositoryImpl(datasource);
}

@riverpod
IAsteroidsStatsRepository asteroidsStatsRepository(Ref ref) {
  final datasource = ref.watch(asteroidsLocalDatasourceProvider);
  return AsteroidsStatsRepositoryImpl(datasource);
}

@riverpod
IAsteroidsSettingsRepository asteroidsSettingsRepository(Ref ref) {
  final datasource = ref.watch(asteroidsLocalDatasourceProvider);
  return AsteroidsSettingsRepositoryImpl(datasource);
}

@riverpod
SaveScoreUseCase saveScoreUseCase(Ref ref) {
  final scoreRepo = ref.watch(asteroidsScoreRepositoryProvider);
  final statsRepo = ref.watch(asteroidsStatsRepositoryProvider);
  return SaveScoreUseCase(scoreRepo, statsRepo);
}

@riverpod
GetHighScoresUseCase getHighScoresUseCase(Ref ref) {
  final repo = ref.watch(asteroidsScoreRepositoryProvider);
  return GetHighScoresUseCase(repo);
}

@riverpod
GetStatsUseCase getStatsUseCase(Ref ref) {
  final repo = ref.watch(asteroidsStatsRepositoryProvider);
  return GetStatsUseCase(repo);
}

@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  final repo = ref.watch(asteroidsSettingsRepositoryProvider);
  return ManageSettingsUseCase(repo);
}

@riverpod
Future<List<AsteroidsScore>> asteroidsHighScores(Ref ref) async {
  final useCase = ref.watch(getHighScoresUseCaseProvider);
  return useCase();
}

@riverpod
Future<AsteroidsStats> asteroidsStats(Ref ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return useCase();
}

@riverpod
Future<AsteroidsSettings> asteroidsSettings(Ref ref) async {
  final useCase = ref.watch(manageSettingsUseCaseProvider);
  return useCase.getSettings();
}

@riverpod
class AsteroidsScoreSaver extends _$AsteroidsScoreSaver {
  @override
  FutureOr<void> build() {}

  Future<void> saveScore(AsteroidsScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(saveScoreUseCaseProvider);
      await useCase(score);
      ref.invalidate(asteroidsHighScoresProvider);
      ref.invalidate(asteroidsStatsProvider);
    });
  }
}

@riverpod
class AsteroidsScoreDeleter extends _$AsteroidsScoreDeleter {
  @override
  FutureOr<void> build() {}

  Future<void> deleteScore(AsteroidsScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(asteroidsScoreRepositoryProvider);
      await repo.deleteScore(score);
      ref.invalidate(asteroidsHighScoresProvider);
    });
  }
}

@riverpod
class AsteroidsSettingsUpdater extends _$AsteroidsSettingsUpdater {
  @override
  FutureOr<void> build() {}

  Future<void> updateSettings(AsteroidsSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.saveSettings(settings);
      ref.invalidate(asteroidsSettingsProvider);
    });
  }
}

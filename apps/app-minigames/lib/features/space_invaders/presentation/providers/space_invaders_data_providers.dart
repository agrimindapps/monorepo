import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/space_invaders_local_datasource.dart';
import '../../data/repositories/space_invaders_score_repository_impl.dart';
import '../../data/repositories/space_invaders_stats_repository_impl.dart';
import '../../data/repositories/space_invaders_settings_repository_impl.dart';
import '../../domain/entities/space_invaders_score.dart';
import '../../domain/entities/space_invaders_stats.dart';
import '../../domain/entities/space_invaders_settings.dart';
import '../../domain/repositories/i_space_invaders_score_repository.dart';
import '../../domain/repositories/i_space_invaders_stats_repository.dart';
import '../../domain/repositories/i_space_invaders_settings_repository.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/manage_settings_usecase.dart';
import '../../domain/usecases/save_score_usecase.dart';
import 'space_invaders_dependencies.dart';

part 'space_invaders_data_providers.g.dart';

@riverpod
SpaceInvadersLocalDatasource spaceInvadersLocalDatasource(Ref ref) {
  final prefs = ref.watch(spaceInvadersSharedPreferencesProvider);
  return SpaceInvadersLocalDatasource(prefs);
}

@riverpod
ISpaceInvadersScoreRepository spaceInvadersScoreRepository(Ref ref) {
  final datasource = ref.watch(spaceInvadersLocalDatasourceProvider);
  return SpaceInvadersScoreRepositoryImpl(datasource);
}

@riverpod
ISpaceInvadersStatsRepository spaceInvadersStatsRepository(Ref ref) {
  final datasource = ref.watch(spaceInvadersLocalDatasourceProvider);
  return SpaceInvadersStatsRepositoryImpl(datasource);
}

@riverpod
ISpaceInvadersSettingsRepository spaceInvadersSettingsRepository(Ref ref) {
  final datasource = ref.watch(spaceInvadersLocalDatasourceProvider);
  return SpaceInvadersSettingsRepositoryImpl(datasource);
}

@riverpod
SaveScoreUseCase saveScoreUseCase(Ref ref) {
  final scoreRepo = ref.watch(spaceInvadersScoreRepositoryProvider);
  final statsRepo = ref.watch(spaceInvadersStatsRepositoryProvider);
  return SaveScoreUseCase(scoreRepo, statsRepo);
}

@riverpod
GetHighScoresUseCase getHighScoresUseCase(Ref ref) {
  final repo = ref.watch(spaceInvadersScoreRepositoryProvider);
  return GetHighScoresUseCase(repo);
}

@riverpod
GetStatsUseCase getStatsUseCase(Ref ref) {
  final repo = ref.watch(spaceInvadersStatsRepositoryProvider);
  return GetStatsUseCase(repo);
}

@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  final repo = ref.watch(spaceInvadersSettingsRepositoryProvider);
  return ManageSettingsUseCase(repo);
}

@riverpod
Future<List<SpaceInvadersScore>> spaceInvadersHighScores(Ref ref) async {
  final useCase = ref.watch(getHighScoresUseCaseProvider);
  return useCase();
}

@riverpod
Future<SpaceInvadersStats> spaceInvadersStats(Ref ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return useCase();
}

@riverpod
Future<SpaceInvadersSettings> spaceInvadersSettings(Ref ref) async {
  final useCase = ref.watch(manageSettingsUseCaseProvider);
  return useCase.getSettings();
}

@riverpod
class SpaceInvadersScoreSaver extends _$SpaceInvadersScoreSaver {
  @override
  FutureOr<void> build() {}

  Future<void> saveScore(SpaceInvadersScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(saveScoreUseCaseProvider);
      await useCase(score);
      ref.invalidate(spaceInvadersHighScoresProvider);
      ref.invalidate(spaceInvadersStatsProvider);
    });
  }
}

@riverpod
class SpaceInvadersScoreDeleter extends _$SpaceInvadersScoreDeleter {
  @override
  FutureOr<void> build() {}

  Future<void> deleteScore(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(spaceInvadersScoreRepositoryProvider);
      await repo.deleteScore(id);
      ref.invalidate(spaceInvadersHighScoresProvider);
    });
  }
}

@riverpod
class SpaceInvadersSettingsUpdater extends _$SpaceInvadersSettingsUpdater {
  @override
  FutureOr<void> build() {}

  Future<void> updateSettings(SpaceInvadersSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.saveSettings(settings);
      ref.invalidate(spaceInvadersSettingsProvider);
    });
  }
}

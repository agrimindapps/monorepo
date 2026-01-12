import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/galaga_local_datasource.dart';
import '../../data/repositories/galaga_score_repository_impl.dart';
import '../../data/repositories/galaga_stats_repository_impl.dart';
import '../../data/repositories/galaga_settings_repository_impl.dart';
import '../../domain/entities/galaga_score.dart';
import '../../domain/entities/galaga_stats.dart';
import '../../domain/entities/galaga_settings.dart';
import '../../domain/repositories/i_galaga_score_repository.dart';
import '../../domain/repositories/i_galaga_stats_repository.dart';
import '../../domain/repositories/i_galaga_settings_repository.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/manage_settings_usecase.dart';
import '../../domain/usecases/save_score_usecase.dart';
import 'galaga_dependencies.dart';

part 'galaga_data_providers.g.dart';

@riverpod
GalagaLocalDatasource galagaLocalDatasource(Ref ref) {
  final prefs = ref.watch(galagaSharedPreferencesProvider);
  return GalagaLocalDatasource(prefs);
}

@riverpod
IGalagaScoreRepository galagaScoreRepository(Ref ref) {
  final datasource = ref.watch(galagaLocalDatasourceProvider);
  return GalagaScoreRepositoryImpl(datasource);
}

@riverpod
IGalagaStatsRepository galagaStatsRepository(Ref ref) {
  final datasource = ref.watch(galagaLocalDatasourceProvider);
  return GalagaStatsRepositoryImpl(datasource);
}

@riverpod
IGalagaSettingsRepository galagaSettingsRepository(Ref ref) {
  final datasource = ref.watch(galagaLocalDatasourceProvider);
  return GalagaSettingsRepositoryImpl(datasource);
}

@riverpod
SaveScoreUseCase saveScoreUseCase(Ref ref) {
  final scoreRepo = ref.watch(galagaScoreRepositoryProvider);
  final statsRepo = ref.watch(galagaStatsRepositoryProvider);
  return SaveScoreUseCase(scoreRepo, statsRepo);
}

@riverpod
GetHighScoresUseCase getHighScoresUseCase(Ref ref) {
  final repo = ref.watch(galagaScoreRepositoryProvider);
  return GetHighScoresUseCase(repo);
}

@riverpod
GetStatsUseCase getStatsUseCase(Ref ref) {
  final repo = ref.watch(galagaStatsRepositoryProvider);
  return GetStatsUseCase(repo);
}

@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  final repo = ref.watch(galagaSettingsRepositoryProvider);
  return ManageSettingsUseCase(repo);
}

@riverpod
Future<List<GalagaScore>> galagaHighScores(Ref ref) async {
  final useCase = ref.watch(getHighScoresUseCaseProvider);
  return useCase();
}

@riverpod
Future<GalagaStats> galagaStats(Ref ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return useCase();
}

@riverpod
Future<GalagaSettings> galagaSettings(Ref ref) async {
  final useCase = ref.watch(manageSettingsUseCaseProvider);
  return useCase.getSettings();
}

@riverpod
class GalagaScoreSaver extends _$GalagaScoreSaver {
  @override
  FutureOr<void> build() {}

  Future<void> saveScore(GalagaScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(saveScoreUseCaseProvider);
      await useCase(score);
      ref.invalidate(galagaHighScoresProvider);
      ref.invalidate(galagaStatsProvider);
    });
  }
}

@riverpod
class GalagaScoreDeleter extends _$GalagaScoreDeleter {
  @override
  FutureOr<void> build() {}

  Future<void> deleteScore(GalagaScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(galagaScoreRepositoryProvider);
      await repo.deleteScore(score);
      ref.invalidate(galagaHighScoresProvider);
    });
  }
}

@riverpod
class GalagaSettingsUpdater extends _$GalagaSettingsUpdater {
  @override
  FutureOr<void> build() {}

  Future<void> updateSettings(GalagaSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.saveSettings(settings);
      ref.invalidate(galagaSettingsProvider);
    });
  }
}

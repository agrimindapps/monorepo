import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/batalha_naval_local_datasource.dart';
import '../../data/repositories/batalha_naval_score_repository_impl.dart';
import '../../data/repositories/batalha_naval_stats_repository_impl.dart';
import '../../data/repositories/batalha_naval_settings_repository_impl.dart';
import '../../domain/entities/batalha_naval_score.dart';
import '../../domain/entities/batalha_naval_stats.dart';
import '../../domain/entities/batalha_naval_settings.dart';
import '../../domain/repositories/i_batalha_naval_score_repository.dart';
import '../../domain/repositories/i_batalha_naval_stats_repository.dart';
import '../../domain/repositories/i_batalha_naval_settings_repository.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/manage_settings_usecase.dart';
import '../../domain/usecases/save_score_usecase.dart';
import 'batalha_naval_dependencies.dart';

part 'batalha_naval_data_providers.g.dart';

@riverpod
BatalhaNavalLocalDatasource batalha_navalLocalDatasource(Ref ref) {
  final prefs = ref.watch(batalha_navalSharedPreferencesProvider);
  return BatalhaNavalLocalDatasource(prefs);
}

@riverpod
IBatalhaNavalScoreRepository batalha_navalScoreRepository(Ref ref) {
  final datasource = ref.watch(batalha_navalLocalDatasourceProvider);
  return BatalhaNavalScoreRepositoryImpl(datasource);
}

@riverpod
IBatalhaNavalStatsRepository batalha_navalStatsRepository(Ref ref) {
  final datasource = ref.watch(batalha_navalLocalDatasourceProvider);
  return BatalhaNavalStatsRepositoryImpl(datasource);
}

@riverpod
IBatalhaNavalSettingsRepository batalha_navalSettingsRepository(Ref ref) {
  final datasource = ref.watch(batalha_navalLocalDatasourceProvider);
  return BatalhaNavalSettingsRepositoryImpl(datasource);
}

@riverpod
SaveScoreUseCase saveScoreUseCase(Ref ref) {
  final scoreRepo = ref.watch(batalha_navalScoreRepositoryProvider);
  final statsRepo = ref.watch(batalha_navalStatsRepositoryProvider);
  return SaveScoreUseCase(scoreRepo, statsRepo);
}

@riverpod
GetHighScoresUseCase getHighScoresUseCase(Ref ref) {
  final repo = ref.watch(batalha_navalScoreRepositoryProvider);
  return GetHighScoresUseCase(repo);
}

@riverpod
GetStatsUseCase getStatsUseCase(Ref ref) {
  final repo = ref.watch(batalha_navalStatsRepositoryProvider);
  return GetStatsUseCase(repo);
}

@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  final repo = ref.watch(batalha_navalSettingsRepositoryProvider);
  return ManageSettingsUseCase(repo);
}

@riverpod
Future<List<BatalhaNavalScore>> batalha_navalHighScores(Ref ref) async {
  final useCase = ref.watch(getHighScoresUseCaseProvider);
  return useCase();
}

@riverpod
Future<BatalhaNavalStats> batalha_navalStats(Ref ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return useCase();
}

@riverpod
Future<BatalhaNavalSettings> batalha_navalSettings(Ref ref) async {
  final useCase = ref.watch(manageSettingsUseCaseProvider);
  return useCase.getSettings();
}

@riverpod
class BatalhaNavalScoreSaver extends _$BatalhaNavalScoreSaver {
  @override
  FutureOr<void> build() {}

  Future<void> saveScore(BatalhaNavalScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(saveScoreUseCaseProvider);
      await useCase(score);
      ref.invalidate(batalha_navalHighScoresProvider);
      ref.invalidate(batalha_navalStatsProvider);
    });
  }
}

@riverpod
class BatalhaNavalScoreDeleter extends _$BatalhaNavalScoreDeleter {
  @override
  FutureOr<void> build() {}

  Future<void> deleteScore(BatalhaNavalScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(batalha_navalScoreRepositoryProvider);
      await repo.deleteScore(score);
      ref.invalidate(batalha_navalHighScoresProvider);
    });
  }
}

@riverpod
class BatalhaNavalSettingsUpdater extends _$BatalhaNavalSettingsUpdater {
  @override
  FutureOr<void> build() {}

  Future<void> updateSettings(BatalhaNavalSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.saveSettings(settings);
      ref.invalidate(batalha_navalSettingsProvider);
    });
  }
}

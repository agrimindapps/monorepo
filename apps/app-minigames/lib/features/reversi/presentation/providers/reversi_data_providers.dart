import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/reversi_local_datasource.dart';
import '../../data/repositories/reversi_score_repository_impl.dart';
import '../../data/repositories/reversi_stats_repository_impl.dart';
import '../../data/repositories/reversi_settings_repository_impl.dart';
import '../../domain/entities/reversi_score.dart';
import '../../domain/entities/reversi_stats.dart';
import '../../domain/entities/reversi_settings.dart';
import '../../domain/repositories/i_reversi_score_repository.dart';
import '../../domain/repositories/i_reversi_stats_repository.dart';
import '../../domain/repositories/i_reversi_settings_repository.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/manage_settings_usecase.dart';
import '../../domain/usecases/save_score_usecase.dart';
import 'reversi_dependencies.dart';

part 'reversi_data_providers.g.dart';

// Datasource
@riverpod
ReversiLocalDatasource reversiLocalDatasource(Ref ref) {
  final prefs = ref.watch(reversiSharedPreferencesProvider);
  return ReversiLocalDatasource(prefs);
}

// Repositories
@riverpod
IReversiScoreRepository reversiScoreRepository(Ref ref) {
  final datasource = ref.watch(reversiLocalDatasourceProvider);
  return ReversiScoreRepositoryImpl(datasource);
}

@riverpod
IReversiStatsRepository reversiStatsRepository(Ref ref) {
  final datasource = ref.watch(reversiLocalDatasourceProvider);
  return ReversiStatsRepositoryImpl(datasource);
}

@riverpod
IReversiSettingsRepository reversiSettingsRepository(Ref ref) {
  final datasource = ref.watch(reversiLocalDatasourceProvider);
  return ReversiSettingsRepositoryImpl(datasource);
}

// Use Cases
@riverpod
SaveScoreUseCase saveScoreUseCase(Ref ref) {
  final scoreRepo = ref.watch(reversiScoreRepositoryProvider);
  final statsRepo = ref.watch(reversiStatsRepositoryProvider);
  return SaveScoreUseCase(scoreRepo, statsRepo);
}

@riverpod
GetHighScoresUseCase getHighScoresUseCase(Ref ref) {
  final repo = ref.watch(reversiScoreRepositoryProvider);
  return GetHighScoresUseCase(repo);
}

@riverpod
GetStatsUseCase getStatsUseCase(Ref ref) {
  final repo = ref.watch(reversiStatsRepositoryProvider);
  return GetStatsUseCase(repo);
}

@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  final repo = ref.watch(reversiSettingsRepositoryProvider);
  return ManageSettingsUseCase(repo);
}

// State Providers
@riverpod
Future<List<ReversiScore>> reversiHighScores(Ref ref) async {
  final useCase = ref.watch(getHighScoresUseCaseProvider);
  return useCase();
}

@riverpod
Future<ReversiStats> reversiStats(Ref ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return useCase();
}

@riverpod
Future<ReversiSettings> reversiSettings(Ref ref) async {
  final useCase = ref.watch(manageSettingsUseCaseProvider);
  return useCase.getSettings();
}

// Action Notifiers
@riverpod
class ReversiScoreSaver extends _$ReversiScoreSaver {
  @override
  FutureOr<void> build() {}

  Future<void> saveScore(ReversiScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(saveScoreUseCaseProvider);
      await useCase(score);
      ref.invalidate(reversiHighScoresProvider);
      ref.invalidate(reversiStatsProvider);
    });
  }
}

@riverpod
class ReversiScoreDeleter extends _$ReversiScoreDeleter {
  @override
  FutureOr<void> build() {}

  Future<void> deleteScore(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(reversiScoreRepositoryProvider);
      await repo.deleteScore(id);
      ref.invalidate(reversiHighScoresProvider);
    });
  }
}

@riverpod
class ReversiSettingsUpdater extends _$ReversiSettingsUpdater {
  @override
  FutureOr<void> build() {}

  Future<void> updateSettings(ReversiSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.saveSettings(settings);
      ref.invalidate(reversiSettingsProvider);
    });
  }
}

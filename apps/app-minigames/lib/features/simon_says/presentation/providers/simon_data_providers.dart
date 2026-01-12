import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/simon_local_datasource.dart';
import '../../data/repositories/simon_score_repository_impl.dart';
import '../../data/repositories/simon_stats_repository_impl.dart';
import '../../data/repositories/simon_settings_repository_impl.dart';
import '../../domain/entities/simon_score.dart';
import '../../domain/entities/simon_stats.dart';
import '../../domain/entities/simon_settings.dart';
import '../../domain/repositories/i_simon_score_repository.dart';
import '../../domain/repositories/i_simon_stats_repository.dart';
import '../../domain/repositories/i_simon_settings_repository.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/manage_settings_usecase.dart';
import '../../domain/usecases/save_score_usecase.dart';
import 'simon_dependencies.dart';

part 'simon_data_providers.g.dart';

// Datasource
@riverpod
SimonLocalDatasource simonLocalDatasource(Ref ref) {
  final prefs = ref.watch(simonSharedPreferencesProvider);
  return SimonLocalDatasource(prefs);
}

// Repositories
@riverpod
ISimonScoreRepository simonScoreRepository(Ref ref) {
  final datasource = ref.watch(simonLocalDatasourceProvider);
  return SimonScoreRepositoryImpl(datasource);
}

@riverpod
ISimonStatsRepository simonStatsRepository(Ref ref) {
  final datasource = ref.watch(simonLocalDatasourceProvider);
  return SimonStatsRepositoryImpl(datasource);
}

@riverpod
ISimonSettingsRepository simonSettingsRepository(Ref ref) {
  final datasource = ref.watch(simonLocalDatasourceProvider);
  return SimonSettingsRepositoryImpl(datasource);
}

// Use Cases
@riverpod
SaveScoreUseCase saveScoreUseCase(Ref ref) {
  final scoreRepo = ref.watch(simonScoreRepositoryProvider);
  final statsRepo = ref.watch(simonStatsRepositoryProvider);
  return SaveScoreUseCase(scoreRepo, statsRepo);
}

@riverpod
GetHighScoresUseCase getHighScoresUseCase(Ref ref) {
  final repo = ref.watch(simonScoreRepositoryProvider);
  return GetHighScoresUseCase(repo);
}

@riverpod
GetStatsUseCase getStatsUseCase(Ref ref) {
  final repo = ref.watch(simonStatsRepositoryProvider);
  return GetStatsUseCase(repo);
}

@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  final repo = ref.watch(simonSettingsRepositoryProvider);
  return ManageSettingsUseCase(repo);
}

// State Providers
@riverpod
Future<List<SimonScore>> simonHighScores(Ref ref) async {
  final useCase = ref.watch(getHighScoresUseCaseProvider);
  return useCase();
}

@riverpod
Future<SimonStats> simonStats(Ref ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return useCase();
}

@riverpod
Future<SimonSettings> simonSettings(Ref ref) async {
  final useCase = ref.watch(manageSettingsUseCaseProvider);
  return useCase.getSettings();
}

// Action Notifiers
@riverpod
class SimonScoreSaver extends _$SimonScoreSaver {
  @override
  FutureOr<void> build() {}

  Future<void> saveScore(SimonScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(saveScoreUseCaseProvider);
      await useCase(score);
      ref.invalidate(simonHighScoresProvider);
      ref.invalidate(simonStatsProvider);
    });
  }
}

@riverpod
class SimonScoreDeleter extends _$SimonScoreDeleter {
  @override
  FutureOr<void> build() {}

  Future<void> deleteScore(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(simonScoreRepositoryProvider);
      await repo.deleteScore(id);
      ref.invalidate(simonHighScoresProvider);
    });
  }
}

@riverpod
class SimonSettingsUpdater extends _$SimonSettingsUpdater {
  @override
  FutureOr<void> build() {}

  Future<void> updateSettings(SimonSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.saveSettings(settings);
      ref.invalidate(simonSettingsProvider);
    });
  }
}

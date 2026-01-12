import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local/connect_four_local_datasource.dart';
import '../../data/repositories/connect_four_score_repository_impl.dart';
import '../../data/repositories/connect_four_stats_repository_impl.dart';
import '../../data/repositories/connect_four_settings_repository_impl.dart';
import '../../domain/entities/connect_four_score.dart';
import '../../domain/entities/connect_four_stats.dart';
import '../../domain/entities/connect_four_settings.dart';
import '../../domain/repositories/i_connect_four_score_repository.dart';
import '../../domain/repositories/i_connect_four_stats_repository.dart';
import '../../domain/repositories/i_connect_four_settings_repository.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/manage_settings_usecase.dart';
import '../../domain/usecases/save_score_usecase.dart';
import 'connect_four_dependencies.dart';

part 'connect_four_data_providers.g.dart';

@riverpod
ConnectFourLocalDatasource connect_fourLocalDatasource(Ref ref) {
  final prefs = ref.watch(connect_fourSharedPreferencesProvider);
  return ConnectFourLocalDatasource(prefs);
}

@riverpod
IConnectFourScoreRepository connect_fourScoreRepository(Ref ref) {
  final datasource = ref.watch(connect_fourLocalDatasourceProvider);
  return ConnectFourScoreRepositoryImpl(datasource);
}

@riverpod
IConnectFourStatsRepository connect_fourStatsRepository(Ref ref) {
  final datasource = ref.watch(connect_fourLocalDatasourceProvider);
  return ConnectFourStatsRepositoryImpl(datasource);
}

@riverpod
IConnectFourSettingsRepository connect_fourSettingsRepository(Ref ref) {
  final datasource = ref.watch(connect_fourLocalDatasourceProvider);
  return ConnectFourSettingsRepositoryImpl(datasource);
}

@riverpod
SaveScoreUseCase saveScoreUseCase(Ref ref) {
  final scoreRepo = ref.watch(connect_fourScoreRepositoryProvider);
  final statsRepo = ref.watch(connect_fourStatsRepositoryProvider);
  return SaveScoreUseCase(scoreRepo, statsRepo);
}

@riverpod
GetHighScoresUseCase getHighScoresUseCase(Ref ref) {
  final repo = ref.watch(connect_fourScoreRepositoryProvider);
  return GetHighScoresUseCase(repo);
}

@riverpod
GetStatsUseCase getStatsUseCase(Ref ref) {
  final repo = ref.watch(connect_fourStatsRepositoryProvider);
  return GetStatsUseCase(repo);
}

@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  final repo = ref.watch(connect_fourSettingsRepositoryProvider);
  return ManageSettingsUseCase(repo);
}

@riverpod
Future<List<ConnectFourScore>> connect_fourHighScores(Ref ref) async {
  final useCase = ref.watch(getHighScoresUseCaseProvider);
  return useCase();
}

@riverpod
Future<ConnectFourStats> connect_fourStats(Ref ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return useCase();
}

@riverpod
Future<ConnectFourSettings> connect_fourSettings(Ref ref) async {
  final useCase = ref.watch(manageSettingsUseCaseProvider);
  return useCase.getSettings();
}

@riverpod
class ConnectFourScoreSaver extends _$ConnectFourScoreSaver {
  @override
  FutureOr<void> build() {}

  Future<void> saveScore(ConnectFourScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(saveScoreUseCaseProvider);
      await useCase(score);
      ref.invalidate(connect_fourHighScoresProvider);
      ref.invalidate(connect_fourStatsProvider);
    });
  }
}

@riverpod
class ConnectFourScoreDeleter extends _$ConnectFourScoreDeleter {
  @override
  FutureOr<void> build() {}

  Future<void> deleteScore(ConnectFourScore score) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(connect_fourScoreRepositoryProvider);
      await repo.deleteScore(score);
      ref.invalidate(connect_fourHighScoresProvider);
    });
  }
}

@riverpod
class ConnectFourSettingsUpdater extends _$ConnectFourSettingsUpdater {
  @override
  FutureOr<void> build() {}

  Future<void> updateSettings(ConnectFourSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.saveSettings(settings);
      ref.invalidate(connect_fourSettingsProvider);
    });
  }
}

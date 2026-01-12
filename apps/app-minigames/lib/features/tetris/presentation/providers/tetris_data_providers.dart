import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/tetris_score_repository_impl.dart';
import '../../data/repositories/tetris_settings_repository_impl.dart';
import '../../data/repositories/tetris_stats_repository_impl.dart';
import '../../domain/entities/tetris_score.dart';
import '../../domain/entities/tetris_settings.dart';
import '../../domain/entities/tetris_stats.dart';
import '../../domain/repositories/i_tetris_score_repository.dart';
import '../../domain/repositories/i_tetris_settings_repository.dart';
import '../../domain/repositories/i_tetris_stats_repository.dart';
import '../../domain/usecases/get_high_scores_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/manage_settings_usecase.dart';
import '../../domain/usecases/save_score_usecase.dart';
import 'tetris_dependencies.dart';

part 'tetris_data_providers.g.dart';

// ========== REPOSITORIES ==========

@riverpod
ITetrisScoreRepository tetrisScoreRepository(Ref ref) {
  final datasource = ref.watch(tetrisLocalDatasourceProvider);
  return TetrisScoreRepositoryImpl(datasource);
}

@riverpod
ITetrisStatsRepository tetrisStatsRepository(Ref ref) {
  final datasource = ref.watch(tetrisLocalDatasourceProvider);
  return TetrisStatsRepositoryImpl(datasource);
}

@riverpod
ITetrisSettingsRepository tetrisSettingsRepository(Ref ref) {
  final datasource = ref.watch(tetrisLocalDatasourceProvider);
  return TetrisSettingsRepositoryImpl(datasource);
}

// ========== USE CASES ==========

@riverpod
SaveScoreUseCase saveScoreUseCase(Ref ref) {
  final scoreRepo = ref.watch(tetrisScoreRepositoryProvider);
  final statsRepo = ref.watch(tetrisStatsRepositoryProvider);
  return SaveScoreUseCase(scoreRepo, statsRepo);
}

@riverpod
GetHighScoresUseCase getHighScoresUseCase(Ref ref) {
  final repository = ref.watch(tetrisScoreRepositoryProvider);
  return GetHighScoresUseCase(repository);
}

@riverpod
GetStatsUseCase getStatsUseCase(Ref ref) {
  final repository = ref.watch(tetrisStatsRepositoryProvider);
  return GetStatsUseCase(repository);
}

@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  final repository = ref.watch(tetrisSettingsRepositoryProvider);
  return ManageSettingsUseCase(repository);
}

// ========== STATE PROVIDERS ==========

/// Provider para os high scores (top 10)
@riverpod
Future<List<TetrisScore>> tetrisHighScores(Ref ref) async {
  final useCase = ref.watch(getHighScoresUseCaseProvider);
  return useCase(limit: 10);
}

/// Provider para as estatísticas
@riverpod
Future<TetrisStats> tetrisStats(Ref ref) async {
  final useCase = ref.watch(getStatsUseCaseProvider);
  return useCase();
}

/// Provider para as configurações
@riverpod
Future<TetrisSettings> tetrisSettings(Ref ref) async {
  final useCase = ref.watch(manageSettingsUseCaseProvider);
  return useCase.getSettings();
}

// ========== ACTIONS ==========

/// Notifier para ações de score
@riverpod
class TetrisScoreActions extends _$TetrisScoreActions {
  @override
  FutureOr<void> build() {}

  /// Salva um novo score
  Future<void> saveScore(TetrisScore score, {int tetrisCount = 0}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(saveScoreUseCaseProvider);
      await useCase(score, tetrisCount: tetrisCount);
      
      // Invalida os providers para recarregar dados
      ref.invalidate(tetrisHighScoresProvider);
      ref.invalidate(tetrisStatsProvider);
    });
  }

  /// Deleta um score
  Future<void> deleteScore(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(tetrisScoreRepositoryProvider);
      await repository.deleteScore(id);
      
      ref.invalidate(tetrisHighScoresProvider);
    });
  }

  /// Deleta todos os scores
  Future<void> deleteAllScores() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(tetrisScoreRepositoryProvider);
      await repository.deleteAllScores();
      
      ref.invalidate(tetrisHighScoresProvider);
    });
  }
}

/// Notifier para ações de settings
@riverpod
class TetrisSettingsActions extends _$TetrisSettingsActions {
  @override
  FutureOr<void> build() {}

  /// Atualiza as configurações
  Future<void> updateSettings(TetrisSettings settings) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.saveSettings(settings);
      
      ref.invalidate(tetrisSettingsProvider);
    });
  }

  /// Reseta para configurações padrão
  Future<void> resetSettings() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(manageSettingsUseCaseProvider);
      await useCase.resetSettings();
      
      ref.invalidate(tetrisSettingsProvider);
    });
  }
}

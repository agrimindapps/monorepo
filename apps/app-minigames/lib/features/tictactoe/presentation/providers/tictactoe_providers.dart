import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/tictactoe_local_data_source.dart';
import '../../data/repositories/tictactoe_repository_impl.dart';
import '../../domain/repositories/tictactoe_repository.dart';
import '../../domain/services/ai_move_strategy_service.dart';
import '../../domain/services/game_result_validation_service.dart';
import '../../domain/services/move_cache_service.dart';
import '../../domain/usecases/check_game_result_usecase.dart';
import '../../domain/usecases/load_settings_usecase.dart';
import '../../domain/usecases/load_stats_usecase.dart';
import '../../domain/usecases/make_ai_move_usecase.dart';
import '../../domain/usecases/make_move_usecase.dart';
import '../../domain/usecases/reset_stats_usecase.dart';
import '../../domain/usecases/save_settings_usecase.dart';
import '../../domain/usecases/save_stats_usecase.dart';

part 'tictactoe_providers.g.dart';

@riverpod
TicTacToeLocalDataSource ticTacToeLocalDataSource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TicTacToeLocalDataSourceImpl(prefs);
}

@Riverpod(keepAlive: true)
TicTacToeRepository ticTacToeRepository(Ref ref) {
  final dataSource = ref.watch(ticTacToeLocalDataSourceProvider);
  return TicTacToeRepositoryImpl(dataSource);
}

@riverpod
AIMoveStrategyService aiMoveStrategyService(Ref ref) {
  final validation = ref.watch(gameResultValidationServiceProvider);
  return AIMoveStrategyService(validation);
}

@riverpod
GameResultValidationService gameResultValidationService(Ref ref) =>
    GameResultValidationService();

@riverpod
MoveCacheService moveCacheService(Ref ref) =>
    MoveCacheService();

@riverpod
CheckGameResultUseCase checkGameResultUseCase(Ref ref) {
  final service = ref.watch(gameResultValidationServiceProvider);
  return CheckGameResultUseCase(service);
}

@riverpod
LoadSettingsUseCase loadSettingsUseCase(Ref ref) {
  final repository = ref.watch(ticTacToeRepositoryProvider);
  return LoadSettingsUseCase(repository);
}

@riverpod
LoadStatsUseCase loadStatsUseCase(Ref ref) {
  final repository = ref.watch(ticTacToeRepositoryProvider);
  return LoadStatsUseCase(repository);
}

@riverpod
MakeAIMoveUseCase makeAiMoveUseCase(Ref ref) {
  final aiStrategy = ref.watch(aiMoveStrategyServiceProvider);
  return MakeAIMoveUseCase(aiStrategy);
}

@riverpod
MakeMoveUseCase makeMoveUseCase(Ref ref) {
  return MakeMoveUseCase();
}

@riverpod
ResetStatsUseCase resetStatsUseCase(Ref ref) {
  final repository = ref.watch(ticTacToeRepositoryProvider);
  return ResetStatsUseCase(repository);
}

@riverpod
SaveSettingsUseCase saveSettingsUseCase(Ref ref) {
  final repository = ref.watch(ticTacToeRepositoryProvider);
  return SaveSettingsUseCase(repository);
}

@riverpod
SaveStatsUseCase saveStatsUseCase(Ref ref) {
  final repository = ref.watch(ticTacToeRepositoryProvider);
  return SaveStatsUseCase(repository);
}

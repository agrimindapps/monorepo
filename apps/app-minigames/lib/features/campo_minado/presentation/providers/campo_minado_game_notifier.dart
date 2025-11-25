import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/game_stats.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/reveal_cell_usecase.dart';
import '../../domain/usecases/toggle_flag_usecase.dart';
import '../../domain/usecases/chord_click_usecase.dart';
import '../../domain/usecases/start_new_game_usecase.dart';
import '../../domain/usecases/toggle_pause_usecase.dart';
import '../../domain/usecases/update_timer_usecase.dart';
import '../../domain/usecases/load_stats_usecase.dart';
import '../../domain/usecases/update_stats_usecase.dart';
import '../../data/datasources/campo_minado_local_data_source.dart';
import '../../data/repositories/campo_minado_repository_impl.dart';
import '../../domain/services/flood_fill_service.dart';
import '../../domain/services/mine_generator_service.dart';
import '../../domain/services/neighbor_calculator_service.dart';
import '../../../../core/providers/core_providers.dart';

part 'campo_minado_game_notifier.g.dart';

// Dependencies providers

@riverpod
CampoMinadoLocalDataSource campoMinadoLocalDataSource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CampoMinadoLocalDataSource(prefs);
}

@riverpod
CampoMinadoRepositoryImpl campoMinadoRepository(Ref ref) {
  final dataSource = ref.watch(campoMinadoLocalDataSourceProvider);
  return CampoMinadoRepositoryImpl(dataSource);
}

// Services providers

@riverpod
FloodFillService floodFillService(Ref ref) {
  return FloodFillService();
}

@riverpod
MineGeneratorService mineGeneratorService(Ref ref) {
  return MineGeneratorService();
}

@riverpod
NeighborCalculatorService neighborCalculatorService(Ref ref) {
  return NeighborCalculatorService();
}

// Use cases providers

@riverpod
RevealCellUseCase revealCellUseCase(Ref ref) {
  return const RevealCellUseCase();
}

@riverpod
ToggleFlagUseCase toggleFlagUseCase(Ref ref) {
  return const ToggleFlagUseCase();
}

@riverpod
ChordClickUseCase chordClickUseCase(Ref ref) {
  return ChordClickUseCase(
    ref.watch(revealCellUseCaseProvider),
  );
}

@riverpod
StartNewGameUseCase startNewGameUseCase(Ref ref) {
  return const StartNewGameUseCase();
}

@riverpod
TogglePauseUseCase togglePauseUseCase(Ref ref) {
  return const TogglePauseUseCase();
}

@riverpod
UpdateTimerUseCase updateTimerUseCase(Ref ref) {
  return const UpdateTimerUseCase();
}

@riverpod
LoadStatsUseCase loadStatsUseCase(Ref ref) {
  final repository = ref.watch(campoMinadoRepositoryProvider);
  return LoadStatsUseCase(repository);
}

@riverpod
UpdateStatsUseCase updateStatsUseCase(Ref ref) {
  final repository = ref.watch(campoMinadoRepositoryProvider);
  return UpdateStatsUseCase(repository);
}

// Game state notifier

@riverpod
class CampoMinadoGameNotifier extends _$CampoMinadoGameNotifier {
  Timer? _gameTimer;
  bool _isMounted = true;

  @override
  GameState build() {
    // Cleanup on dispose
    ref.onDispose(() {
      _isMounted = false;
      _stopTimer();
    });

    return GameState.initial(difficulty: Difficulty.beginner);
  }

  // Actions

  Future<void> revealCell(int row, int col) async {
    final result = await ref.read(revealCellUseCaseProvider)(
      currentState: state,
      row: row,
      col: col,
    );

    result.fold(
      (failure) {
        // Log error but don't update state
      },
      (newState) {
        state = newState;

        // Start timer on first move
        if (newState.isPlaying &&
            !newState.isFirstClick &&
            _gameTimer == null) {
          _startTimer();
        }

        // Handle game over
        if (newState.isGameOver) {
          _stopTimer();
          _updateStatistics(won: newState.status == GameStatus.won);
        }
      },
    );
  }

  Future<void> toggleFlag(int row, int col) async {
    final result = await ref.read(toggleFlagUseCaseProvider)(
      currentState: state,
      row: row,
      col: col,
    );

    result.fold(
      (failure) {
        // Log error
      },
      (newState) {
        state = newState;
      },
    );
  }

  Future<void> chordClick(int row, int col) async {
    final result = await ref.read(chordClickUseCaseProvider)(
      currentState: state,
      row: row,
      col: col,
    );

    result.fold(
      (failure) {
        // Log error
      },
      (newState) {
        state = newState;

        // Handle game over
        if (newState.isGameOver) {
          _stopTimer();
          _updateStatistics(won: newState.status == GameStatus.won);
        }
      },
    );
  }

  Future<void> startNewGame({
    Difficulty? difficulty,
    GameConfig? customConfig,
  }) async {
    _stopTimer();

    final result = await ref.read(startNewGameUseCaseProvider)(
      difficulty: difficulty ?? state.difficulty,
      customConfig: customConfig,
    );

    result.fold(
      (failure) {
        // Log error
      },
      (newState) {
        state = newState;
      },
    );
  }

  Future<void> restartGame() async {
    await startNewGame(
      difficulty: state.difficulty,
      customConfig: state.difficulty == Difficulty.custom ? state.config : null,
    );
  }

  Future<void> togglePause() async {
    final result = await ref.read(togglePauseUseCaseProvider)(
      currentState: state,
    );

    result.fold(
      (failure) {
        // Log error
      },
      (newState) {
        state = newState;

        if (newState.isPaused) {
          _stopTimer();
        } else if (newState.isPlaying) {
          _startTimer();
        }
      },
    );
  }

  Future<void> changeDifficulty(Difficulty difficulty) async {
    await startNewGame(difficulty: difficulty);
  }

  // Timer management

  void _startTimer() {
    _stopTimer(); // Ensure no duplicate timers

    if (state.isGameOver || state.isPaused) return;

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_isMounted) return;

      if (!state.isPlaying || state.isPaused) {
        _stopTimer();
        return;
      }

      final result = await ref.read(updateTimerUseCaseProvider)(
        currentState: state,
      );
      if (!_isMounted) return;

      result.fold(
        (failure) {
          // Log error
        },
        (newState) {
          if (!_isMounted) return;
          state = newState;
        },
      );
    });
  }

  void _stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  // Statistics

  Future<void> _updateStatistics({required bool won}) async {
    final useCase = ref.read(updateStatsUseCaseProvider);
    final result = await useCase(
      gameState: state,
      won: won,
    );

    result.fold(
      (failure) {
        // Log error
      },
      (updatedStats) {
        // Stats updated successfully
        // Invalidate stats provider to refresh UI
        ref.invalidate(campoMinadoStatsProvider);
      },
    );
  }
}

// Stats provider (separate from game state)

@riverpod
class CampoMinadoStats extends _$CampoMinadoStats {
  @override
  Future<GameStats> build(Difficulty difficulty) async {
    final useCase = ref.read(loadStatsUseCaseProvider);
    final result = await useCase(difficulty: difficulty);

    return result.fold(
      (failure) => GameStats.empty(difficulty: difficulty),
      (stats) => stats,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    final useCase = ref.read(loadStatsUseCaseProvider);
    final result = await useCase(difficulty: difficulty);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (stats) => AsyncValue.data(stats),
    );
  }
}

// Computed/derived providers

@riverpod
bool isGameActive(Ref ref) {
  final gameState = ref.watch(campoMinadoGameProvider);
  return gameState.isPlaying && !gameState.isPaused;
}

@riverpod
bool canInteract(Ref ref) {
  final gameState = ref.watch(campoMinadoGameProvider);
  return gameState.canInteract;
}

@riverpod
String formattedTime(Ref ref) {
  final gameState = ref.watch(campoMinadoGameProvider);
  return gameState.formattedTime;
}

@riverpod
int remainingMines(Ref ref) {
  final gameState = ref.watch(campoMinadoGameProvider);
  return gameState.remainingMines;
}

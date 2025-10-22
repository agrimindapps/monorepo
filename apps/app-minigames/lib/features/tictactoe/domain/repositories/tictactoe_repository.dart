import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_stats.dart';
import '../entities/game_settings.dart';

/// Repository interface for TicTacToe game data operations
/// Implementations should handle data persistence (SharedPreferences, etc.)
abstract class TicTacToeRepository {
  /// Loads game statistics from storage
  /// Returns [GameStats] on success or [Failure] on error
  Future<Either<Failure, GameStats>> getStats();

  /// Saves game statistics to storage
  /// Returns [void] on success or [Failure] on error
  Future<Either<Failure, void>> saveStats(GameStats stats);

  /// Resets game statistics to zero
  /// Returns [void] on success or [Failure] on error
  Future<Either<Failure, void>> resetStats();

  /// Loads game settings from storage
  /// Returns [GameSettings] on success or [Failure] on error
  Future<Either<Failure, GameSettings>> getSettings();

  /// Saves game settings to storage
  /// Returns [void] on success or [Failure] on error
  Future<Either<Failure, void>> saveSettings(GameSettings settings);
}

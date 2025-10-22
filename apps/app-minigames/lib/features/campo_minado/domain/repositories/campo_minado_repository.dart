import 'package:core/core.dart';
import '../entities/game_stats.dart';
import '../entities/enums.dart';

/// Repository interface for Campo Minado game data
abstract class CampoMinadoRepository {
  /// Loads game statistics for a specific difficulty
  Future<Either<Failure, GameStats>> loadStats(Difficulty difficulty);

  /// Saves game statistics for a specific difficulty
  Future<Either<Failure, void>> saveStats(GameStats stats);

  /// Resets statistics for a specific difficulty
  Future<Either<Failure, void>> resetStats(Difficulty difficulty);

  /// Loads global statistics (all difficulties combined)
  Future<Either<Failure, GameStats>> loadGlobalStats();
}

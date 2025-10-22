import 'package:equatable/equatable.dart';

/// Immutable entity representing game statistics
class GameStats extends Equatable {
  final int xWins;
  final int oWins;
  final int draws;

  const GameStats({
    required this.xWins,
    required this.oWins,
    required this.draws,
  });

  /// Factory constructor for empty stats
  const GameStats.empty()
      : xWins = 0,
        oWins = 0,
        draws = 0;

  // Computed properties (OK in entities)

  /// Total number of games played
  int get totalGames => xWins + oWins + draws;

  /// Win rate for X player (0.0 to 1.0)
  double get xWinRate => totalGames > 0 ? xWins / totalGames : 0.0;

  /// Win rate for O player (0.0 to 1.0)
  double get oWinRate => totalGames > 0 ? oWins / totalGames : 0.0;

  /// Draw rate (0.0 to 1.0)
  double get drawRate => totalGames > 0 ? draws / totalGames : 0.0;

  /// Creates a copy with updated fields
  GameStats copyWith({
    int? xWins,
    int? oWins,
    int? draws,
  }) {
    return GameStats(
      xWins: xWins ?? this.xWins,
      oWins: oWins ?? this.oWins,
      draws: draws ?? this.draws,
    );
  }

  /// Increments X wins
  GameStats incrementXWins() => copyWith(xWins: xWins + 1);

  /// Increments O wins
  GameStats incrementOWins() => copyWith(oWins: oWins + 1);

  /// Increments draws
  GameStats incrementDraws() => copyWith(draws: draws + 1);

  @override
  List<Object> get props => [xWins, oWins, draws];
}

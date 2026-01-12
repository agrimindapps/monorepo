import '../entities/reversi_entities.dart';

class ReversiScore {
  final String id;
  final ReversiPlayer winner;
  final int blackCount;
  final int whiteCount;
  final int moves;
  final Duration duration;
  final DateTime completedAt;
  final String? playerName;

  const ReversiScore({
    required this.id,
    required this.winner,
    required this.blackCount,
    required this.whiteCount,
    required this.moves,
    required this.duration,
    required this.completedAt,
    this.playerName,
  });

  int get scoreDifference => (blackCount - whiteCount).abs();

  String get winnerName => winner == ReversiPlayer.black ? 'Preto' : 'Branco';

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(completedAt);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${completedAt.day}/${completedAt.month}/${completedAt.year}';
    }
  }
}

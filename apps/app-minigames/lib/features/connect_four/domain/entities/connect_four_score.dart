class ConnectFourScore {
  final String winner; // 'Player 1', 'Player 2', or 'Draw'
  final int movesCount;
  final Duration gameDuration;
  final DateTime timestamp;

  const ConnectFourScore({
    required this.winner,
    required this.movesCount,
    required this.gameDuration,
    required this.timestamp,
  });

  String get formattedDuration {
    final minutes = gameDuration.inMinutes;
    final seconds = gameDuration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String get formattedDate {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year;
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

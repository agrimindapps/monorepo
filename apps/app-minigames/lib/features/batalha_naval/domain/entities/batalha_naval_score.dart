class BatalhaNavalScore {
  final String winner; // 'Humano', 'Computador', or 'Empate'
  final int shipsDestroyed;
  final int shotsFired;
  final Duration gameDuration;
  final DateTime timestamp;

  const BatalhaNavalScore({
    required this.winner,
    required this.shipsDestroyed,
    required this.shotsFired,
    required this.gameDuration,
    required this.timestamp,
  });

  double get accuracy => shotsFired > 0
      ? (shipsDestroyed * 5) / shotsFired
      : 0; // Assuming 5 ships

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

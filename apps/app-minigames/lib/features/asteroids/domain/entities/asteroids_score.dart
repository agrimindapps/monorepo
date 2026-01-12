class AsteroidsScore {
  final int score;
  final int wave;
  final int asteroidsDestroyed;
  final DateTime timestamp;

  const AsteroidsScore({
    required this.score,
    required this.wave,
    required this.asteroidsDestroyed,
    required this.timestamp,
  });

  String get formattedDate {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year;
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

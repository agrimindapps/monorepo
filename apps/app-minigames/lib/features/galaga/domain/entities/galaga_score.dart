class GalagaScore {
  final int score;
  final int wave;
  final int enemiesDestroyed;
  final DateTime timestamp;

  const GalagaScore({
    required this.score,
    required this.wave,
    required this.enemiesDestroyed,
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

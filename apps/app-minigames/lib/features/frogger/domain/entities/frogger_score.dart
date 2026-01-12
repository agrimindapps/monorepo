class FroggerScore {
  final int score;
  final int level;
  final int crossingsCompleted;
  final DateTime timestamp;

  const FroggerScore({
    required this.score,
    required this.level,
    required this.crossingsCompleted,
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

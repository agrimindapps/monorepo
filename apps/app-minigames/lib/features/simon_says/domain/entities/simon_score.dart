class SimonScore {
  final String id;
  final int score;
  final int longestSequence;
  final Duration duration;
  final DateTime completedAt;
  final String? playerName;

  const SimonScore({
    required this.id,
    required this.score,
    required this.longestSequence,
    required this.duration,
    required this.completedAt,
    this.playerName,
  });

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

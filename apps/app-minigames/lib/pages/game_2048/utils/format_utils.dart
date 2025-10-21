/// Utilitários para formatação de valores
class FormatUtils {
  /// Formata uma duração para o formato MM:SS
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Formata uma duração para descrição completa (1h 23m 45s)
  static String formatDurationVerbose(Duration duration) {
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    final seconds = (duration.inSeconds % 60);

    final parts = <String>[];

    if (hours > 0) {
      parts.add('${hours}h');
    }

    if (minutes > 0 || hours > 0) {
      parts.add('${minutes}m');
    }

    parts.add('${seconds}s');

    return parts.join(' ');
  }
}

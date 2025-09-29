/// **COMENTARIOS DATE FORMATTER**
/// 
/// Utility class for formatting dates in the Comentarios feature.
/// Provides consistent date formatting across all comentarios components.
/// 
/// ## Features:
/// 
/// - **Relative Formatting**: Shows "2d atrás", "1h atrás", etc.
/// - **Localized Messages**: Portuguese language support
/// - **Smart Cutoffs**: Different formats for different time ranges
/// - **Consistent Behavior**: Same formatting logic throughout the app
library;

class ComentariosDateFormatter {
  /// Formats a date as relative time (e.g., "2d atrás", "1h atrás")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Agora';
    }
  }

  /// Formats a date as absolute date when needed (e.g., "15/03/2024")
  static String formatAbsoluteDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Formats a date with time (e.g., "15/03/2024 14:30")
  static String formatDateTime(DateTime date) {
    return '${formatAbsoluteDate(date)} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  /// Formats date for display in headers or summaries
  static String formatDisplayDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    // Show relative for recent dates
    if (difference.inDays < 7) {
      return formatRelativeDate(date);
    }

    // Show absolute for older dates
    return formatAbsoluteDate(date);
  }

  /// Formats date range for statistics
  static String formatDateRange(DateTime start, DateTime end) {
    return '${formatAbsoluteDate(start)} - ${formatAbsoluteDate(end)}';
  }

  /// Gets a readable description of time ago
  static String getTimeAgoDescription(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'há 1 ano' : 'há $years anos';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'há 1 mês' : 'há $months meses';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'há 1 semana' : 'há $weeks semanas';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'há 1 dia' : 'há ${difference.inDays} dias';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? 'há 1 hora' : 'há ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? 'há 1 minuto' : 'há ${difference.inMinutes} minutos';
    } else {
      return 'agora mesmo';
    }
  }
}
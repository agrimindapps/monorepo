import 'package:intl/intl.dart';

/// Service responsible for date and time formatting
/// Follows SRP by handling only formatting operations

class DateTimeFormatterService {
  static final DateFormat _brazilianDateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _brazilianDateTimeFormat = DateFormat(
    'dd/MM/yyyy HH:mm',
  );
  static final DateFormat _shortDateFormat = DateFormat('dd/MM');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy', 'pt_BR');
  static final DateFormat _fullDateFormat = DateFormat(
    'EEEE, d MMMM yyyy',
    'pt_BR',
  );
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  /// Format date in Brazilian format (dd/MM/yyyy)
  String formatDate(DateTime date) {
    return _brazilianDateFormat.format(date);
  }

  /// Format date with time (dd/MM/yyyy HH:mm)
  String formatDateTime(DateTime date) {
    return _brazilianDateTimeFormat.format(date);
  }

  /// Format short date without year (dd/MM)
  String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Format month and year (Jan 2025)
  String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Format full date (Segunda-feira, 31 Outubro 2025)
  String formatFullDate(DateTime date) {
    return _fullDateFormat.format(date);
  }

  /// Format only time (HH:mm)
  String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format relative date (Hoje, Ontem, etc)
  String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(targetDate).inDays;

    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Ontem';
    } else if (difference < 7) {
      return '$difference dias atrás';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks ${weeks == 1 ? "semana" : "semanas"} atrás';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '$months ${months == 1 ? "mês" : "meses"} atrás';
    } else {
      final years = (difference / 365).floor();
      return '$years ${years == 1 ? "ano" : "anos"} atrás';
    }
  }

  /// Format date range
  String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return formatDate(start);
    }

    if (start.year == end.year && start.month == end.month) {
      return '${start.day} - ${end.day}/${end.month}/${end.year}';
    }

    if (start.year == end.year) {
      return '${start.day}/${start.month} - ${end.day}/${end.month}/${end.year}';
    }

    return '${formatDate(start)} - ${formatDate(end)}';
  }

  /// Format time ago (5 minutos atrás, 2 horas atrás)
  String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? "minuto" : "minutos"} atrás';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? "hora" : "horas"} atrás';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? "dia" : "dias"} atrás';
    } else {
      return formatDate(date);
    }
  }

  /// Parse Brazilian date string to DateTime
  DateTime? parseBrazilianDate(String dateString) {
    try {
      return _brazilianDateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Check if date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is this week
  bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is this month
  bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Get start of day
  DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of month
  DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  /// Get end of month
  DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }
}

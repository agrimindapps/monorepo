// Package imports:
import 'package:intl/intl.dart';

/// Service for centralized date formatting and conversion
class DateFormatterService {
  static DateFormatterService? _instance;
  static DateFormatterService get instance =>
      _instance ??= DateFormatterService._();

  DateFormatterService._();

  // Standard date formats
  static const String _displayFormat = 'dd/MM/yyyy';
  static const String _displayFormatWithTime = 'dd/MM/yyyy HH:mm';
  static const String _inputFormat = 'dd/MM/yyyy';
  static const String _isoFormat = 'yyyy-MM-dd';
  static const String _longFormat = 'dd \'de\' MMMM \'de\' yyyy';
  static const String _shortFormat = 'dd/MM/yy';
  static const String _timeFormat = 'HH:mm';
  static const String _monthYearFormat = 'MM/yyyy';

  // Formatters
  late final DateFormat _displayFormatter;
  late final DateFormat _displayWithTimeFormatter;
  late final DateFormat _inputFormatter;
  late final DateFormat _isoFormatter;
  late final DateFormat _longFormatter;
  late final DateFormat _shortFormatter;
  late final DateFormat _timeFormatter;
  late final DateFormat _monthYearFormatter;

  /// Initialize formatters with locale
  void initialize({String locale = 'pt_BR'}) {
    _displayFormatter = DateFormat(_displayFormat, locale);
    _displayWithTimeFormatter = DateFormat(_displayFormatWithTime, locale);
    _inputFormatter = DateFormat(_inputFormat, locale);
    _isoFormatter = DateFormat(_isoFormat, locale);
    _longFormatter = DateFormat(_longFormat, locale);
    _shortFormatter = DateFormat(_shortFormat, locale);
    _timeFormatter = DateFormat(_timeFormat, locale);
    _monthYearFormatter = DateFormat(_monthYearFormat, locale);
  }

  /// Format DateTime to display format (dd/MM/yyyy)
  String formatForDisplay(DateTime date) {
    _ensureInitialized();
    return _displayFormatter.format(date);
  }

  /// Format DateTime to display format with time (dd/MM/yyyy HH:mm)
  String formatForDisplayWithTime(DateTime date) {
    _ensureInitialized();
    return _displayWithTimeFormatter.format(date);
  }

  /// Format timestamp to display format
  String formatTimestampForDisplay(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return formatForDisplay(date);
  }

  /// Format timestamp to display format with time
  String formatTimestampForDisplayWithTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return formatForDisplayWithTime(date);
  }

  /// Format DateTime to input format (for text fields)
  String formatForInput(DateTime date) {
    _ensureInitialized();
    return _inputFormatter.format(date);
  }

  /// Format DateTime to ISO format (yyyy-MM-dd)
  String formatToIso(DateTime date) {
    _ensureInitialized();
    return _isoFormatter.format(date);
  }

  /// Format DateTime to long format (dd de MMMM de yyyy)
  String formatToLong(DateTime date) {
    _ensureInitialized();
    return _longFormatter.format(date);
  }

  /// Format DateTime to short format (dd/MM/yy)
  String formatToShort(DateTime date) {
    _ensureInitialized();
    return _shortFormatter.format(date);
  }

  /// Format DateTime to time only (HH:mm)
  String formatTimeOnly(DateTime date) {
    _ensureInitialized();
    return _timeFormatter.format(date);
  }

  /// Format DateTime to month/year (MM/yyyy)
  String formatMonthYear(DateTime date) {
    _ensureInitialized();
    return _monthYearFormatter.format(date);
  }

  /// Parse date string from input format (dd/MM/yyyy)
  DateTime? parseFromInput(String dateString) {
    try {
      _ensureInitialized();
      return _inputFormatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse date string from ISO format (yyyy-MM-dd)
  DateTime? parseFromIso(String dateString) {
    try {
      _ensureInitialized();
      return _isoFormatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse date string from display format (dd/MM/yyyy)
  DateTime? parseFromDisplay(String dateString) {
    try {
      _ensureInitialized();
      return _displayFormatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Convert timestamp to DateTime
  DateTime timestampToDateTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Convert DateTime to timestamp
  int dateTimeToTimestamp(DateTime date) {
    return date.millisecondsSinceEpoch;
  }

  /// Get relative time description (há X dias, hoje, amanhã, etc.)
  String getRelativeTime(DateTime date, {DateTime? relativeTo}) {
    final now = relativeTo ?? DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Same day
      final hoursDiff = difference.inHours;
      if (hoursDiff == 0) {
        final minutesDiff = difference.inMinutes;
        if (minutesDiff < 1) {
          return 'agora mesmo';
        } else if (minutesDiff == 1) {
          return 'há 1 minuto';
        } else {
          return 'há $minutesDiff minutos';
        }
      } else if (hoursDiff == 1) {
        return 'há 1 hora';
      } else if (hoursDiff < 0) {
        return 'em ${(-hoursDiff)} horas';
      } else {
        return 'há $hoursDiff horas';
      }
    } else if (difference.inDays == 1) {
      return 'ontem';
    } else if (difference.inDays == -1) {
      return 'amanhã';
    } else if (difference.inDays > 1 && difference.inDays <= 7) {
      return 'há ${difference.inDays} dias';
    } else if (difference.inDays < -1 && difference.inDays >= -7) {
      return 'em ${(-difference.inDays)} dias';
    } else if (difference.inDays > 7 && difference.inDays <= 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'há 1 semana' : 'há $weeks semanas';
    } else if (difference.inDays < -7 && difference.inDays >= -30) {
      final weeks = ((-difference.inDays) / 7).floor();
      return weeks == 1 ? 'em 1 semana' : 'em $weeks semanas';
    } else if (difference.inDays > 30 && difference.inDays <= 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'há 1 mês' : 'há $months meses';
    } else if (difference.inDays < -30 && difference.inDays >= -365) {
      final months = ((-difference.inDays) / 30).floor();
      return months == 1 ? 'em 1 mês' : 'em $months meses';
    } else if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'há 1 ano' : 'há $years anos';
    } else {
      final years = ((-difference.inDays) / 365).floor();
      return years == 1 ? 'em 1 ano' : 'em $years anos';
    }
  }

  /// Get relative time from timestamp
  String getRelativeTimeFromTimestamp(int timestamp, {DateTime? relativeTo}) {
    final date = timestampToDateTime(timestamp);
    return getRelativeTime(date, relativeTo: relativeTo);
  }

  /// Check if date string is valid for input format
  bool isValidInputDate(String dateString) {
    return parseFromInput(dateString) != null;
  }

  /// Check if date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if timestamp is today
  bool isTimestampToday(int timestamp) {
    final date = timestampToDateTime(timestamp);
    return isToday(date);
  }

  /// Check if date is this week
  bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  /// Check if date is this month
  bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if date is this year
  bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// Get start of day for a given date
  DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day for a given date
  DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week for a given date
  DateTime getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return getStartOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// Get end of week for a given date
  DateTime getEndOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return getEndOfDay(date.add(Duration(days: daysToSunday)));
  }

  /// Get start of month for a given date
  DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month for a given date
  DateTime getEndOfMonth(DateTime date) {
    final nextMonth = date.month == 12
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1));
  }

  /// Get days in month
  int getDaysInMonth(DateTime date) {
    final nextMonth = date.month == 12
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  /// Format age from birth date
  String formatAge(DateTime birthDate, {DateTime? relativeTo}) {
    final now = relativeTo ?? DateTime.now();
    final age = now.difference(birthDate).inDays;

    if (age < 30) {
      return '$age dias';
    } else if (age < 365) {
      final months = (age / 30).floor();
      return months == 1 ? '1 mês' : '$months meses';
    } else {
      final years = (age / 365).floor();
      final remainingMonths = ((age % 365) / 30).floor();

      if (remainingMonths == 0) {
        return years == 1 ? '1 ano' : '$years anos';
      } else {
        final yearText = years == 1 ? '1 ano' : '$years anos';
        final monthText =
            remainingMonths == 1 ? '1 mês' : '$remainingMonths meses';
        return '$yearText e $monthText';
      }
    }
  }

  /// Format duration between two dates
  String formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);

    if (duration.inDays > 0) {
      return '${duration.inDays} dias';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} horas';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutos';
    } else {
      return 'menos de 1 minuto';
    }
  }

  /// Ensure formatters are initialized
  void _ensureInitialized() {
    try {
      _displayFormatter.format(DateTime.now());
    } catch (e) {
      initialize();
    }
  }

  /// Get common date range presets
  Map<String, Map<String, DateTime>> getDateRangePresets() {
    final now = DateTime.now();

    return {
      'Hoje': {
        'start': getStartOfDay(now),
        'end': getEndOfDay(now),
      },
      'Ontem': {
        'start': getStartOfDay(now.subtract(const Duration(days: 1))),
        'end': getEndOfDay(now.subtract(const Duration(days: 1))),
      },
      'Esta semana': {
        'start': getStartOfWeek(now),
        'end': getEndOfWeek(now),
      },
      'Semana passada': {
        'start': getStartOfWeek(now.subtract(const Duration(days: 7))),
        'end': getEndOfWeek(now.subtract(const Duration(days: 7))),
      },
      'Este mês': {
        'start': getStartOfMonth(now),
        'end': getEndOfMonth(now),
      },
      'Mês passado': {
        'start': getStartOfMonth(DateTime(now.year, now.month - 1)),
        'end': getEndOfMonth(DateTime(now.year, now.month - 1)),
      },
      'Últimos 30 dias': {
        'start': getStartOfDay(now.subtract(const Duration(days: 30))),
        'end': getEndOfDay(now),
      },
      'Últimos 90 dias': {
        'start': getStartOfDay(now.subtract(const Duration(days: 90))),
        'end': getEndOfDay(now),
      },
    };
  }
}

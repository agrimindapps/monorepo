// Project imports:
import '../../../../../../app-petiveti/utils/date_utils.dart' as app_date_utils;

class DateUtils {
  // Delegated functions to centralized date utils
  static String formatDateToString(int milliseconds) => app_date_utils.DateUtils.formatDate(milliseconds);
  static String formatDateTimeToString(DateTime date) => app_date_utils.DateUtils.formatDate(date.millisecondsSinceEpoch);
  static DateTime? parseStringToDate(String dateString) => app_date_utils.DateUtils.parseStringToDate(dateString);
  static bool isValidDate(DateTime date) {
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));
    
    return !date.isAfter(now) && !date.isBefore(oneYearAgo);
  }
  static DateTime normalizeDate(DateTime date) => app_date_utils.DateUtils.normalizeDate(date);
  static int dateTimeToMilliseconds(DateTime date) => date.millisecondsSinceEpoch;
  static DateTime millisecondsToDateTime(int milliseconds) => DateTime.fromMillisecondsSinceEpoch(milliseconds);
  static String getRelativeTimeString(DateTime date) => app_date_utils.DateUtils.getRelativeTimeString(date);
  static bool isToday(DateTime date) => app_date_utils.DateUtils.isToday(date);
  static bool isTomorrow(DateTime date) => app_date_utils.DateUtils.isTomorrow(date);
  static bool isYesterday(DateTime date) => app_date_utils.DateUtils.isYesterday(date);
  static bool isThisWeek(DateTime date) => app_date_utils.DateUtils.isThisWeek(date);
  static bool isThisMonth(DateTime date) => app_date_utils.DateUtils.isThisMonth(date);
  static bool isThisYear(DateTime date) => app_date_utils.DateUtils.isThisYear(date);
  static String getMes(int month) => app_date_utils.DateUtils.getMes(month);
  static String getMesAbreviado(int month) => app_date_utils.DateUtils.getMesAbreviado(month);
  static String getDiaSemana(int weekday) => app_date_utils.DateUtils.getDiaSemana(weekday);
  static String getDiaSemanaAbreviado(int weekday) => app_date_utils.DateUtils.getDiaSemanaAbreviado(weekday);
  static String formatDateComplete(DateTime date) => app_date_utils.DateUtils.formatDateComplete(date);
  static DateTime getStartOfDay(DateTime date) => app_date_utils.DateUtils.getStartOfDay(date);
  static DateTime getEndOfDay(DateTime date) => app_date_utils.DateUtils.getEndOfDay(date);
  static DateTime getStartOfMonth(DateTime date) => app_date_utils.DateUtils.getStartOfMonth(date);
  static DateTime getEndOfMonth(DateTime date) => app_date_utils.DateUtils.getEndOfMonth(date);
  static List<DateTime> getDateRange(DateTime start, DateTime end) => app_date_utils.DateUtils.getDateRange(start, end);
  static int daysBetweenDates(DateTime start, DateTime end) {
    final startDate = normalizeDate(start);
    final endDate = normalizeDate(end);
    return endDate.difference(startDate).inDays;
  }

  // Page-specific utility functions (keep these)
  static int getTodayTimestamp() {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    return todayMidnight.millisecondsSinceEpoch;
  }

  static int getWeekStartTimestamp() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartMidnight = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return weekStartMidnight.millisecondsSinceEpoch;
  }

  static int getMonthStartTimestamp() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return monthStart.millisecondsSinceEpoch;
  }

  static int getYearStartTimestamp() {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    return yearStart.millisecondsSinceEpoch;
  }

  static int getDaysAgoTimestamp(int days) {
    final daysAgo = DateTime.now().subtract(Duration(days: days));
    final daysAgoMidnight = DateTime(daysAgo.year, daysAgo.month, daysAgo.day);
    return daysAgoMidnight.millisecondsSinceEpoch;
  }

  static int getMonthsAgoTimestamp(int months) {
    final now = DateTime.now();
    final monthsAgo = DateTime(now.year, now.month - months, now.day);
    return monthsAgo.millisecondsSinceEpoch;
  }

  static int addDays(int timestamp, int days) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final newDate = date.add(Duration(days: days));
    return newDate.millisecondsSinceEpoch;
  }

  static int addMonths(int timestamp, int months) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final newDate = DateTime(date.year, date.month + months, date.day);
    return newDate.millisecondsSinceEpoch;
  }

  static bool isTodayTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final today = DateTime.now();
    
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  static bool isThisWeekTimestamp(int timestamp) {
    final weekStart = getWeekStartTimestamp();
    final weekEnd = addDays(weekStart, 7);
    
    return timestamp >= weekStart && timestamp < weekEnd;
  }

  static bool isThisMonthTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    return date.year == now.year && date.month == now.month;
  }

  static bool isThisYearTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    return date.year == now.year;
  }

  static int daysBetweenTimestamps(int start, int end) {
    final startDate = DateTime.fromMillisecondsSinceEpoch(start);
    final endDate = DateTime.fromMillisecondsSinceEpoch(end);
    
    return endDate.difference(startDate).inDays;
  }

  static Map<String, DateRange> getPredefinedRanges() {
    final now = DateTime.now();
    
    return {
      'today': DateRange(
        start: getTodayTimestamp(),
        end: addDays(getTodayTimestamp(), 1),
        label: 'Hoje',
      ),
      'week': DateRange(
        start: getWeekStartTimestamp(),
        end: addDays(getWeekStartTimestamp(), 7),
        label: 'Esta semana',
      ),
      'month': DateRange(
        start: getMonthStartTimestamp(),
        end: addMonths(getMonthStartTimestamp(), 1),
        label: 'Este mês',
      ),
      'last30days': DateRange(
        start: getDaysAgoTimestamp(30),
        end: getTodayTimestamp(),
        label: 'Últimos 30 dias',
      ),
      'last90days': DateRange(
        start: getDaysAgoTimestamp(90),
        end: getTodayTimestamp(),
        label: 'Últimos 90 dias',
      ),
      'year': DateRange(
        start: getYearStartTimestamp(),
        end: DateTime(now.year + 1, 1, 1).millisecondsSinceEpoch,
        label: 'Este ano',
      ),
      'all': DateRange(
        start: DateTime(2000, 1, 1).millisecondsSinceEpoch,
        end: DateTime(now.year + 1, 12, 31).millisecondsSinceEpoch,
        label: 'Todos os registros',
      ),
    };
  }

  static String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks semana${weeks > 1 ? 's' : ''} atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months mês${months > 1 ? 'es' : ''} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ano${years > 1 ? 's' : ''} atrás';
    }
  }

  static String getSeason(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final month = date.month;
    
    // Southern hemisphere seasons
    if (month >= 12 || month <= 2) {
      return 'Verão';
    } else if (month >= 3 && month <= 5) {
      return 'Outono';
    } else if (month >= 6 && month <= 8) {
      return 'Inverno';
    } else {
      return 'Primavera';
    }
  }

  static bool isWeekend(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static int getWeekNumber(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  static int getQuarter(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return ((date.month - 1) / 3).floor() + 1;
  }

  static Map<String, List<int>> groupTimestampsByPeriod(
    List<int> timestamps,
    String period,
  ) {
    final groups = <String, List<int>>{};
    
    for (final timestamp in timestamps) {
      final key = _getPeriodKey(timestamp, period);
      groups.putIfAbsent(key, () => []).add(timestamp);
    }
    
    return groups;
  }

  static String _getPeriodKey(int timestamp, String period) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    
    switch (period) {
      case 'day':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'week':
        return 'S${getWeekNumber(timestamp)}/${date.year}';
      case 'month':
        return '${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'quarter':
        return 'Q${getQuarter(timestamp)}/${date.year}';
      case 'year':
        return date.year.toString();
      default:
        return date.toString();
    }
  }
}

/// Date range helper class
class DateRange {
  final int start;
  final int end;
  final String label;

  const DateRange({
    required this.start,
    required this.end,
    required this.label,
  });

  /// Check if timestamp is within this range
  bool contains(int timestamp) {
    return timestamp >= start && timestamp < end;
  }

  /// Get duration in days
  int get durationInDays {
    return DateUtils.daysBetweenTimestamps(start, end);
  }

  /// Check if range is valid
  bool get isValid => start < end;

  @override
  String toString() => '$label ($durationInDays dias)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
           other.start == start &&
           other.end == end &&
           other.label == label;
  }

  @override
  int get hashCode => Object.hash(start, end, label);
}

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
  static int daysBetween(DateTime start, DateTime end) {
    final startDate = normalizeDate(start);
    final endDate = normalizeDate(end);
    return endDate.difference(startDate).inDays;
  }

  // Form-specific date utilities (keep these for peso_cadastro specific functionality)
  static bool isDateInFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  static bool isDateTooOld(DateTime date, {int maxYears = 10}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: 365 * maxYears));
    return date.isBefore(cutoffDate);
  }

  static String formatDateForInput(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static DateTime? parseDateFromInput(String input) {
    return parseStringToDate(input);
  }

  static List<DateTime> getDateSuggestions() {
    final now = DateTime.now();
    return [
      now, // Today
      now.subtract(const Duration(days: 1)), // Yesterday
      now.subtract(const Duration(days: 7)), // Last week
      now.subtract(const Duration(days: 30)), // Last month
    ];
  }

  static String getDateSuggestionLabel(DateTime date) {
    if (isToday(date)) return 'Hoje';
    if (isYesterday(date)) return 'Ontem';
    
    final daysDiff = DateTime.now().difference(date).inDays;
    if (daysDiff == 7) return 'Uma semana atrás';
    if (daysDiff == 30) return 'Um mês atrás';
    
    return formatDateForInput(date);
  }

  static Map<String, DateTime> getCommonDateChoices() {
    final now = DateTime.now();
    return {
      'Hoje': now,
      'Ontem': now.subtract(const Duration(days: 1)),
      'Há 2 dias': now.subtract(const Duration(days: 2)),
      'Há 3 dias': now.subtract(const Duration(days: 3)),
      'Uma semana atrás': now.subtract(const Duration(days: 7)),
      'Duas semanas atrás': now.subtract(const Duration(days: 14)),
      'Um mês atrás': now.subtract(const Duration(days: 30)),
    };
  }

  // Date validation helpers
  static String? validateDateString(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) {
      return 'Data é obrigatória';
    }

    final date = parseStringToDate(dateString);
    if (date == null) {
      return 'Formato de data inválido (use dd/mm/aaaa)';
    }

    if (isDateInFuture(date)) {
      return 'Data não pode ser no futuro';
    }

    if (isDateTooOld(date)) {
      return 'Data muito antiga para um registro de peso';
    }

    return null;
  }

  static String? validateDateTime(DateTime? date) {
    if (date == null) {
      return 'Data é obrigatória';
    }

    if (isDateInFuture(date)) {
      return 'Data não pode ser no futuro';
    }

    if (isDateTooOld(date)) {
      return 'Data muito antiga para um registro de peso';
    }

    return null;
  }

  // Date comparison utilities
  static bool isSameDate(DateTime date1, DateTime date2) {
    return normalizeDate(date1).isAtSameMomentAs(normalizeDate(date2));
  }

  static bool isDateBefore(DateTime date1, DateTime date2) {
    return normalizeDate(date1).isBefore(normalizeDate(date2));
  }

  static bool isDateAfter(DateTime date1, DateTime date2) {
    return normalizeDate(date1).isAfter(normalizeDate(date2));
  }

  static DateTime getClosestDate(DateTime target, List<DateTime> dates) {
    if (dates.isEmpty) return target;
    
    DateTime closest = dates.first;
    int minDiff = (target.difference(closest).inDays).abs();
    
    for (final date in dates) {
      final diff = (target.difference(date).inDays).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = date;
      }
    }
    
    return closest;
  }

  // Date range helpers for forms
  static DateTime getMinAllowedDate() {
    return DateTime.now().subtract(const Duration(days: 365)); // 1 year ago
  }

  static DateTime getMaxAllowedDate() {
    return DateTime.now();
  }

  static bool isDateInAllowedRange(DateTime date) {
    final min = getMinAllowedDate();
    final max = getMaxAllowedDate();
    return !date.isBefore(min) && !date.isAfter(max);
  }

  // Format helpers for display
  static String formatDateForDisplay(DateTime date) {
    if (isToday(date)) return 'Hoje';
    if (isYesterday(date)) return 'Ontem';
    if (isTomorrow(date)) return 'Amanhã';
    
    return formatDateForInput(date);
  }

  static String formatDateWithWeekday(DateTime date) {
    final weekday = getDiaSemanaAbreviado(date.weekday);
    final formatted = formatDateForInput(date);
    return '$weekday, $formatted';
  }

  static String formatDateRange(DateTime start, DateTime end) {
    if (isSameDate(start, end)) {
      return formatDateForDisplay(start);
    }
    
    final startFormatted = formatDateForInput(start);
    final endFormatted = formatDateForInput(end);
    return '$startFormatted - $endFormatted';
  }

  // Time utilities for forms
  static String formatTimeForInput(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static DateTime combineDateAndTime(DateTime date, DateTime time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      time.second,
    );
  }

  static DateTime setTime(DateTime date, int hour, int minute) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // Input masking and formatting
  static String maskDateInput(String input) {
    // Remove non-numeric characters
    final numbers = input.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numbers.length <= 2) {
      return numbers;
    } else if (numbers.length <= 4) {
      return '${numbers.substring(0, 2)}/${numbers.substring(2)}';
    } else if (numbers.length <= 8) {
      return '${numbers.substring(0, 2)}/${numbers.substring(2, 4)}/${numbers.substring(4)}';
    } else {
      return '${numbers.substring(0, 2)}/${numbers.substring(2, 4)}/${numbers.substring(4, 8)}';
    }
  }

  static bool isDateInputComplete(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length == 8;
  }

  static String getDateInputPlaceholder() {
    return 'dd/mm/aaaa';
  }

  // Date calculation helpers
  static DateTime addDaysToDate(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  static DateTime subtractDaysFromDate(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  static DateTime addMonthsToDate(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }

  static DateTime addYearsToDate(DateTime date, int years) {
    return DateTime(date.year + years, date.month, date.day);
  }

  static int getAgeInDays(DateTime birthDate) {
    return DateTime.now().difference(birthDate).inDays;
  }

  static int getAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    return (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
  }

  static int getAgeInYears(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

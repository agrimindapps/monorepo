class DateUtils {
  static String formatDateToString(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  static String formatTimeToString(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  static String formatDateTimeToString(int milliseconds) {
    return '${formatDateToString(milliseconds)} às ${formatTimeToString(milliseconds)}';
  }

  static String formatDateTimeToString24h(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  static DateTime? parseStringToDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length != 3) return null;
      
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      
      if (day == null || month == null || year == null) return null;
      
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseStringToDateTime(String dateTimeString) {
    try {
      final parts = dateTimeString.split(' ');
      if (parts.length != 2) return null;
      
      final date = parseStringToDate(parts[0]);
      if (date == null) return null;
      
      final timeParts = parts[1].split(':');
      if (timeParts.length != 2) return null;
      
      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      
      if (hour == null || minute == null) return null;
      
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  static bool isValidDate(DateTime date) {
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));
    final fiveYearsFromNow = now.add(const Duration(days: 1825));
    
    return !date.isBefore(oneYearAgo) && !date.isAfter(fiveYearsFromNow);
  }

  static bool isValidDateTime(DateTime dateTime) {
    return isValidDate(dateTime) && 
           dateTime.hour >= 0 && dateTime.hour <= 23 &&
           dateTime.minute >= 0 && dateTime.minute <= 59;
  }

  static bool isInPast(DateTime dateTime) {
    return dateTime.isBefore(DateTime.now());
  }

  static bool isInFuture(DateTime dateTime) {
    return dateTime.isAfter(DateTime.now());
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime normalizeDateTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute);
  }

  static int dateTimeToMilliseconds(DateTime date) {
    return date.millisecondsSinceEpoch;
  }

  static DateTime millisecondsToDateTime(int milliseconds) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  static bool isValidDateRange(DateTime start, DateTime end) {
    return end.isAfter(start) || end.isAtSameMomentAs(start);
  }

  static Duration getDurationBetween(DateTime start, DateTime end) {
    return end.difference(start);
  }

  static int getDaysBetween(DateTime start, DateTime end) {
    return normalizeDate(end).difference(normalizeDate(start)).inDays;
  }

  static int getHoursBetween(DateTime start, DateTime end) {
    return end.difference(start).inHours;
  }

  static int getMinutesBetween(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  static DateTime addHours(DateTime date, int hours) {
    return date.add(Duration(hours: hours));
  }

  static DateTime addMinutes(DateTime date, int minutes) {
    return date.add(Duration(minutes: minutes));
  }

  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  static DateTime subtractHours(DateTime date, int hours) {
    return date.subtract(Duration(hours: hours));
  }

  static DateTime subtractMinutes(DateTime date, int minutes) {
    return date.subtract(Duration(minutes: minutes));
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime getEndOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  static List<DateTime> getDateRangeList(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = normalizeDate(start);
    final normalizedEnd = normalizeDate(end);
    
    while (!current.isAfter(normalizedEnd)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }

  static String getWeekdayName(DateTime date) {
    const weekdays = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];
    return weekdays[date.weekday - 1];
  }

  static String getMonthName(DateTime date) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[date.month - 1];
  }

  static String getShortMonthName(DateTime date) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[date.month - 1];
  }
}
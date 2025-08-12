/// Centralized date utilities to replace duplicated date functions across modules
class CommonDateUtils {
  // Date formatting constants
  static const String defaultDateFormat = 'dd/MM/yyyy';
  static const String compactDateFormat = 'dd/MM';
  static const String fullDateFormat = 'dd/MM/yyyy HH:mm';
  
  // Month names in Portuguese
  static const List<String> monthNames = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  
  // Weekday names in Portuguese
  static const List<String> weekdayNames = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
  ];
  
  /// Formats timestamp to dd/MM/yyyy format
  static String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  /// Formats timestamp to dd/MM/yyyy format (alias for compatibility)
  static String formatDateToString(int milliseconds) {
    return formatDate(milliseconds);
  }
  
  /// Formats DateTime to dd/MM/yyyy format
  static String formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  /// Formats timestamp to dd/MM format (compact)
  static String formatDateCompact(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
  
  /// Formats timestamp to dd/MM/yyyy HH:mm format
  static String formatDateWithTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${formatDate(timestamp)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// Parses dd/MM/yyyy string to DateTime
  static DateTime? parseStringToDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length != 3) return null;
      
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      
      if (day == null || month == null || year == null) return null;
      
      // Validate date ranges
      if (month < 1 || month > 12) return null;
      if (day < 1 || day > 31) return null;
      if (year < 1900 || year > 2100) return null;
      
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }
  
  /// Parses dd/MM/yyyy string to timestamp
  static int? parseStringToTimestamp(String dateString) {
    final date = parseStringToDate(dateString);
    return date?.millisecondsSinceEpoch;
  }
  
  /// Checks if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// Checks if timestamp is today
  static bool isTodayTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return isToday(date);
  }
  
  /// Normalizes date to start of day (00:00:00)
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Normalizes timestamp to start of day
  static int normalizeDateTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return normalizeDate(date).millisecondsSinceEpoch;
  }
  
  /// Gets month name in Portuguese
  static String getMonthName(DateTime date) {
    return monthNames[date.month - 1];
  }
  
  /// Gets month name from timestamp
  static String getMonthNameFromTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return getMonthName(date);
  }
  
  /// Gets weekday name in Portuguese
  static String getWeekdayName(DateTime date) {
    return weekdayNames[date.weekday - 1];
  }
  
  /// Gets weekday name from timestamp
  static String getWeekdayNameFromTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return getWeekdayName(date);
  }
  
  /// Gets date range as list of DateTime objects
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
  
  /// Gets date range as list of timestamps
  static List<int> getDateRangeTimestamps(int startTimestamp, int endTimestamp) {
    final start = DateTime.fromMillisecondsSinceEpoch(startTimestamp);
    final end = DateTime.fromMillisecondsSinceEpoch(endTimestamp);
    return getDateRangeList(start, end)
        .map((date) => date.millisecondsSinceEpoch)
        .toList();
  }
  
  /// Calculates days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    return normalizeDate(end).difference(normalizeDate(start)).inDays;
  }
  
  /// Calculates days between two timestamps
  static int daysBetweenTimestamps(int startTimestamp, int endTimestamp) {
    final start = DateTime.fromMillisecondsSinceEpoch(startTimestamp);
    final end = DateTime.fromMillisecondsSinceEpoch(endTimestamp);
    return daysBetween(start, end);
  }
  
  /// Checks if date is in the past
  static bool isPast(DateTime date) {
    return normalizeDate(date).isBefore(normalizeDate(DateTime.now()));
  }
  
  /// Checks if timestamp is in the past
  static bool isPastTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return isPast(date);
  }
  
  /// Checks if date is in the future
  static bool isFuture(DateTime date) {
    return normalizeDate(date).isAfter(normalizeDate(DateTime.now()));
  }
  
  /// Checks if timestamp is in the future
  static bool isFutureTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return isFuture(date);
  }
  
  /// Adds days to a date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }
  
  /// Adds days to a timestamp
  static int addDaysToTimestamp(int timestamp, int days) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return addDays(date, days).millisecondsSinceEpoch;
  }
  
  /// Subtracts days from a date
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }
  
  /// Subtracts days from a timestamp
  static int subtractDaysFromTimestamp(int timestamp, int days) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return subtractDays(date, days).millisecondsSinceEpoch;
  }
  
  /// Gets the current timestamp
  static int getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }
  
  /// Gets timestamp for start of today
  static int getTodayStartTimestamp() {
    return normalizeDate(DateTime.now()).millisecondsSinceEpoch;
  }
  
  /// Gets timestamp for end of today
  static int getTodayEndTimestamp() {
    final today = normalizeDate(DateTime.now());
    return today.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)).millisecondsSinceEpoch;
  }
  
  /// Validates if a date string is in valid format
  static bool isValidDateString(String dateString) {
    return parseStringToDate(dateString) != null;
  }
  
  /// Validates if a timestamp is valid
  static bool isValidTimestamp(int timestamp) {
    try {
      DateTime.fromMillisecondsSinceEpoch(timestamp);
      return true;
    } catch (e) {
      return false;
    }
  }
}
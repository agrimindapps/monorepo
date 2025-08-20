// Package imports:
import 'package:intl/intl.dart';

class LembreteDateUtils {
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDateTimeShort(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM HH:mm').format(dateTime);
  }

  static DateTime? parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  static bool isToday(DateTime? dateTime) {
    if (dateTime == null) return false;
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  static bool isTomorrow(DateTime? dateTime) {
    if (dateTime == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
           dateTime.month == tomorrow.month &&
           dateTime.day == tomorrow.day;
  }

  static bool isThisWeek(DateTime? dateTime) {
    if (dateTime == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return dateTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           dateTime.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static List<String> getMonthsForFilter() {
    return [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
  }

  static String getMonthName(int month) {
    final months = getMonthsForFilter();
    return months[month - 1];
  }

  static Duration getDurationUntil(DateTime? dateTime) {
    if (dateTime == null) return Duration.zero;
    return dateTime.difference(DateTime.now());
  }

  static String getRelativeTimeText(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    if (isToday(dateTime)) {
      return 'Hoje às ${formatTime(dateTime)}';
    } else if (isTomorrow(dateTime)) {
      return 'Amanhã às ${formatTime(dateTime)}';
    } else {
      return formatDateTime(dateTime);
    }
  }
}

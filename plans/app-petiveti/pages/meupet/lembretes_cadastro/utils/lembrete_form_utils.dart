// Flutter imports:
import 'package:flutter/material.dart';

class LembreteFormUtils {
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime date, TimeOfDay time) {
    return '${formatDate(date)} às ${formatTime(time)}';
  }

  static String formatDateTimeFromMilliseconds(int milliseconds) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return '${formatDate(dateTime)} às ${formatTime(TimeOfDay.fromDateTime(dateTime))}';
  }

  static DateTime? parseDate(String dateString) {
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

  static TimeOfDay? parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;
      
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      
      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  static DateTime combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  static bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  static bool isToday(DateTime date) {
    return isSameDate(date, DateTime.now());
  }

  static bool isTomorrow(DateTime date) {
    return isSameDate(date, DateTime.now().add(const Duration(days: 1)));
  }

  static bool isYesterday(DateTime date) {
    return isSameDate(date, DateTime.now().subtract(const Duration(days: 1)));
  }

  static bool isPastDue(DateTime dateTime) {
    return dateTime.isBefore(DateTime.now());
  }

  static String getRelativeTimeDescription(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 0) {
        return 'Atrasado há ${absDifference.inDays} dia${absDifference.inDays > 1 ? 's' : ''}';
      } else if (absDifference.inHours > 0) {
        return 'Atrasado há ${absDifference.inHours} hora${absDifference.inHours > 1 ? 's' : ''}';
      } else {
        return 'Atrasado há ${absDifference.inMinutes} minuto${absDifference.inMinutes > 1 ? 's' : ''}';
      }
    } else {
      if (isToday(dateTime)) return 'Hoje';
      if (isTomorrow(dateTime)) return 'Amanhã';
      
      if (difference.inDays > 0) {
        return 'Em ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'Em ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else {
        return 'Em ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      }
    }
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  static String sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String getDateRangeDescription(DateTime start, DateTime end) {
    if (isSameDate(start, end)) {
      return formatDate(start);
    }
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  static Duration getTimeDifference(DateTime start, DateTime end) {
    return end.difference(start);
  }

  static int getMillisecondsSinceEpoch(DateTime date, TimeOfDay time) {
    return combineDateTime(date, time).millisecondsSinceEpoch;
  }

  static DateTime getNextOccurrence(DateTime baseDate, String repetirTipo) {
    switch (repetirTipo.toLowerCase()) {
      case 'diário':
        return baseDate.add(const Duration(days: 1));
      case 'semanal':
        return baseDate.add(const Duration(days: 7));
      case 'mensal':
        return DateTime(baseDate.year, baseDate.month + 1, baseDate.day, baseDate.hour, baseDate.minute);
      case 'anual':
        return DateTime(baseDate.year + 1, baseDate.month, baseDate.day, baseDate.hour, baseDate.minute);
      default:
        return baseDate;
    }
  }

  static List<DateTime> generateOccurrences(
    DateTime startDate,
    String repetirTipo,
    int count,
  ) {
    final occurrences = <DateTime>[startDate];
    var currentDate = startDate;

    for (int i = 1; i < count; i++) {
      currentDate = getNextOccurrence(currentDate, repetirTipo);
      occurrences.add(currentDate);
    }

    return occurrences;
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

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime getEndOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  static bool isInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
           date.isBefore(end.add(const Duration(days: 1)));
  }

  static String getFormattedDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} dia${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hora${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minuto${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  static Map<String, dynamic> exportToJson({
    required String titulo,
    required String descricao,
    required DateTime dataLembrete,
    required TimeOfDay horaLembrete,
    required String tipo,
    required String repetir,
    required bool concluido,
    required String animalId,
  }) {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'data': formatDate(dataLembrete),
      'hora': formatTime(horaLembrete),
      'dataHora': formatDateTime(dataLembrete, horaLembrete),
      'tipo': tipo,
      'repetir': repetir,
      'concluido': concluido,
      'animalId': animalId,
      'timestamp': getMillisecondsSinceEpoch(dataLembrete, horaLembrete),
      'relativeTime': getRelativeTimeDescription(combineDateTime(dataLembrete, horaLembrete)),
    };
  }

  static String escapeForCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static List<String> getAvailableTimeSlots({
    DateTime? selectedDate,
    int intervalMinutes = 30,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    final start = startTime ?? const TimeOfDay(hour: 8, minute: 0);
    final end = endTime ?? const TimeOfDay(hour: 18, minute: 0);
    final slots = <String>[];
    
    var current = start;
    while (current.hour < end.hour || (current.hour == end.hour && current.minute <= end.minute)) {
      slots.add(formatTime(current));
      
      final totalMinutes = current.hour * 60 + current.minute + intervalMinutes;
      current = TimeOfDay(
        hour: totalMinutes ~/ 60,
        minute: totalMinutes % 60,
      );
      
      if (current.hour >= 24) break;
    }
    
    return slots;
  }
}

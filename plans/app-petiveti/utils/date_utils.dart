class DateUtils {
  /// Formats timestamp to dd/MM/yyyy format
  static String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  /// Formats date range
  static String formatDateRange(DateTime start, DateTime end) {
    final startStr = formatDate(start.millisecondsSinceEpoch);
    final endStr = formatDate(end.millisecondsSinceEpoch);
    return '$startStr - $endStr';
  }
  
  /// Get relative time string
  static String getRelativeTimeString(DateTime date) {
    if (isToday(date)) return 'Hoje';
    if (isTomorrow(date)) return 'Amanhã';
    if (isYesterday(date)) return 'Ontem';
    
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 365) {
        final years = (absDifference.inDays / 365).floor();
        return 'há $years ano${years > 1 ? 's' : ''}';
      } else if (absDifference.inDays > 30) {
        final months = (absDifference.inDays / 30).floor();
        return 'há $months mês${months > 1 ? 'es' : ''}';
      } else if (absDifference.inDays > 0) {
        return 'há ${absDifference.inDays} dia${absDifference.inDays > 1 ? 's' : ''}';
      } else if (absDifference.inHours > 0) {
        return 'há ${absDifference.inHours} hora${absDifference.inHours > 1 ? 's' : ''}';
      } else {
        return 'há ${absDifference.inMinutes} minuto${absDifference.inMinutes > 1 ? 's' : ''}';
      }
    } else {
      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return 'em $years ano${years > 1 ? 's' : ''}';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return 'em $months mês${months > 1 ? 'es' : ''}';
      } else if (difference.inDays > 0) {
        return 'em ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'em ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else {
        return 'em ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      }
    }
  }
  
  /// Format duration to readable string
  static String formatTimePeriod(Duration duration) {
    if (duration.inDays > 365) {
      final years = (duration.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'}';
    } else if (duration.inDays > 30) {
      final months = (duration.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'}';
    } else if (duration.inDays > 7) {
      final weeks = (duration.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (duration.inDays > 0) {
      return '${duration.inDays} ${duration.inDays == 1 ? 'dia' : 'dias'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ${duration.inHours == 1 ? 'hora' : 'horas'}';
    } else {
      return '${duration.inMinutes} ${duration.inMinutes == 1 ? 'minuto' : 'minutos'}';
    }
  }
  
  /// Parse string date to DateTime
  static DateTime? parseStringToDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length != 3) return null;
      
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      
      if (day == null || month == null || year == null) return null;
      if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900) return null;
      
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }
  
  /// Normalize date to start of day
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Get month name in Portuguese
  static String getMes(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }
  
  /// Get abbreviated month name in Portuguese
  static String getMesAbreviado(int month) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[month - 1];
  }
  
  /// Get weekday name in Portuguese
  static String getDiaSemana(int weekday) {
    const weekdays = [
      'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
      'Sexta-feira', 'Sábado', 'Domingo'
    ];
    return weekdays[weekday - 1];
  }
  
  /// Get abbreviated weekday name in Portuguese
  static String getDiaSemanaAbreviado(int weekday) {
    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return weekdays[weekday - 1];
  }
  
  /// Format date with time
  static String formatDateComplete(DateTime date) {
    return '${formatDate(date.millisecondsSinceEpoch)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  /// Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
  
  /// Check if date is this year
  static bool isThisYear(DateTime date) {
    return date.year == DateTime.now().year;
  }
  
  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
  
  /// Get start of day
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Get end of day
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
  /// Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// Get end of month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }
  
  /// Get start of week
  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
  
  /// Get end of week
  static DateTime getEndOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }
  
  /// Get start of year
  static DateTime getStartOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }
  
  /// Get end of year
  static DateTime getEndOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }
  
  /// Get date range between two dates
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = getStartOfDay(start);
    final normalizedEnd = getStartOfDay(end);
    
    while (!current.isAfter(normalizedEnd)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }
  
  /// Check if date is in range
  static bool isInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
           date.isBefore(end.add(const Duration(days: 1)));
  }
  
  /// Get formatted date range
  static String getFormattedRange(DateTime start, DateTime end) {
    if (isSameDay(start, end)) {
      return formatDate(start.millisecondsSinceEpoch);
    }
    return '${formatDate(start.millisecondsSinceEpoch)} - ${formatDate(end.millisecondsSinceEpoch)}';
  }
  
  /// Get formatted month for current date or specific date (MMM YY format)
  static String getFormattedMonth([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[targetDate.month - 1]} ${targetDate.year.toString().substring(2)}';
  }
  
  /// Format current date
  static String formatarDataAtual() {
    return formatDate(DateTime.now().millisecondsSinceEpoch);
  }
  
  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }
  
  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
  
  /// Check if date is overdue (past today)
  static bool isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    return targetDay.isBefore(today);
  }
}
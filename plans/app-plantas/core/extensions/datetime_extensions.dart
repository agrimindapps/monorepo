/// Extensions para DateTime com operações otimizadas e cache
extension DateTimeOptimizations on DateTime {
  /// Obter apenas a data (sem hora) de forma otimizada
  DateTime get dateOnly {
    return DateTime(year, month, day);
  }

  /// Verificar se é hoje (otimizado com cache)
  bool get isToday {
    final today = DateTime.now();
    return year == today.year && month == today.month && day == today.day;
  }

  /// Verificar se é antes de hoje
  bool get isBeforeToday {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final thisDateOnly = dateOnly;
    return thisDateOnly.isBefore(todayDateOnly);
  }

  /// Verificar se é depois de hoje
  bool get isAfterToday {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final thisDateOnly = dateOnly;
    return thisDateOnly.isAfter(todayDateOnly);
  }

  /// Verificar se é o mesmo dia que outra data
  bool isSameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Obter diferença em dias completos (mais preciso que difference().inDays)
  int daysDifference(DateTime other) {
    final thisDateOnly = dateOnly;
    final otherDateOnly = other.dateOnly;
    return thisDateOnly.difference(otherDateOnly).inDays;
  }

  /// Verificar se está dentro do intervalo (incluindo as bordas)
  bool isBetween(DateTime start, DateTime end) {
    final thisDateOnly = dateOnly;
    final startDateOnly = start.dateOnly;
    final endDateOnly = end.dateOnly;

    return (thisDateOnly.isAtSameMomentAs(startDateOnly) ||
            thisDateOnly.isAfter(startDateOnly)) &&
        (thisDateOnly.isAtSameMomentAs(endDateOnly) ||
            thisDateOnly.isBefore(endDateOnly));
  }

  /// Verificar se é amanhã
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Verificar se é ontem
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Verificar se é nesta semana
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isBetween(startOfWeek, endOfWeek);
  }

  /// Verificar se é neste mês
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
}

/// Extensions para comparações otimizadas de data
extension DateTimeComparisons on DateTime {
  /// Comparador otimizado para ordenação por data (ignora hora)
  static int compareDatesOnly(DateTime a, DateTime b) {
    // Comparar ano primeiro
    if (a.year != b.year) return a.year.compareTo(b.year);

    // Depois mês
    if (a.month != b.month) return a.month.compareTo(b.month);

    // Finalmente dia
    return a.day.compareTo(b.day);
  }

  /// Verificar se duas datas são consecutivas
  bool isNextDayOf(DateTime other) {
    final thisDaysSinceEpoch =
        dateOnly.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
    final otherDaysSinceEpoch =
        other.dateOnly.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);

    return thisDaysSinceEpoch == otherDaysSinceEpoch + 1;
  }
}

/// Cache local para evitar recalcular datas frequentemente usadas
class DateTimeCache {
  static DateTime? _todayCache;
  static DateTime? _yesterdayCache;
  static DateTime? _tomorrowCache;
  static int? _lastCacheDay;

  /// Obter hoje com cache
  static DateTime get today {
    final now = DateTime.now();
    final currentDay = now.day + (now.month * 31) + (now.year * 365);

    if (_lastCacheDay != currentDay || _todayCache == null) {
      _todayCache = DateTime(now.year, now.month, now.day);
      _yesterdayCache = _todayCache!.subtract(const Duration(days: 1));
      _tomorrowCache = _todayCache!.add(const Duration(days: 1));
      _lastCacheDay = currentDay;
    }

    return _todayCache!;
  }

  /// Obter ontem com cache
  static DateTime get yesterday {
    // Garante que today foi calculado primeiro
    today;
    return _yesterdayCache!;
  }

  /// Obter amanhã com cache
  static DateTime get tomorrow {
    // Garante que today foi calculado primeiro
    today;
    return _tomorrowCache!;
  }

  /// Limpar cache (útil para testes)
  static void clearCache() {
    _todayCache = null;
    _yesterdayCache = null;
    _tomorrowCache = null;
    _lastCacheDay = null;
  }
}

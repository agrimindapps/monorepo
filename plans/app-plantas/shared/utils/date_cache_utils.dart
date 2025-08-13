/// Utilities para operações com data otimizadas para evitar recálculos
class DateUtils {
  static DateTime? _cachedToday;
  static DateTime? _cachedTodayDateOnly;
  static int? _cachedTodayDay;

  /// Obter data/hora atual com cache opcional para evitar múltiplas chamadas
  static DateTime now({bool useCache = false}) {
    if (useCache && _cachedToday != null) {
      return _cachedToday!;
    }

    final now = DateTime.now();
    if (useCache) {
      _cachedToday = now;
    }
    return now;
  }

  /// Obter data atual (sem hora) com cache para evitar recálculos
  static DateTime todayDateOnly({bool useCache = false}) {
    if (useCache && _cachedTodayDateOnly != null) {
      return _cachedTodayDateOnly!;
    }

    final today = now(useCache: useCache);
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    if (useCache) {
      _cachedTodayDateOnly = todayDateOnly;
    }
    return todayDateOnly;
  }

  /// Converter DateTime para date-only de forma otimizada
  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Comparar se duas datas são do mesmo dia (ignora hora)
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Verificar se uma data é hoje
  static bool isToday(DateTime date, {bool useCache = true}) {
    final today = todayDateOnly(useCache: useCache);
    return isSameDay(date, today);
  }

  /// Verificar se uma data é antes de hoje
  static bool isBeforeToday(DateTime date, {bool useCache = true}) {
    final today = todayDateOnly(useCache: useCache);
    final dateOnly = DateUtils.dateOnly(date);
    return dateOnly.isBefore(today);
  }

  /// Verificar se uma data é depois de hoje
  static bool isAfterToday(DateTime date, {bool useCache = true}) {
    final today = todayDateOnly(useCache: useCache);
    final dateOnly = DateUtils.dateOnly(date);
    return dateOnly.isAfter(today);
  }

  /// Limpar cache (útil para testes ou mudança de dia)
  static void clearCache() {
    _cachedToday = null;
    _cachedTodayDateOnly = null;
    _cachedTodayDay = null;
  }

  /// Obter cache do dia atual (para evitar múltiplas criações do mesmo objeto)
  static int get cachedTodayDay {
    if (_cachedTodayDay == null) {
      final today = now();
      _cachedTodayDay =
          DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
    }
    return _cachedTodayDay!;
  }
}

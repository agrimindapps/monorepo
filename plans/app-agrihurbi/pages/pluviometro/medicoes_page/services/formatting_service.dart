// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'cache_service.dart';

/// Service responsável por formatação de dados padronizada
class FormattingService {
  static final FormattingService _instance = FormattingService._internal();
  factory FormattingService() => _instance;
  FormattingService._internal();

  final CacheService _cache = CacheService();

  // Formatadores padronizados - Issue #18
  static final DateFormat _standardDateFormat =
      DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM', 'pt_BR');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'pt_BR');
  static final DateFormat _weekDayFormat = DateFormat('EEEE', 'pt_BR');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'pt_BR');
  static final DateFormat _shortMonthYearFormat = DateFormat('MMM yy', 'pt_BR');
  static final DateFormat _monthOnlyFormat = DateFormat('MMMM', 'pt_BR');
  static final NumberFormat _precipitationFormat = NumberFormat('0.0', 'pt_BR');
  static final NumberFormat _percentageFormat = NumberFormat('0.0', 'pt_BR');
  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'pt_BR');

  /// Formata data no padrão brasileiro completo com cache
  String formatDate(DateTime date) {
    final key = 'date_${date.millisecondsSinceEpoch}';
    return _cache.getCachedFormatting(key, 'formatDate') ??
        _cacheAndReturn(key, 'formatDate', _standardDateFormat.format(date));
  }

  /// Formata data no padrão curto (dd/MM)
  String formatShortDate(DateTime date) {
    final key = 'short_date_${date.millisecondsSinceEpoch}';
    return _cache.getCachedFormatting(key, 'formatShortDate') ??
        _cacheAndReturn(key, 'formatShortDate', _shortDateFormat.format(date));
  }

  /// Formata hora
  String formatTime(DateTime date) {
    final key = 'time_${date.millisecondsSinceEpoch}';
    return _cache.getCachedFormatting(key, 'formatTime') ??
        _cacheAndReturn(key, 'formatTime', _timeFormat.format(date));
  }

  /// Formata data e hora completos
  String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  /// Formata dia da semana de forma padronizada
  String formatWeekDay(DateTime date) {
    final key = 'weekday_${date.year}_${date.month}_${date.day}';
    return _cache.getCachedFormatting(key, 'formatWeekDay') ??
        _cacheAndReturn(
          key,
          'formatWeekDay',
          _weekDayFormat.format(date).capitalize().replaceAll('-feira', ''),
        );
  }

  /// Formata mês e ano completo (Janeiro 2024)
  String formatMonthYear(DateTime date) {
    final key = 'month_year_${date.year}_${date.month}';
    return _cache.getCachedFormatting(key, 'formatMonthYear') ??
        _cacheAndReturn(
          key,
          'formatMonthYear',
          _monthYearFormat.format(date).capitalize(),
        );
  }

  /// Formata mês e ano curto (Jan 24)
  String formatShortMonthYear(DateTime date) {
    final key = 'short_month_year_${date.year}_${date.month}';
    return _cache.getCachedFormatting(key, 'formatShortMonthYear') ??
        _cacheAndReturn(
          key,
          'formatShortMonthYear',
          _shortMonthYearFormat.format(date).capitalize(),
        );
  }

  /// Formata apenas o mês (Janeiro)
  String formatMonthOnly(DateTime date) {
    final key = 'month_only_${date.month}';
    return _cache.getCachedFormatting(key, 'formatMonthOnly') ??
        _cacheAndReturn(
          key,
          'formatMonthOnly',
          _monthOnlyFormat.format(date).capitalize(),
        );
  }

  /// Formata valor de precipitação de forma padronizada
  String formatPrecipitation(double value) {
    final key = 'precipitation_$value';
    return _cache.getCachedFormatting(key, 'formatPrecipitation') ??
        _cacheAndReturn(
          key,
          'formatPrecipitation',
          '${_precipitationFormat.format(value)} mm',
        );
  }

  /// Formata porcentagem de forma padronizada
  String formatPercentage(double value) {
    final key = 'percentage_$value';
    return _cache.getCachedFormatting(key, 'formatPercentage') ??
        _cacheAndReturn(
          key,
          'formatPercentage',
          '${_percentageFormat.format(value)}%',
        );
  }

  /// Gera lista de dias do mês formatados
  List<String> generateFormattedDaysOfMonth({DateTime? referenceDate}) {
    final date = referenceDate ?? DateTime.now();
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);

    final List<String> days = [];
    for (var i = 0; i < lastDay.day; i++) {
      final currentDay = firstDay.add(Duration(days: i));
      days.add(formatDate(currentDay));
    }
    return days;
  }

  /// Formata duração em formato legível
  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} dias';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} horas';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutos';
    } else {
      return '${duration.inSeconds} segundos';
    }
  }

  /// Formata número com separador de milhares
  String formatNumber(num value) {
    final key = 'number_$value';
    return _cache.getCachedFormatting(key, 'formatNumber') ??
        _cacheAndReturn(key, 'formatNumber', _numberFormat.format(value));
  }

  /// Invalida cache de formatação
  void invalidateFormattingCache() {
    _cache.invalidatePattern('format');
  }

  /// Helper method para cache e retorno
  String _cacheAndReturn(String key, String operation, String result) {
    _cache.cacheFormatting(key, operation, result);
    return result;
  }

  /// Constantes de formato padronizadas para consistência
  static const Map<String, String> standardFormats = {
    'date': 'dd/MM/yyyy',
    'shortDate': 'dd/MM',
    'time': 'HH:mm',
    'monthYear': 'MMMM yyyy',
    'shortMonthYear': 'MMM yy',
    'weekDay': 'EEEE',
    'precipitation': '0.0 mm',
    'percentage': '0.0%',
    'number': '#,##0',
  };

  /// Obtém padrão de formato por tipo
  static String getFormatPattern(String type) {
    return standardFormats[type] ?? 'dd/MM/yyyy';
  }
}

/// Extension para capitalizar strings
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

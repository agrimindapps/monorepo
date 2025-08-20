// Package imports:
import 'package:intl/intl.dart';

/// Service centralizado para formatação de dados de medições
class MedicoesFormatters {
  static final MedicoesFormatters _instance = MedicoesFormatters._internal();
  factory MedicoesFormatters() => _instance;
  MedicoesFormatters._internal();

  // Formatadores padrão
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'pt_BR');
  static final DateFormat _dateTimeFormat =
      DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
  static final DateFormat _monthYearFormat = DateFormat('MMM yy', 'pt_BR');
  static final DateFormat _fullMonthFormat = DateFormat('MMMM yyyy', 'pt_BR');

  // Cache para evitar reprocessamento
  final Map<String, String> _cache = {};

  /// Formatar quantidade de precipitação
  String formatQuantidade(double quantidade, {int decimals = 1}) {
    final key = 'quantidade_${quantidade}_$decimals';
    return _cache.putIfAbsent(key, () {
      if (quantidade == 0) return '0.0 mm';
      if (quantidade < 1) return '${quantidade.toStringAsFixed(2)} mm';
      return '${quantidade.toStringAsFixed(decimals)} mm';
    });
  }

  /// Formatar data simples
  String formatDate(DateTime date) {
    final key = 'date_${date.millisecondsSinceEpoch}';
    return _cache.putIfAbsent(key, () => _dateFormat.format(date));
  }

  /// Formatar hora
  String formatTime(DateTime date) {
    final key = 'time_${date.millisecondsSinceEpoch}';
    return _cache.putIfAbsent(key, () => _timeFormat.format(date));
  }

  /// Formatar data e hora
  String formatDateTime(DateTime date) {
    final key = 'datetime_${date.millisecondsSinceEpoch}';
    return _cache.putIfAbsent(key, () => _dateTimeFormat.format(date));
  }

  /// Formatar mês e ano (ex: Jan 25)
  String formatMonthYear(DateTime date) {
    final key = 'monthyear_${date.year}_${date.month}';
    return _cache.putIfAbsent(key, () {
      return _monthYearFormat.format(date).capitalize();
    });
  }

  /// Formatar mês completo (ex: Janeiro 2025)
  String formatFullMonth(DateTime date) {
    final key = 'fullmonth_${date.year}_${date.month}';
    return _cache.putIfAbsent(key, () {
      return _fullMonthFormat.format(date).capitalize();
    });
  }

  /// Formatar dia da semana
  String formatWeekday(DateTime date) {
    final key = 'weekday_${date.weekday}';
    return _cache.putIfAbsent(key, () {
      return DateFormat('EEEE', 'pt_BR')
          .format(date)
          .capitalize()
          .replaceAll('-feira', '');
    });
  }

  /// Formatar timestamp para string legível
  String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return formatDateTime(date);
  }

  /// Formatar duração relativa (ex: "há 2 horas")
  String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'há 1 ano' : 'há $years anos';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'há 1 mês' : 'há $months meses';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? 'há 1 dia'
          : 'há ${difference.inDays} dias';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? 'há 1 hora'
          : 'há ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? 'há 1 minuto'
          : 'há ${difference.inMinutes} minutos';
    } else {
      return 'agora';
    }
  }

  /// Formatar range de valores
  String formatRange(double min, double max, {int decimals = 1}) {
    return '${min.toStringAsFixed(decimals)} - ${max.toStringAsFixed(decimals)} mm';
  }

  /// Formatar estatísticas
  String formatStatistic(double value, String unit, {int decimals = 1}) {
    if (value == 0) return '0.0 $unit';
    return '${value.toStringAsFixed(decimals)} $unit';
  }

  /// Formatar porcentagem
  String formatPercentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Formatar número com separador de milhares
  String formatNumber(double value, {int decimals = 0}) {
    final formatter = NumberFormat('#,##0.${'0' * decimals}', 'pt_BR');
    return formatter.format(value);
  }

  /// Formatar observações (truncar se necessário)
  String formatObservacoes(String? observacoes, {int maxLength = 100}) {
    if (observacoes == null || observacoes.isEmpty) return '-';

    if (observacoes.length <= maxLength) return observacoes;

    return '${observacoes.substring(0, maxLength)}...';
  }

  /// Formatar ID para exibição
  String formatId(String id, {int maxLength = 8}) {
    if (id.length <= maxLength) return id;
    return '${id.substring(0, maxLength)}...';
  }

  /// Formatar status booleano
  String formatBoolean(bool value,
      {String trueText = 'Sim', String falseText = 'Não'}) {
    return value ? trueText : falseText;
  }

  /// Formatar lista de itens
  String formatList(List<String> items,
      {String separator = ', ', String lastSeparator = ' e '}) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first;
    if (items.length == 2) return '${items.first}$lastSeparator${items.last}';

    final allButLast = items.sublist(0, items.length - 1).join(separator);
    return '$allButLast$lastSeparator${items.last}';
  }

  /// Formatar tamanho de arquivo
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Limpar cache
  void clearCache() {
    _cache.clear();
  }

  /// Obter estatísticas do cache
  Map<String, int> getCacheStats() {
    return {
      'size': _cache.length,
      'maxSize': 1000, // Limite sugerido
    };
  }
}

/// Extensão para capitalizar strings
extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

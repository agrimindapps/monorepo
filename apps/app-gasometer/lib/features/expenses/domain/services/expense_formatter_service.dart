import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Serviço especializado para formatação de campos de despesas
/// Implementa formatação brasileira com vírgula decimal e cache para performance
class ExpenseFormatterService {
  
  /// Cria uma nova instância do serviço de formatação
  ExpenseFormatterService();
  // Cache para formatações recentes (memoização)
  final Map<String, String> _formatCache = <String, String>{};
  static const int _maxCacheSize = 100;

  // Formatadores brasileiros
  final _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  final _dateFormatter = DateFormat('dd/MM/yyyy', 'pt_BR');
  final _timeFormatter = DateFormat('HH:mm', 'pt_BR');
  final _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  // Constantes de formatação
  static const String decimalSeparator = ',';
  static const String dotSeparator = '.';
  static const String thousandSeparator = '.';
  static const int amountDecimals = 2;
  static const int odometerDecimals = 1;

  /// Formata valor monetário em formato brasileiro
  String formatAmount(double value) {
    if (value == 0.0) return '';
    return _formatWithCache(value, amountDecimals, 'amount', () {
      return _currencyFormatter.format(value);
    });
  }

  /// Formata odômetro com 1 casa decimal
  String formatOdometer(double value) {
    if (value == 0.0) return '';
    return _formatWithCache(value, odometerDecimals, 'odometer', () {
      final String formatted = value.toStringAsFixed(odometerDecimals);
      return formatted.replaceAll(dotSeparator, decimalSeparator);
    });
  }

  /// Formata data no padrão brasileiro
  String formatDate(DateTime date) {
    final key = 'date_${date.millisecondsSinceEpoch}';
    if (_formatCache.containsKey(key)) {
      return _formatCache[key]!;
    }

    final formatted = _dateFormatter.format(date);
    _addToCache(key, formatted);
    return formatted;
  }

  /// Formata horário no padrão brasileiro (24h)
  String formatTime(DateTime dateTime) {
    final key = 'time_${dateTime.millisecondsSinceEpoch}';
    if (_formatCache.containsKey(key)) {
      return _formatCache[key]!;
    }

    final formatted = _timeFormatter.format(dateTime);
    _addToCache(key, formatted);
    return formatted;
  }

  /// Formata data e hora completa
  String formatDateTime(DateTime dateTime) {
    final key = 'datetime_${dateTime.millisecondsSinceEpoch}';
    if (_formatCache.containsKey(key)) {
      return _formatCache[key]!;
    }

    final formatted = _dateTimeFormatter.format(dateTime);
    _addToCache(key, formatted);
    return formatted;
  }

  /// Formata com cache para melhor performance
  String _formatWithCache(
    double value,
    int decimals,
    String type,
    String Function() formatter,
  ) {
    final key = '${type}_${value}_$decimals';

    if (_formatCache.containsKey(key)) {
      return _formatCache[key]!;
    }

    final formatted = formatter();
    _addToCache(key, formatted);
    return formatted;
  }

  /// Converte string formatada para double
  double parseFormattedAmount(String value) {
    if (value.isEmpty) return 0.0;

    // Remove formatação brasileira: 1.234,56 -> 1234.56
    final cleanValue = value
        .replaceAll(RegExp(r'\s'), '') // Remove espaços
        .replaceAll(thousandSeparator, '') // Remove separadores de milhar
        .replaceAll(decimalSeparator, dotSeparator) // Vírgula para ponto
        .replaceAll(RegExp(r'[^\d\.]'), ''); // Remove caracteres não numéricos

    return double.tryParse(cleanValue) ?? 0.0;
  }

  /// Converte string formatada para double (odômetro)
  double parseFormattedOdometer(String value) {
    if (value.isEmpty) return 0.0;

    final cleanValue = value
        .replaceAll(decimalSeparator, dotSeparator)
        .replaceAll(RegExp(r'[^\d\.]'), '');

    return double.tryParse(cleanValue) ?? 0.0;
  }

  /// Sanitiza entrada removendo caracteres perigosos
  String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>"\\&%$#@!*()[\]{}]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// InputFormatter para valores monetários brasileiros
  TextInputFormatter get amountFormatter => _AmountFormatter();

  /// InputFormatter para odômetro (até 1 casa decimal)
  TextInputFormatter get odometerFormatter => _OdometerFormatter();

  /// InputFormatter para descrição (sem caracteres especiais)
  TextInputFormatter get descriptionFormatter => _DescriptionFormatter();

  void _addToCache(String key, String value) {
    if (_formatCache.length >= _maxCacheSize) {
      final firstKey = _formatCache.keys.first;
      _formatCache.remove(firstKey);
    }
    _formatCache[key] = value;
  }

  /// Limpa cache de formatação
  void clearCache() {
    _formatCache.clear();
  }

  /// Formata valores para exibição em relatórios
  String formatReportAmount(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1).replaceAll('.', ',')}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1).replaceAll('.', ',')}K';
    } else {
      return formatAmount(value);
    }
  }

  /// Retorna símbolo de moeda brasileiro
  String get currencySymbol => 'R\$';

  /// Retorna padrão de data brasileiro
  String get datePattern => 'dd/MM/yyyy';

  /// Retorna padrão de hora brasileiro
  String get timePattern => 'HH:mm';

  /// Formata período simples (para estatísticas)
  String formatPeriod(DateTime date) {
    final monthFormatter = DateFormat('MMM yyyy', 'pt_BR');
    return monthFormatter.format(date);
  }
}

/// Formatter para valores monetários brasileiros
class _AmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Permitir apenas números e vírgula/ponto decimal
    if (!RegExp(r'^\d{0,8}[,.]?\d{0,2}$').hasMatch(text)) {
      return oldValue;
    }

    // Substituir ponto por vírgula
    String formattedText = text.replaceAll('.', ',');

    // Aplicar formatação de milhares se necessário
    if (!formattedText.contains(',') && formattedText.length > 3) {
      final number = int.tryParse(formattedText);
      if (number != null) {
        final formatted = NumberFormat('#,###', 'pt_BR').format(number);
        formattedText = formatted.replaceAll('.', ',');
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Formatter para odômetro (até 1 casa decimal)
class _OdometerFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Permitir até 999999,9 km
    if (!RegExp(r'^\d{0,6}[,.]?\d{0,1}$').hasMatch(text)) {
      return oldValue;
    }

    // Substituir ponto por vírgula
    final formattedText = text.replaceAll('.', ',');

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Formatter para descrição (sem caracteres especiais perigosos)
class _DescriptionFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Remove caracteres perigosos
    final sanitized = text
        .replaceAll(RegExp(r'[<>"\\&%$#@!*()[\]{}]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');

    // Limita tamanho
    final limited = sanitized.length > 100 ? sanitized.substring(0, 100) : sanitized;

    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}
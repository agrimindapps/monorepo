import 'package:flutter/services.dart';

/// Serviço especializado para formatação de campos de combustível
/// Implementa formatação brasileira com vírgula decimal e cache para performance
class FuelFormatterService {
  factory FuelFormatterService() => _instance;
  FuelFormatterService._internal();
  static final FuelFormatterService _instance = FuelFormatterService._internal();
  final Map<String, String> _formatCache = {};
  static const int _maxCacheSize = 100;
  static const String decimalSeparator = ',';
  static const String dotSeparator = '.';
  static const int litrosDecimals = 3;
  static const int priceDecimals = 3;
  static const int totalDecimals = 2;
  static const int odometerDecimals = 1;

  /// Formata litros com até 3 casas decimais
  String formatLiters(double value) {
    if (value == 0.0) return '';
    return _formatWithCache(value, litrosDecimals, 'liters');
  }

  /// Formata preço por litro com 3 casas decimais
  String formatPricePerLiter(double value) {
    if (value == 0.0) return '';
    return _formatWithCache(value, priceDecimals, 'price');
  }

  /// Formata valor total com 2 casas decimais
  String formatTotalPrice(double value) {
    if (value == 0.0) return '';
    return _formatWithCache(value, totalDecimals, 'total');
  }

  /// Formata odômetro com 1 casa decimal
  String formatOdometer(double value) {
    if (value == 0.0) return '';
    return _formatWithCache(value, odometerDecimals, 'odometer');
  }

  /// Formata com cache para melhor performance
  String _formatWithCache(double value, int decimals, String type) {
    final key = '${type}_${value}_$decimals';

    if (_formatCache.containsKey(key)) {
      return _formatCache[key]!;
    }

    String formatted = value.toStringAsFixed(decimals);
    formatted = formatted.replaceAll(dotSeparator, decimalSeparator);

    _addToCache(key, formatted);
    return formatted;
  }

  /// Converte string formatada para double
  double parseFormattedValue(String value) {
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

  /// InputFormatter para litros (até 3 casas decimais)
  TextInputFormatter get litersFormatter => _LitersFormatter();

  /// InputFormatter para preços (até 3 casas decimais)
  TextInputFormatter get priceFormatter => _PriceFormatter();

  /// InputFormatter para odômetro (até 1 casa decimal)
  TextInputFormatter get odometerFormatter => _OdometerFormatter();

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
}

/// Formatter para litros (até 3 casas decimais)
class _LitersFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (!RegExp(r'^\d{0,4}[,.]?\d{0,3}$').hasMatch(text)) {
      return oldValue;
    }
    final formattedText = text.replaceAll('.', ',');

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Formatter para preços (até 3 casas decimais)
class _PriceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (!RegExp(r'^\d{0,1}[,.]?\d{0,3}$').hasMatch(text)) {
      return oldValue;
    }
    final formattedText = text.replaceAll('.', ',');

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
    if (!RegExp(r'^\d{0,6}[,.]?\d{0,1}$').hasMatch(text)) {
      return oldValue;
    }
    final formattedText = text.replaceAll('.', ',');

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

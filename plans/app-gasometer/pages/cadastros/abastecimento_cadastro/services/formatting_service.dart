// Flutter imports:
import 'package:flutter/services.dart';

/// Serviço otimizado para formatação de campos numéricos
/// Implementa memoização e cache para melhorar performance
class FormattingService {
  static final FormattingService _instance = FormattingService._internal();
  factory FormattingService() => _instance;
  FormattingService._internal();

  // Cache para formatações recentes
  final Map<String, String> _formatCache = {};
  static const int _maxCacheSize = 100;

  /// Formata valor numérico com memoização
  String formatNumericValue(double value, int decimals,
      {bool replaceDecimalSeparator = true}) {
    final key = '${value}_${decimals}_$replaceDecimalSeparator';

    if (_formatCache.containsKey(key)) {
      return _formatCache[key]!;
    }

    final formatted = value.toStringAsFixed(decimals);
    final result =
        replaceDecimalSeparator ? formatted.replaceAll('.', ',') : formatted;

    _addToCache(key, result);
    return result;
  }

  /// Limpa valor formatado para conversão numérica
  double parseFormattedValue(String value) {
    if (value.isEmpty) return 0.0;

    final cleanValue = value.replaceAll(',', '.');
    return double.tryParse(cleanValue) ?? 0.0;
  }

  /// InputFormatter otimizado para litros (até 3 casas decimais)
  TextInputFormatter get litrosFormatter => _LitrosFormatter();

  /// InputFormatter otimizado para valores monetários (2 casas decimais)
  TextInputFormatter get currencyFormatter => _CurrencyFormatter();

  /// InputFormatter otimizado para odômetro (2 casas decimais)
  TextInputFormatter get odometroFormatter => _OdometroFormatter();

  void _addToCache(String key, String value) {
    if (_formatCache.length >= _maxCacheSize) {
      // Remove o primeiro item (FIFO)
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

/// Formatter otimizado para campo de litros
class _LitrosFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Permitir apenas números, vírgulas e pontos
    if (!RegExp(r'^\d{0,3}[,.]?\d{0,3}$').hasMatch(text)) {
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

/// Formatter otimizado para valores monetários
class _CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Permitir apenas números, vírgulas e pontos
    if (!RegExp(r'^\d*[,.]?\d{0,2}$').hasMatch(text)) {
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

/// Formatter otimizado para odômetro
class _OdometroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Permitir apenas números, vírgulas e pontos
    if (!RegExp(r'^\d*[,.]?\d{0,2}$').hasMatch(text)) {
      return oldValue;
    }

    // Substituir ponto por vírgula e limitar casas decimais
    String formattedText = text.replaceAll('.', ',');

    if (formattedText.contains(',')) {
      final parts = formattedText.split(',');
      if (parts.length == 2 && parts[1].length > 2) {
        formattedText = '${parts[0]},${parts[1].substring(0, 2)}';
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

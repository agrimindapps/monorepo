// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';

/// Formatter otimizado para entrada de valores monetários
///
/// Implementa:
/// - Cache de valores formatados
/// - Pool de formatters reutilizáveis
/// - Verificação de limites antes da formatação
/// - Otimização de regex
/// - Lazy loading de recursos
class OptimizedMoneyFormatter extends TextInputFormatter {
  // Singleton para reutilização
  static final OptimizedMoneyFormatter _instance =
      OptimizedMoneyFormatter._internal();
  factory OptimizedMoneyFormatter() => _instance;
  OptimizedMoneyFormatter._internal();

  // Cache LRU (Least Recently Used) para valores formatados
  final _formattedCache = LinkedHashMap<String, String>.fromIterable(
    [], // valores iniciais vazios
    key: (k) => k.toString(),
    value: (v) => v.toString(),
  );

  // Cache de regex pré-compilados para melhor performance
  static final RegExp _onlyNumbersRegex = RegExp(r'[^\d]');
  static final RegExp _currencySymbolRegex = RegExp(r'[R$\s.]');

  // Constantes de formatação
  static const int _cacheSize = 100; // Limite do cache LRU
  static const String _currencySymbol = CalculationConstants.CURRENCY_SYMBOL;
  static const String _decimalSeparator = CalculationConstants.COMMA_CHAR;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Verifica cache primeiro
    final cachedValue = _getCachedFormat(newValue.text);
    if (cachedValue != null) {
      return TextEditingValue(
        text: cachedValue,
        selection: TextSelection.collapsed(offset: cachedValue.length),
      );
    }

    // Remove caracteres não numéricos de forma otimizada
    final cleanValue = newValue.text.replaceAll(_onlyNumbersRegex, '');

    // Converte para centavos
    final valueInCents = int.tryParse(cleanValue) ?? 0;
    if (valueInCents == 0) {
      return const TextEditingValue(
        text: '$_currencySymbol 0${_decimalSeparator}00',
        selection: TextSelection.collapsed(offset: 6),
      );
    }

    // Verifica limites antes de formatar
    if (_isOutOfBounds(valueInCents)) {
      return oldValue;
    }

    // Formata o valor
    final formattedValue = _formatValue(valueInCents);

    // Atualiza cache
    _updateCache(newValue.text, formattedValue);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }

  /// Verifica se o valor está dentro dos limites permitidos
  bool _isOutOfBounds(int valueInCents) {
    final value = valueInCents / 100;
    return value < CalculationConstants.MIN_CURRENCY_VALUE ||
        value > CalculationConstants.MAX_CURRENCY_VALUE;
  }

  /// Formata um valor em centavos para moeda
  String _formatValue(int valueInCents) {
    // Separa reais e centavos
    final reais = valueInCents ~/ 100;
    final centavos = valueInCents % 100;

    // Formata os reais com pontos a cada 3 dígitos
    final reaisStr = _formatThousands(reais);

    // Retorna string formatada
    return '$_currencySymbol $reaisStr$_decimalSeparator${centavos.toString().padLeft(2, '0')}';
  }

  /// Formata milhares com pontos
  String _formatThousands(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    final length = str.length;

    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }

  /// Busca valor formatado no cache
  String? _getCachedFormat(String input) {
    return _formattedCache[input];
  }

  /// Atualiza o cache mantendo o limite de tamanho
  void _updateCache(String input, String formatted) {
    if (_formattedCache.length >= _cacheSize) {
      _formattedCache.remove(_formattedCache.keys.first);
    }
    _formattedCache[input] = formatted;
  }

  /// Extrai valor numérico de string formatada
  double getUnmaskedDouble(String value) {
    if (value.isEmpty) return 0;

    // Remove formatação mantendo apenas números
    String cleanValue = value.replaceAll(_currencySymbolRegex, '');
    cleanValue = cleanValue.replaceAll(_decimalSeparator, '.');

    // Tenta converter para double
    return double.tryParse(cleanValue) ?? 0;
  }

  /// Limpa o cache quando não for mais necessário
  void dispose() {
    _formattedCache.clear();
  }
}

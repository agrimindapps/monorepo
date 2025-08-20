// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import '../constants/error_messages.dart';
import '../utils/type_conversion_utils.dart';

/// Validador especializado para entrada numérica
class NumericInputValidator {
  /// Valida entrada numérica refinada
  static String? validateRefinedNumeric(
    String? value, {
    double? minValue,
    double? maxValue,
    int? maxDecimalPlaces,
    bool allowNegative = false,
    bool allowZero = true,
    List<double>? suggestedValues,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return null; // Validação de obrigatório é feita separadamente
    }

    final normalizedValue = TypeConversionUtils.normalizeNumericString(value);

    // Validação de formato numérico
    if (!TypeConversionUtils.isValidDouble(normalizedValue)) {
      return ErrorMessages.quantidadeInvalidNumber;
    }

    final numericValue =
        TypeConversionUtils.safeDoubleFromString(normalizedValue);

    // Validação de valor negativo
    if (!allowNegative && numericValue < 0) {
      return ErrorMessages.quantidadeNegative;
    }

    // Validação de zero
    if (!allowZero && numericValue == 0) {
      return ErrorMessages.quantidadeZero;
    }

    // Validação de valor mínimo
    if (minValue != null && numericValue < minValue) {
      return 'Valor deve ser maior ou igual a ${_formatNumber(minValue)}';
    }

    // Validação de valor máximo
    if (maxValue != null && numericValue > maxValue) {
      return ErrorMessages.substitute(
          ErrorMessages.quantidadeMaxValue, {'max': _formatNumber(maxValue)});
    }

    // Validação de casas decimais
    if (maxDecimalPlaces != null) {
      final decimalPlaces = _getDecimalPlaces(numericValue);
      if (decimalPlaces > maxDecimalPlaces) {
        return ErrorMessages.substitute(
            ErrorMessages.quantidadeMaxDecimal, {'max': maxDecimalPlaces});
      }
    }

    // Validação de valores extremos baseada em sugestões
    if (suggestedValues != null && suggestedValues.isNotEmpty) {
      final isExtremeValue = _isExtremeValue(numericValue, suggestedValues);
      if (isExtremeValue) {
        final suggestion =
            _findClosestSuggestion(numericValue, suggestedValues);
        return ErrorMessages.substitute(ErrorMessages.quantidadeAtypicalValue,
            {'suggestion': _formatNumber(suggestion)});
      }
    }

    return null;
  }

  /// Cria formatter para entrada numérica
  static TextInputFormatter createNumericFormatter({
    int? maxDecimalPlaces,
    double? maxValue,
    bool allowNegative = false,
  }) {
    return FilteringTextInputFormatter.allow(
      _buildNumericPattern(
        maxDecimalPlaces: maxDecimalPlaces,
        maxValue: maxValue,
        allowNegative: allowNegative,
      ),
    );
  }

  /// Cria formatter avançado com validação em tempo real
  static TextInputFormatter createAdvancedNumericFormatter({
    int? maxDecimalPlaces,
    double? maxValue,
    bool allowNegative = false,
    void Function(String)? onValueChange,
  }) {
    return _AdvancedNumericFormatter(
      maxDecimalPlaces: maxDecimalPlaces,
      maxValue: maxValue,
      allowNegative: allowNegative,
      onValueChange: onValueChange,
    );
  }

  /// Valida entrada de quantidade específica
  static String? validateQuantidadeInput(String? value) {
    return validateRefinedNumeric(
      value,
      minValue: 0.0,
      maxValue: 1000.0,
      maxDecimalPlaces: 2,
      allowZero: true,
      suggestedValues: [0.5, 1.0, 2.0, 5.0, 10.0, 15.0, 20.0, 25.0, 50.0],
      fieldName: 'quantidade',
    );
  }

  /// Valida entrada de coordenadas (latitude)
  static String? validateLatitudeInput(String? value) {
    return validateRefinedNumeric(
      value,
      minValue: -90.0,
      maxValue: 90.0,
      maxDecimalPlaces: 6,
      allowNegative: true,
      fieldName: 'latitude',
    );
  }

  /// Valida entrada de coordenadas (longitude)
  static String? validateLongitudeInput(String? value) {
    return validateRefinedNumeric(
      value,
      minValue: -180.0,
      maxValue: 180.0,
      maxDecimalPlaces: 6,
      allowNegative: true,
      fieldName: 'longitude',
    );
  }

  /// Formata número durante a digitação
  static String formatWhileTyping(String value, {int decimalPlaces = 2}) {
    if (value.isEmpty) return value;

    final normalizedValue = TypeConversionUtils.normalizeNumericString(value);

    if (!TypeConversionUtils.isValidDouble(normalizedValue)) {
      return value;
    }

    final numericValue =
        TypeConversionUtils.safeDoubleFromString(normalizedValue);

    // Limita casas decimais durante a digitação
    final formatted = numericValue.toStringAsFixed(decimalPlaces);

    // Remove zeros desnecessários
    return formatted
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Sugere valores baseado na entrada atual
  static List<double> suggestValues(
      String currentValue, List<double> possibleValues) {
    if (currentValue.isEmpty) return possibleValues.take(5).toList();

    final normalizedValue =
        TypeConversionUtils.normalizeNumericString(currentValue);

    if (!TypeConversionUtils.isValidDouble(normalizedValue)) {
      return possibleValues.take(5).toList();
    }

    final numericValue =
        TypeConversionUtils.safeDoubleFromString(normalizedValue);

    // Ordena valores por proximidade
    final sortedValues = List<double>.from(possibleValues);
    sortedValues.sort((a, b) {
      final diffA = (a - numericValue).abs();
      final diffB = (b - numericValue).abs();
      return diffA.compareTo(diffB);
    });

    return sortedValues.take(5).toList();
  }

  /// Valida contexto histórico
  static String? validateWithHistoricalContext(
    String? value,
    List<double> historicalValues,
  ) {
    if (value == null || value.trim().isEmpty) return null;

    final normalizedValue = TypeConversionUtils.normalizeNumericString(value);

    if (!TypeConversionUtils.isValidDouble(normalizedValue)) {
      return 'Digite um número válido';
    }

    final numericValue =
        TypeConversionUtils.safeDoubleFromString(normalizedValue);

    if (historicalValues.isEmpty) return null;

    // Calcula estatísticas
    final mean =
        historicalValues.reduce((a, b) => a + b) / historicalValues.length;
    final max = historicalValues.reduce((a, b) => a > b ? a : b);
    final min = historicalValues.reduce((a, b) => a < b ? a : b);

    // Valida contra contexto histórico
    if (numericValue > max * 2) {
      return 'Valor muito acima do máximo histórico (${_formatNumber(max)})';
    }

    if (numericValue > mean * 5) {
      return 'Valor muito acima da média histórica (${_formatNumber(mean)})';
    }

    if (numericValue < min && numericValue > 0) {
      return 'Valor abaixo do mínimo histórico (${_formatNumber(min)})';
    }

    return null;
  }

  // Métodos auxiliares privados

  static int _getDecimalPlaces(double value) {
    final str = value.toString();
    if (!str.contains('.')) return 0;
    return str.split('.')[1].length;
  }

  static String _formatNumber(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static bool _isExtremeValue(double value, List<double> suggestedValues) {
    if (suggestedValues.isEmpty) return false;

    final mean =
        suggestedValues.reduce((a, b) => a + b) / suggestedValues.length;
    final max = suggestedValues.reduce((a, b) => a > b ? a : b);

    return value > max * 1.5 || value > mean * 3;
  }

  static double _findClosestSuggestion(
      double value, List<double> suggestedValues) {
    double closest = suggestedValues.first;
    double minDiff = (value - closest).abs();

    for (final suggestion in suggestedValues) {
      final diff = (value - suggestion).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = suggestion;
      }
    }

    return closest;
  }

  static RegExp _buildNumericPattern({
    int? maxDecimalPlaces,
    double? maxValue,
    bool allowNegative = false,
  }) {
    final negativePattern = allowNegative ? r'-?' : '';
    final decimalPattern = maxDecimalPlaces != null
        ? r'(\.\d{0,' + maxDecimalPlaces.toString() + r'})?'
        : r'(\.\d*)?';

    return RegExp('^' + negativePattern + r'\d*' + decimalPattern + r'$');
  }
}

/// Formatter avançado para entrada numérica
class _AdvancedNumericFormatter extends TextInputFormatter {
  final int? maxDecimalPlaces;
  final double? maxValue;
  final bool allowNegative;
  final void Function(String)? onValueChange;

  _AdvancedNumericFormatter({
    this.maxDecimalPlaces,
    this.maxValue,
    this.allowNegative = false,
    this.onValueChange,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    // Permite string vazia
    if (newText.isEmpty) {
      onValueChange?.call(newText);
      return newValue;
    }

    // Valida padrão básico
    final pattern = NumericInputValidator._buildNumericPattern(
      maxDecimalPlaces: maxDecimalPlaces,
      maxValue: maxValue,
      allowNegative: allowNegative,
    );

    if (!pattern.hasMatch(newText)) {
      return oldValue;
    }

    // Valida valor máximo se especificado
    if (maxValue != null && TypeConversionUtils.isValidDouble(newText)) {
      final value = TypeConversionUtils.safeDoubleFromString(newText);
      if (value > maxValue!) {
        return oldValue;
      }
    }

    onValueChange?.call(newText);
    return newValue;
  }
}

/// Configurações de validação numérica
class NumericValidationConfig {
  final double? minValue;
  final double? maxValue;
  final int? maxDecimalPlaces;
  final bool allowNegative;
  final bool allowZero;
  final List<double>? suggestedValues;
  final List<double>? historicalValues;

  const NumericValidationConfig({
    this.minValue,
    this.maxValue,
    this.maxDecimalPlaces,
    this.allowNegative = false,
    this.allowZero = true,
    this.suggestedValues,
    this.historicalValues,
  });

  /// Configuração para quantidade
  static const quantidade = NumericValidationConfig(
    minValue: 0.0,
    maxValue: 1000.0,
    maxDecimalPlaces: 2,
    allowZero: true,
    suggestedValues: [0.5, 1.0, 2.0, 5.0, 10.0, 15.0, 20.0, 25.0, 50.0],
  );

  /// Configuração para latitude
  static const latitude = NumericValidationConfig(
    minValue: -90.0,
    maxValue: 90.0,
    maxDecimalPlaces: 6,
    allowNegative: true,
  );

  /// Configuração para longitude
  static const longitude = NumericValidationConfig(
    minValue: -180.0,
    maxValue: 180.0,
    maxDecimalPlaces: 6,
    allowNegative: true,
  );
}

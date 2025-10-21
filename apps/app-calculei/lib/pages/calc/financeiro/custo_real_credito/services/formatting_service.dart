/// Serviço responsável por formatação de números e valores monetários
///
/// Centraliza a lógica de formatação, parsing e conversão de valores
/// numericos, garantindo consistência e reutilização em toda a aplicação.
library;

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';

class FormattingService {
  static final FormattingService _instance = FormattingService._internal();
  factory FormattingService() => _instance;
  FormattingService._internal();

  /// Formatador de moeda brasileira (Singleton para otimização)
  late final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: CalculationConstants.BRAZILIAN_LOCALE,
    symbol: CalculationConstants.CURRENCY_SYMBOL,
    decimalDigits: CalculationConstants.CURRENCY_DECIMAL_DIGITS,
  );

  /// Formata um valor double para string monetária brasileira
  ///
  /// Exemplo: 1234.56 -> "R$ 1.234,56"
  String formatCurrency(double value) {
    return _currencyFormatter.format(value);
  }

  /// Converte uma string formatada para double
  ///
  /// Remove formatação monetária e converte para número.
  /// Exemplo: "R$ 1.234,56" -> 1234.56
  double parseUnmaskedDouble(String value) {
    if (value.isEmpty) return 0.0;

    // Remove símbolos de moeda e espaços
    String cleanValue = value.replaceAll(RegExp(r'[R$\s]'), '');

    // Substitui vírgula por ponto para parsing
    cleanValue = cleanValue.replaceAll(
        CalculationConstants.COMMA_CHAR, CalculationConstants.DOT_CHAR);

    // Converte para double com fallback seguro
    return double.tryParse(cleanValue) ?? 0.0;
  }

  /// Converte entrada numérica (em centavos) para valor real
  ///
  /// Usado na formatação de entrada do usuário.
  /// Exemplo: 123456 -> 1234.56
  double centavosToReal(String numericalInput) {
    if (numericalInput.isEmpty) return 0.0;

    double value = double.tryParse(numericalInput) ?? 0.0;
    return value / CalculationConstants.CENTS_TO_REAL_DIVISOR;
  }

  /// Formata um double para string com vírgula decimal brasileira
  ///
  /// Usado para campos de porcentagem.
  /// Exemplo: 0.7 -> "0,7"
  String formatPercentage(double value) {
    return value.toString().replaceAll(
        CalculationConstants.DOT_CHAR, CalculationConstants.COMMA_CHAR);
  }

  /// Converte string com vírgula para double
  ///
  /// Usado para parsing de campos de porcentagem.
  /// Exemplo: "0,7" -> 0.7
  double parsePercentage(String value) {
    if (value.isEmpty) return 0.0;

    String cleanValue = value.replaceAll(
        CalculationConstants.COMMA_CHAR, CalculationConstants.DOT_CHAR);

    return double.tryParse(cleanValue) ?? 0.0;
  }
}

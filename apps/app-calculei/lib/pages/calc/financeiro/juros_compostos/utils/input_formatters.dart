// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:intl/intl.dart';

/// Formatter para valores monetários brasileiros
class BrazilianCurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove todos os caracteres não numéricos
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Converte para double (divide por 100 para obter centavos)
    double value = double.parse(digitsOnly) / 100;

    // Formata como moeda
    String formatted = _currencyFormat.format(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter para percentuais com suporte a vírgula decimal
class PercentageInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Permite apenas números, vírgula e ponto
    if (!RegExp(r'^[\d,\.]*$').hasMatch(text)) {
      return oldValue;
    }

    // Substitui vírgula por ponto para uniformizar
    String normalizedText = text.replaceAll(',', '.');

    // Verifica se é um número válido
    if (normalizedText.isNotEmpty) {
      try {
        double value = double.parse(normalizedText);

        // Limita a 3 casas decimais e máximo 999%
        if (value > 999) {
          return oldValue;
        }

        // Limita casas decimais
        List<String> parts = normalizedText.split('.');
        if (parts.length > 1 && parts[1].length > 3) {
          normalizedText = '${parts[0]}.${parts[1].substring(0, 3)}';
        }
      } catch (e) {
        return oldValue;
      }
    }

    // Retorna com vírgula para exibição brasileira
    String displayText = normalizedText.replaceAll('.', ',');

    return TextEditingValue(
      text: displayText,
      selection: TextSelection.collapsed(offset: displayText.length),
    );
  }
}

/// Formatter para números inteiros com formatação de milhares
class IntegerWithThousandsFormatter extends TextInputFormatter {
  final NumberFormat _numberFormat = NumberFormat('#,###', 'pt_BR');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove todos os caracteres não numéricos
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Limita a 8 dígitos (99.999.999)
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }

    // Converte para int e formata
    int value = int.parse(digitsOnly);
    String formatted = _numberFormat.format(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Validador para valores monetários
class CurrencyValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    try {
      double parsed = _parseValue(value);
      if (parsed < 0) {
        return 'Valor não pode ser negativo';
      }
      if (parsed > 999999999) {
        return 'Valor muito alto (máx: R\$ 999.999.999)';
      }
      return null;
    } catch (e) {
      return 'Valor inválido';
    }
  }

  static double _parseValue(String value) {
    // Remove formatação e converte para double
    String cleanValue = value.replaceAll(RegExp(r'[^\d,]'), '');
    cleanValue = cleanValue.replaceAll(',', '.');
    return double.parse(cleanValue);
  }
}

/// Validador para percentuais
class PercentageValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    try {
      String normalizedValue = value.replaceAll(',', '.');
      double parsed = double.parse(normalizedValue);

      if (parsed < 0) {
        return 'Taxa não pode ser negativa';
      }
      if (parsed > 100) {
        return 'Taxa muito alta (máx: 100%)';
      }
      return null;
    } catch (e) {
      return 'Taxa inválida';
    }
  }
}

/// Validador para períodos
class PeriodValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    try {
      String cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
      int parsed = int.parse(cleanValue);

      if (parsed <= 0) {
        return 'Período deve ser maior que zero';
      }
      if (parsed > 1200) {
        return 'Período muito longo (máx: 1200 meses)';
      }
      return null;
    } catch (e) {
      return 'Período inválido';
    }
  }
}

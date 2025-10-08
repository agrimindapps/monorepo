import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'unified_validators.dart';

/// Retorna os formatadores apropriados para o tipo de validação
List<TextInputFormatter> getUnifiedFormatters(UnifiedValidationType type) {
  switch (type) {
    case UnifiedValidationType.currency:
      return [CurrencyInputFormatter()];
    case UnifiedValidationType.odometer:
      return [OdometerInputFormatter()];
    case UnifiedValidationType.licensePlate:
      return [LicensePlateInputFormatter()];
    case UnifiedValidationType.chassi:
      return [ChassiInputFormatter()];
    case UnifiedValidationType.renavam:
      return [RenavamInputFormatter()];
    case UnifiedValidationType.number:
      return [FilteringTextInputFormatter.digitsOnly];
    case UnifiedValidationType.decimal:
      return [DecimalInputFormatter()];
    default:
      return [];
  }
}

/// Sistema de formatadores unificado para campos de formulário
abstract class UnifiedFormatters {
  @Deprecated('Use getUnifiedFormatters() function instead')
  static List<TextInputFormatter> getFormatters(UnifiedValidationType type) {
    return getUnifiedFormatters(type);
  }
}

/// Formatador para valores monetários (R$ 0,00)
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    if (newText.isEmpty) return newValue;
    final digitsOnly = newText.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue();
    final number = double.tryParse(digitsOnly);
    if (number == null) return oldValue;
    final formatted = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(number / 100);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatador para odômetro com separadores de milhares
class OdometerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    if (newText.isEmpty) return newValue;
    final digitsOnly = newText.replaceAll(RegExp(r'[^\d,.]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue();
    final normalizedText = digitsOnly.replaceAll(',', '.');
    final number = double.tryParse(normalizedText);
    if (number == null) return oldValue;
    if (number > 999999.9) {
      return oldValue;
    }
    final formatter = NumberFormat('#,##0.0', 'pt_BR');
    String formatted = formatter.format(number);
    if (formatted.endsWith(',0')) {
      formatted = formatted.substring(0, formatted.length - 2);
    }

    formatted += ' km';
    final cursorPosition = formatted.length - 3;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

/// Formatador para placas de veículos (ABC-1234 ou ABC-1D23)
class LicensePlateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );

    if (newText.length > 7) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < newText.length; i++) {
      if (i == 3) {
        formatted += '-';
      }
      formatted += newText[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatador para chassi do veículo
class ChassiInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.toUpperCase();
    final filteredText = newText.replaceAll(RegExp(r'[^A-HJ-NPR-Z0-9]'), '');

    if (filteredText.length > 17) {
      return oldValue;
    }

    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: filteredText.length),
    );
  }
}

/// Formatador para RENAVAM
class RenavamInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length > 11) {
      return oldValue;
    }

    return TextEditingValue(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}

/// Formatador para números decimais com vírgula brasileira
class DecimalInputFormatter extends TextInputFormatter {
  DecimalInputFormatter({this.decimalPlaces = 2});
  final int decimalPlaces;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    final filteredText = newText.replaceAll(RegExp(r'[^\d,.]'), '');
    final normalizedText = filteredText.replaceAll('.', ',');
    final commaCount = ','.allMatches(normalizedText).length;
    if (commaCount > 1) {
      return oldValue;
    }
    if (normalizedText.contains(',')) {
      final parts = normalizedText.split(',');
      if (parts.length == 2 && parts[1].length > decimalPlaces) {
        return oldValue;
      }
    }

    return TextEditingValue(
      text: normalizedText,
      selection: TextSelection.collapsed(offset: normalizedText.length),
    );
  }
}

/// Formatador para telefone brasileiro
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length > 11) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 0) {
        formatted += '(';
      } else if (i == 2) {
        formatted += ') ';
      } else if ((digitsOnly.length == 11 && i == 7) ||
          (digitsOnly.length == 10 && i == 6)) {
        formatted += '-';
      }
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatador para CPF
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length > 11) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 3 || i == 6) {
        formatted += '.';
      } else if (i == 9) {
        formatted += '-';
      }
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatador para CEP
class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length > 8) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 5) {
        formatted += '-';
      }
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'unified_validators.dart';

/// Sistema de formatadores unificado para campos de formulário
abstract class UnifiedFormatters {
  static List<TextInputFormatter> getFormatters(UnifiedValidationType type) {
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
    
    // Remove todos os caracteres não numéricos
    final digitsOnly = newText.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue();
    
    // Converte para double (dividindo por 100 para centavos)
    final number = double.tryParse(digitsOnly);
    if (number == null) return oldValue;
    
    // Formata como moeda brasileira
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
    
    // Remove todos os caracteres não numéricos (exceto vírgula e ponto para decimais)
    final digitsOnly = newText.replaceAll(RegExp(r'[^\d,.]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue();
    
    // Converte vírgula para ponto para processamento
    final normalizedText = digitsOnly.replaceAll(',', '.');
    final number = double.tryParse(normalizedText);
    if (number == null) return oldValue;
    
    // Limita a 6 dígitos inteiros (999.999 km) e 1 decimal
    if (number > 999999.9) {
      return oldValue;
    }
    
    // Formata com separadores de milhares
    final formatter = NumberFormat('#,##0.0', 'pt_BR');
    String formatted = formatter.format(number);
    
    // Remove .0 desnecessário se for número inteiro
    if (formatted.endsWith(',0')) {
      formatted = formatted.substring(0, formatted.length - 2);
    }
    
    formatted += ' km';
    
    // Calcula a posição do cursor (antes da unidade ' km')
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
    final newText = newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    if (newText.length > 7) {
      return oldValue;
    }
    
    String formatted = '';
    
    // Formato: ABC-1234 ou ABC-1D23
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
    
    // Remove caracteres inválidos (I, O, Q não são permitidos no chassi)
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
  final int decimalPlaces;
  
  DecimalInputFormatter({this.decimalPlaces = 2});
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    // Permite apenas dígitos, vírgula e ponto
    final filteredText = newText.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Substitui ponto por vírgula para padrão brasileiro
    final normalizedText = filteredText.replaceAll('.', ',');
    
    // Verifica se há múltiplas vírgulas
    final commaCount = ','.allMatches(normalizedText).length;
    if (commaCount > 1) {
      return oldValue;
    }
    
    // Limita casas decimais
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
    
    // Formato: (11) 99999-9999
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
    
    // Formato: 999.999.999-99
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
    
    // Formato: 99999-999
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
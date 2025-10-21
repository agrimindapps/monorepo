// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:intl/intl.dart';

class FormattingService {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  
  static final NumberFormat _percentFormatter = NumberFormat.percentPattern('pt_BR');
  
  static final NumberFormat _hoursFormatter = NumberFormat('#,##0.0', 'pt_BR');
  
  String formatCurrency(double value) {
    return _currencyFormatter.format(value);
  }
  
  String formatPercent(double value) {
    return _percentFormatter.format(value);
  }
  
  String formatHours(double hours) {
    if (hours == 0) return '0h';
    
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();
    
    if (minutes == 0) {
      return '${wholeHours}h';
    }
    
    return '${wholeHours}h${minutes.toString().padLeft(2, '0')}';
  }
  
  String formatHoursDecimal(double hours) {
    return _hoursFormatter.format(hours);
  }
  
  double parseCurrency(String value) {
    // Remove all non-numeric characters except comma and dot
    String numericValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Handle Brazilian currency format: thousands separator (.) and decimal separator (,)
    // Convert from "1.234,56" to "1234.56" for parsing
    if (numericValue.contains(',')) {
      // Split by comma (decimal separator)
      final parts = numericValue.split(',');
      if (parts.length == 2) {
        // Remove dots from integer part (thousands separators)
        final integerPart = parts[0].replaceAll('.', '');
        final decimalPart = parts[1];
        numericValue = '$integerPart.$decimalPart';
      } else if (parts.length == 1) {
        // Only integer part, remove dots
        numericValue = parts[0].replaceAll('.', '');
      } else {
        return 0.0;
      }
    } else {
      // No comma, check if it's just a dot (could be decimal or thousands)
      final dotCount = numericValue.split('.').length - 1;
      if (dotCount > 1) {
        // Multiple dots, treat all but last as thousands separators
        final parts = numericValue.split('.');
        final lastPart = parts.removeLast();
        if (lastPart.length <= 2) {
          // Last part looks like decimal
          final integerPart = parts.join('');
          numericValue = '$integerPart.$lastPart';
        } else {
          // All dots are thousands separators
          numericValue = parts.join('') + lastPart;
        }
      }
      // Single dot or no dot - keep as is
    }
    
    return double.tryParse(numericValue) ?? 0.0;
  }
  
  double parseHours(String value) {
    // Remove all non-numeric characters except comma and dot
    String numericValue = value.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Handle Brazilian number format: thousands separator (.) and decimal separator (,)
    // Convert from "1.234,56" to "1234.56" for parsing
    if (numericValue.contains(',')) {
      // Split by comma (decimal separator)
      final parts = numericValue.split(',');
      if (parts.length == 2) {
        // Remove dots from integer part (thousands separators)
        final integerPart = parts[0].replaceAll('.', '');
        final decimalPart = parts[1];
        numericValue = '$integerPart.$decimalPart';
      } else if (parts.length == 1) {
        // Only integer part, remove dots
        numericValue = parts[0].replaceAll('.', '');
      } else {
        return 0.0;
      }
    } else {
      // No comma, check if it's just a dot (could be decimal or thousands)
      final dotCount = numericValue.split('.').length - 1;
      if (dotCount > 1) {
        // Multiple dots, treat all but last as thousands separators
        final parts = numericValue.split('.');
        final lastPart = parts.removeLast();
        if (lastPart.length <= 2) {
          // Last part looks like decimal
          final integerPart = parts.join('');
          numericValue = '$integerPart.$lastPart';
        } else {
          // All dots are thousands separators
          numericValue = parts.join('') + lastPart;
        }
      }
      // Single dot or no dot - keep as is
    }
    
    return double.tryParse(numericValue) ?? 0.0;
  }
  
  double parsePercent(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d,.]'), '');
    final normalized = cleaned.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }
  
  String formatJornada(int horasSemanais) {
    if (horasSemanais == 44) {
      return '$horasSemanais horas/semana (CLT padrão)';
    }
    
    if (horasSemanais == 40) {
      return '$horasSemanais horas/semana (reduzida)';
    }
    
    return '$horasSemanais horas/semana';
  }
  
  String formatDiasUteis(int dias) {
    if (dias == 1) {
      return '1 dia útil';
    }
    return '$dias dias úteis';
  }
  
  String formatAdicionalNoturno(double percentual) {
    if (percentual == 20) {
      return '${percentual.toStringAsFixed(0)}% (mínimo legal)';
    }
    return '${percentual.toStringAsFixed(0)}%';
  }
  
  String formatResumoHoras(double horas50, double horas100, double horasNoturnas, double horasDomingo) {
    final List<String> partes = [];
    
    if (horas50 > 0) {
      partes.add('${formatHoursDecimal(horas50)}h (50%)');
    }
    
    if (horas100 > 0) {
      partes.add('${formatHoursDecimal(horas100)}h (100%)');
    }
    
    if (horasNoturnas > 0) {
      partes.add('${formatHoursDecimal(horasNoturnas)}h (noturno)');
    }
    
    if (horasDomingo > 0) {
      partes.add('${formatHoursDecimal(horasDomingo)}h (domingo/feriado)');
    }
    
    if (partes.isEmpty) {
      return 'Nenhuma hora extra';
    }
    
    return partes.join(' + ');
  }
  
  TextInputFormatter get currencyFormatter => _CurrencyInputFormatter();
  TextInputFormatter get hoursFormatter => _HoursInputFormatter();
  TextInputFormatter get percentFormatter => _PercentInputFormatter();
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    
    final value = newValue.text;
    final numericValue = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numericValue.isEmpty) {
      return const TextEditingValue(text: '');
    }
    
    final intValue = int.parse(numericValue);
    final formatted = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 2,
    ).format(intValue / 100);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _HoursInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove caracteres não numéricos exceto vírgula e ponto
    final cleanedText = text.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Limita a 5 caracteres (ex: 999.5)
    if (cleanedText.length > 5) {
      return oldValue;
    }
    
    return TextEditingValue(
      text: cleanedText,
      selection: TextSelection.collapsed(offset: cleanedText.length),
    );
  }
}

class _PercentInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove caracteres não numéricos exceto vírgula e ponto
    final cleanedText = text.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Limita a 4 caracteres (ex: 99.5)
    if (cleanedText.length > 4) {
      return oldValue;
    }
    
    return TextEditingValue(
      text: cleanedText,
      selection: TextSelection.collapsed(offset: cleanedText.length),
    );
  }
}

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
  
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  
  String formatCurrency(double value) {
    return _currencyFormatter.format(value);
  }
  
  String formatPercent(double value) {
    return _percentFormatter.format(value);
  }
  
  String formatDate(DateTime date) {
    return _dateFormatter.format(date);
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
  
  DateTime? parseDate(String value) {
    try {
      return _dateFormatter.parse(value);
    } catch (e) {
      return null;
    }
  }
  
  String formatDias(int dias) {
    if (dias == 1) {
      return '1 dia';
    }
    return '$dias dias';
  }
  
  String formatMeses(int meses) {
    if (meses == 1) {
      return '1 mês';
    }
    return '$meses meses';
  }
  
  String formatFaltas(int faltas) {
    if (faltas == 0) {
      return 'Nenhuma falta';
    }
    if (faltas == 1) {
      return '1 falta';
    }
    return '$faltas faltas';
  }
  
  String formatPeriodo(DateTime inicio, DateTime fim) {
    final diferenca = fim.difference(inicio);
    final meses = (diferenca.inDays / 30).floor();
    final dias = diferenca.inDays % 30;
    
    if (meses == 0) {
      return formatDias(dias);
    }
    
    if (dias == 0) {
      return formatMeses(meses);
    }
    
    return '${formatMeses(meses)} e ${formatDias(dias)}';
  }
  
  String formatDireitoFerias(int diasDireito) {
    if (diasDireito == 0) {
      return 'Sem direito';
    }
    
    if (diasDireito == 30) {
      return 'Direito completo (30 dias)';
    }
    
    return 'Direito a ${formatDias(diasDireito)}';
  }
  
  TextInputFormatter get currencyFormatter => _CurrencyInputFormatter();
  TextInputFormatter get dateFormatter => _DateInputFormatter();
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

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final numericValue = text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numericValue.length > 8) {
      return oldValue;
    }
    
    String formatted = '';
    for (int i = 0; i < numericValue.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += numericValue[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';

class ValidationService {
  String? validateSalario(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o salário bruto';
    }
    
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
        return 'Valor inválido';
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
    
    final salario = double.tryParse(numericValue);
    if (salario == null) {
      return 'Valor inválido';
    }
    
    if (salario < CalculationConstants.minSalario) {
      return 'Salário deve ser maior que R\$ ${CalculationConstants.minSalario.toStringAsFixed(2)}';
    }
    
    if (salario > CalculationConstants.maxSalario) {
      return 'Salário deve ser menor que R\$ ${CalculationConstants.maxSalario.toStringAsFixed(2)}';
    }
    
    return null;
  }
  
  String? validateDependentes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Dependentes é opcional
    }
    
    final dependentes = int.tryParse(value);
    if (dependentes == null) {
      return 'Número inválido';
    }
    
    if (dependentes < 0) {
      return 'Número de dependentes não pode ser negativo';
    }
    
    if (dependentes > CalculationConstants.maxDependentes) {
      return 'Máximo ${CalculationConstants.maxDependentes} dependentes';
    }
    
    return null;
  }
  
  String? validateMoneyValue(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Campos monetários opcionais
    }
    
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
        return 'Valor inválido para $fieldName';
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
    
    final money = double.tryParse(numericValue);
    if (money == null) {
      return 'Valor inválido para $fieldName';
    }
    
    if (money < 0) {
      return '$fieldName não pode ser negativo';
    }
    
    if (money > 99999.99) {
      return '$fieldName muito alto';
    }
    
    return null;
  }
}

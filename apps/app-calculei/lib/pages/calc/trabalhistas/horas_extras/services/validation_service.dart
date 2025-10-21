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
  
  String? validateHorasSemanais(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe as horas semanais';
    }
    
    final horas = int.tryParse(value);
    if (horas == null) {
      return 'Número inválido';
    }
    
    if (horas < CalculationConstants.minHorasSemanais) {
      return 'Mínimo ${CalculationConstants.minHorasSemanais} hora semanal';
    }
    
    if (horas > CalculationConstants.maxHorasSemanais) {
      return 'Máximo ${CalculationConstants.maxHorasSemanais} horas semanais';
    }
    
    return null;
  }
  
  String? validateHorasExtras(String? value, String tipo) {
    if (value == null || value.isEmpty) {
      return null; // Horas extras são opcionais
    }
    
    final numericValue = value.replaceAll(',', '.');
    final horas = double.tryParse(numericValue);
    
    if (horas == null) {
      return 'Número inválido para $tipo';
    }
    
    if (horas < 0) {
      return '$tipo não pode ser negativo';
    }
    
    if (horas > CalculationConstants.maxHorasExtras) {
      return '$tipo muito alto (máx. ${CalculationConstants.maxHorasExtras})';
    }
    
    return null;
  }
  
  String? validatePercentualNoturno(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Percentual noturno é opcional se não há horas noturnas
    }
    
    final numericValue = value.replaceAll(',', '.');
    final percentual = double.tryParse(numericValue);
    
    if (percentual == null) {
      return 'Percentual inválido';
    }
    
    if (percentual < CalculationConstants.percentualAdicionalNoturnoMinimo * 100) {
      return 'Percentual mínimo é ${(CalculationConstants.percentualAdicionalNoturnoMinimo * 100).toStringAsFixed(0)}%';
    }
    
    if (percentual > CalculationConstants.maxPercentualNoturno) {
      return 'Percentual máximo é ${CalculationConstants.maxPercentualNoturno.toStringAsFixed(0)}%';
    }
    
    return null;
  }
  
  String? validateDiasUteis(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe os dias úteis do mês';
    }
    
    final dias = int.tryParse(value);
    if (dias == null) {
      return 'Número inválido';
    }
    
    if (dias < CalculationConstants.minDiasUteis) {
      return 'Mínimo ${CalculationConstants.minDiasUteis} dia útil';
    }
    
    if (dias > CalculationConstants.maxDiasUteis) {
      return 'Máximo ${CalculationConstants.maxDiasUteis} dias úteis';
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
  
  String? validateHorasNoturnasComPercentual(double horasNoturnas, double percentualNoturno) {
    if (horasNoturnas > 0 && percentualNoturno == 0) {
      return 'Informe o percentual do adicional noturno';
    }
    
    if (horasNoturnas == 0 && percentualNoturno > 0) {
      return 'Informe as horas noturnas para aplicar o percentual';
    }
    
    return null;
  }
  
  String getAlertaHorasExtras(double totalHoras) {
    if (totalHoras == 0) {
      return '';
    }
    
    if (totalHoras > 44) {
      return '⚠️ Total de horas extras muito alto - verifique limites legais';
    }
    
    if (totalHoras > 20) {
      return '⚠️ Quantidade elevada de horas extras';
    }
    
    return '✅ Quantidade normal de horas extras';
  }
  
  String getDicaJornada(int horasSemanais) {
    if (horasSemanais == 44) {
      return 'Jornada padrão CLT (44h semanais)';
    }
    
    if (horasSemanais == 40) {
      return 'Jornada reduzida (40h semanais)';
    }
    
    if (horasSemanais < 40) {
      return 'Jornada reduzida';
    }
    
    if (horasSemanais > 44) {
      return 'Jornada estendida - verifique acordo coletivo';
    }
    
    return '';
  }
}

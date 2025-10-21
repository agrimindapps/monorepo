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
  
  String? validateDiasFerias(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe os dias de férias';
    }
    
    final dias = int.tryParse(value);
    if (dias == null) {
      return 'Número inválido';
    }
    
    if (dias < CalculationConstants.diasMinimosFerias) {
      return 'Mínimo ${CalculationConstants.diasMinimosFerias} dias corridos';
    }
    
    if (dias > CalculationConstants.maxDiasFerias) {
      return 'Máximo ${CalculationConstants.maxDiasFerias} dias';
    }
    
    return null;
  }
  
  String? validateDataInicio(DateTime? data) {
    if (data == null) {
      return 'Informe o início do período aquisitivo';
    }
    
    final hoje = DateTime.now();
    
    if (data.isAfter(hoje)) {
      return 'Data de início não pode ser futura';
    }
    
    if (data.year < CalculationConstants.anoMinimoAquisitivo) {
      return 'Data de início muito antiga';
    }
    
    if (data.year > CalculationConstants.anoMaximoAquisitivo) {
      return 'Data de início inválida';
    }
    
    return null;
  }
  
  String? validateDataFim(DateTime? data) {
    if (data == null) {
      return 'Informe o fim do período aquisitivo';
    }
    
    final hoje = DateTime.now();
    
    if (data.isAfter(hoje)) {
      return 'Data de fim não pode ser futura';
    }
    
    if (data.year < CalculationConstants.anoMinimoAquisitivo) {
      return 'Data de fim muito antiga';
    }
    
    return null;
  }
  
  String? validateFaltas(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Faltas é opcional
    }
    
    final faltas = int.tryParse(value);
    if (faltas == null) {
      return 'Número inválido';
    }
    
    if (faltas < 0) {
      return 'Número de faltas não pode ser negativo';
    }
    
    if (faltas > CalculationConstants.maxFaltas) {
      return 'Número de faltas muito alto';
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
  
  String? validatePeriodoAquisitivo(DateTime? inicio, DateTime? fim) {
    if (inicio == null || fim == null) {
      return null; // Validação individual já foi feita
    }
    
    if (inicio.isAfter(fim)) {
      return 'Data de início deve ser anterior à data de fim';
    }
    
    final diferenca = fim.difference(inicio);
    if (diferenca.inDays < 30) {
      return 'Período aquisitivo deve ter pelo menos 30 dias';
    }
    
    if (diferenca.inDays > CalculationConstants.diasPeriodoAquisitivo + 30) {
      return 'Período aquisitivo não pode exceder 13 meses';
    }
    
    return null;
  }
  
  String? validateDiasFeriasComDireito(int diasFerias, int diasDireito, bool abonoPecuniario) {
    if (diasDireito == 0) {
      return 'Sem direito a férias devido ao excesso de faltas';
    }
    
    final diasVendidos = abonoPecuniario ? (diasDireito / 3).floor() : 0;
    final diasDisponiveis = diasDireito - diasVendidos;
    
    if (diasFerias > diasDisponiveis) {
      return 'Máximo $diasDisponiveis dias disponíveis para gozo';
    }
    
    if (diasFerias < CalculationConstants.diasMinimosFerias) {
      return 'Mínimo ${CalculationConstants.diasMinimosFerias} dias corridos';
    }
    
    return null;
  }
  
  String getDicaFaltas(int faltas) {
    for (final faixa in CalculationConstants.tabelaFaltas) {
      final faltasMin = faixa['faltasMin']!;
      final faltasMax = faixa['faltasMax']!;
      final diasDireito = faixa['diasDireito']!;
      
      if (faltas >= faltasMin && faltas <= faltasMax) {
        if (diasDireito == 0) {
          return 'Com $faltas faltas, perde o direito às férias';
        }
        return 'Com $faltas faltas, tem direito a $diasDireito dias';
      }
    }
    
    return '';
  }
}

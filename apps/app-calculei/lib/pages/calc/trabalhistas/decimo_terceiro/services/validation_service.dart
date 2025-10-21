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
  
  String? validateMeses(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe os meses trabalhados';
    }
    
    final meses = int.tryParse(value);
    if (meses == null) {
      return 'Número inválido';
    }
    
    if (meses < 1) {
      return 'Mínimo 1 mês trabalhado';
    }
    
    if (meses > CalculationConstants.maxMeses) {
      return 'Máximo ${CalculationConstants.maxMeses} meses';
    }
    
    return null;
  }
  
  String? validateDataAdmissao(DateTime? data) {
    if (data == null) {
      return 'Informe a data de admissão';
    }
    
    final hoje = DateTime.now();
    
    if (data.isAfter(hoje)) {
      return 'Data de admissão não pode ser futura';
    }
    
    if (data.year < CalculationConstants.anoMinimoAdmissao) {
      return 'Data de admissão muito antiga';
    }
    
    if (data.year > CalculationConstants.anoMaximoAdmissao) {
      return 'Data de admissão inválida';
    }
    
    return null;
  }
  
  String? validateDataCalculo(DateTime? data) {
    if (data == null) {
      return 'Informe a data do cálculo';
    }
    
    final hoje = DateTime.now();
    
    if (data.isAfter(hoje)) {
      return 'Data do cálculo não pode ser futura';
    }
    
    if (data.year < CalculationConstants.anoMinimoAdmissao) {
      return 'Data do cálculo muito antiga';
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
    
    if (dependentes > 99) {
      return 'Máximo 99 dependentes';
    }
    
    return null;
  }
  
  String? validatePeriodo(DateTime? dataAdmissao, DateTime? dataCalculo) {
    if (dataAdmissao == null || dataCalculo == null) {
      return null; // Validação individual já foi feita
    }
    
    if (dataAdmissao.isAfter(dataCalculo)) {
      return 'Data de admissão deve ser anterior à data do cálculo';
    }
    
    final diferenca = dataCalculo.difference(dataAdmissao);
    if (diferenca.inDays < 30) {
      return 'Período mínimo de 30 dias para cálculo do 13º';
    }
    
    return null;
  }
}

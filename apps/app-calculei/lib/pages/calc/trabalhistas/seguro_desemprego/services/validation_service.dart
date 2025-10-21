// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';

class ValidationService {
  String? validateSalarioMedio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o salário médio';
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
  
  String? validateTempoTrabalho(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o tempo de trabalho';
    }
    
    final tempo = int.tryParse(value);
    if (tempo == null) {
      return 'Número inválido';
    }
    
    if (tempo < CalculationConstants.minTempoTrabalho) {
      return 'Mínimo ${CalculationConstants.minTempoTrabalho} mês';
    }
    
    if (tempo > CalculationConstants.maxTempoTrabalho) {
      return 'Máximo ${CalculationConstants.maxTempoTrabalho} meses';
    }
    
    return null;
  }
  
  String? validateVezesRecebidas(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Vezes recebidas é opcional (padrão 0)
    }
    
    final vezes = int.tryParse(value);
    if (vezes == null) {
      return 'Número inválido';
    }
    
    if (vezes < 0) {
      return 'Número não pode ser negativo';
    }
    
    if (vezes > CalculationConstants.maxVezesRecebidas) {
      return 'Máximo ${CalculationConstants.maxVezesRecebidas} vezes';
    }
    
    return null;
  }
  
  String? validateDataDemissao(DateTime? data) {
    if (data == null) {
      return 'Informe a data de demissão';
    }
    
    final hoje = DateTime.now();
    
    if (data.isAfter(hoje)) {
      return 'Data de demissão não pode ser futura';
    }
    
    if (data.year < CalculationConstants.anoMinimoAdmissao) {
      return 'Data de demissão muito antiga';
    }
    
    final diasDesdeDemissao = hoje.difference(data).inDays;
    if (diasDesdeDemissao > CalculationConstants.prazoRequererDias) {
      return 'Prazo para requerer já expirou (${CalculationConstants.prazoRequererDias} dias)';
    }
    
    return null;
  }
  
  String getDicaCarencia(int tempoTrabalho, int vezesRecebidas) {
    int carenciaNecessaria;
    
    switch (vezesRecebidas) {
      case 0:
        carenciaNecessaria = CalculationConstants.carenciaPrimeiraVez;
        break;
      case 1:
        carenciaNecessaria = CalculationConstants.carenciaSegundaVez;
        break;
      default:
        carenciaNecessaria = CalculationConstants.carenciaTerceiraVez;
        break;
    }
    
    if (tempoTrabalho >= carenciaNecessaria) {
      return '✅ Tem direito ao seguro-desemprego';
    } else {
      final faltam = carenciaNecessaria - tempoTrabalho;
      return '❌ Faltam $faltam meses para ter direito';
    }
  }
  
  String getDicaVezesRecebidas(int vezesRecebidas) {
    switch (vezesRecebidas) {
      case 0:
        return 'Primeira vez - carência: 12 meses';
      case 1:
        return 'Segunda vez - carência: 9 meses';
      case 2:
        return 'Terceira vez - carência: 6 meses';
      default:
        return 'Múltiplas vezes - carência: 6 meses';
    }
  }
  
  String getDicaPrazo(DateTime dataDemissao) {
    final hoje = DateTime.now();
    final diasDesdeDemissao = hoje.difference(dataDemissao).inDays;
    final diasRestantes = CalculationConstants.prazoRequererDias - diasDesdeDemissao;
    
    if (diasRestantes <= 0) {
      return '⚠️ Prazo expirado para requerer';
    }
    
    if (diasRestantes <= 30) {
      return '⚠️ Prazo urgente: $diasRestantes dias restantes';
    }
    
    return '✅ Dentro do prazo: $diasRestantes dias restantes';
  }
  
  String getDicaSalario(double salarioMedio) {
    if (salarioMedio <= 1968.36) {
      return 'Faixa 1: 80% do salário médio';
    } else if (salarioMedio <= 3280.93) {
      return 'Faixa 2: 50% + valor fixo';
    } else {
      return 'Faixa 3: valor fixo máximo';
    }
  }
}

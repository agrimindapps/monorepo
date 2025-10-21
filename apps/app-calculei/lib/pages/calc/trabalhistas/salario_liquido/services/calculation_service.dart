// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/trabalhistas/salario_liquido/services/models/salario_liquido_model.dart';

class CalculationService {
  SalarioLiquidoModel calculate({
    required double salarioBruto,
    required int dependentes,
    required double valeTransporte,
    required double planoSaude,
    required double outrosDescontos,
  }) {
    // Calcula INSS
    final resultadoInss = _calcularInss(salarioBruto);
    final descontoInss = resultadoInss['desconto']!;
    final aliquotaInss = resultadoInss['aliquota']!;
    
    // Base de cálculo do IRRF (salário bruto - INSS)
    final baseCalculoIrrf = salarioBruto - descontoInss;
    
    // Calcula IRRF
    final resultadoIrrf = _calcularIrrf(baseCalculoIrrf, dependentes);
    final descontoIrrf = resultadoIrrf['desconto']!;
    final aliquotaIrrf = resultadoIrrf['aliquota']!;
    
    // Calcula desconto vale transporte
    final descontoValeTransporte = _calcularDescontoValeTransporte(
      salarioBruto, 
      valeTransporte,
    );
    
    // Total de descontos
    final totalDescontos = descontoInss + 
                          descontoIrrf + 
                          descontoValeTransporte + 
                          planoSaude + 
                          outrosDescontos;
    
    // Salário líquido
    final salarioLiquido = salarioBruto - totalDescontos;
    
    return SalarioLiquidoModel(
      salarioBruto: salarioBruto,
      dependentes: dependentes,
      valeTransporte: valeTransporte,
      planoSaude: planoSaude,
      outrosDescontos: outrosDescontos,
      descontoInss: descontoInss,
      descontoIrrf: descontoIrrf,
      descontoValeTransporte: descontoValeTransporte,
      totalDescontos: totalDescontos,
      salarioLiquido: salarioLiquido,
      aliquotaInss: aliquotaInss,
      aliquotaIrrf: aliquotaIrrf,
      baseCalculoIrrf: baseCalculoIrrf,
    );
  }
  
  Map<String, double> _calcularInss(double salarioBruto) {
    double desconto = 0.0;
    double aliquota = 0.0;
    
    for (final faixa in CalculationConstants.faixasInss) {
      final min = faixa['min']!;
      final max = faixa['max']!;
      final aliquotaFaixa = faixa['aliquota']!;
      
      if (salarioBruto > min) {
        final baseCalculo = salarioBruto > max ? max : salarioBruto;
        final valorFaixa = baseCalculo - min;
        desconto += valorFaixa * aliquotaFaixa;
        aliquota = aliquotaFaixa;
      }
    }
    
    // Limita ao teto do INSS
    if (desconto > CalculationConstants.tetoInss * 0.14) {
      desconto = CalculationConstants.tetoInss * 0.14;
    }
    
    return {'desconto': desconto, 'aliquota': aliquota};
  }
  
  Map<String, double> _calcularIrrf(double baseCalculo, int dependentes) {
    // Aplica dedução por dependentes
    final baseComDependentes = baseCalculo - 
                               (dependentes * CalculationConstants.deducaoDependenteIrrf);
    
    if (baseComDependentes <= 0) {
      return {'desconto': 0.0, 'aliquota': 0.0};
    }
    
    for (final faixa in CalculationConstants.faixasIrrf) {
      final min = faixa['min']!;
      final max = faixa['max']!;
      final aliquota = faixa['aliquota']!;
      final deducao = faixa['deducao']!;
      
      if (baseComDependentes >= min && baseComDependentes <= max) {
        final desconto = (baseComDependentes * aliquota) - deducao;
        return {
          'desconto': desconto > 0 ? desconto : 0.0,
          'aliquota': aliquota,
        };
      }
    }
    
    return {'desconto': 0.0, 'aliquota': 0.0};
  }
  
  double _calcularDescontoValeTransporte(double salarioBruto, double valeTransporte) {
    if (valeTransporte <= 0) return 0.0;
    
    final descontoMaximo = salarioBruto * CalculationConstants.percentualValeTransporte;
    return valeTransporte > descontoMaximo ? descontoMaximo : valeTransporte;
  }
}

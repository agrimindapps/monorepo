// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/trabalhistas/horas_extras/services/models/horas_extras_model.dart';

class CalculationService {
  HorasExtrasModel calculate({
    required double salarioBruto,
    required int horasSemanais,
    required double horas50,
    required double horas100,
    required double horasNoturnas,
    required double percentualNoturno,
    required double horasDomingoFeriado,
    required int dependentes,
    required int diasUteis,
  }) {
    // Calcula valor da hora normal
    final horasTrabalhadasMes = (horasSemanais * diasUteis) / CalculationConstants.diasTrabalhoSemana;
    final valorHoraNormal = salarioBruto / horasTrabalhadasMes;
    
    // Calcula valores das horas extras
    final valorHora50 = valorHoraNormal * (1 + CalculationConstants.percentualHorasExtras50);
    final valorHora100 = valorHoraNormal * (1 + CalculationConstants.percentualHorasExtras100);
    
    // Calcula valor da hora noturna (hora normal + adicional noturno)
    final valorHoraNoturna = valorHoraNormal * (1 + percentualNoturno / 100);
    
    // Calcula valor da hora domingo/feriado
    final valorHoraDomingoFeriado = valorHoraNormal * (1 + CalculationConstants.percentualDomingoFeriado);
    
    // Calcula totais
    final totalHoras50 = horas50 * valorHora50;
    final totalHoras100 = horas100 * valorHora100;
    final totalAdicionalNoturno = horasNoturnas * valorHoraNoturna;
    final totalDomingoFeriado = horasDomingoFeriado * valorHoraDomingoFeriado;
    
    // Calcula total de horas extras (sem adicional noturno e domingo/feriado)
    final horasExtrasMes = horas50 + horas100;
    final totalHorasExtras = totalHoras50 + totalHoras100;
    
    // Calcula DSR sobre horas extras (1/6 sobre horas extras)
    final dsrSobreExtras = totalHorasExtras * CalculationConstants.percentualDsr;
    
    // Calcula reflexos
    final reflexoFerias = totalHorasExtras * CalculationConstants.percentualReflexoFerias;
    final reflexoDecimoTerceiro = totalHorasExtras * CalculationConstants.percentualReflexoDecimoTerceiro;
    
    // Calcula total bruto (salário + todas as extras + reflexos)
    final totalBruto = salarioBruto + 
                       totalHorasExtras + 
                       totalAdicionalNoturno + 
                       totalDomingoFeriado + 
                       dsrSobreExtras + 
                       reflexoFerias + 
                       reflexoDecimoTerceiro;
    
    // Calcula INSS
    final resultadoInss = _calcularInss(totalBruto);
    final descontoInss = resultadoInss['desconto']!;
    final aliquotaInss = resultadoInss['aliquota']!;
    
    // Base de cálculo do IRRF (bruto - INSS)
    final baseCalculoIrrf = totalBruto - descontoInss;
    
    // Calcula IRRF
    final resultadoIrrf = _calcularIrrf(baseCalculoIrrf, dependentes);
    final descontoIrrf = resultadoIrrf['desconto']!;
    final aliquotaIrrf = resultadoIrrf['aliquota']!;
    
    // Calcula total líquido
    final totalLiquido = totalBruto - descontoInss - descontoIrrf;
    
    return HorasExtrasModel(
      salarioBruto: salarioBruto,
      horasSemanais: horasSemanais,
      horas50: horas50,
      horas100: horas100,
      horasNoturnas: horasNoturnas,
      percentualNoturno: percentualNoturno,
      horasDomingoFeriado: horasDomingoFeriado,
      dependentes: dependentes,
      diasUteis: diasUteis,
      valorHoraNormal: valorHoraNormal,
      valorHora50: valorHora50,
      valorHora100: valorHora100,
      valorHoraNoturna: valorHoraNoturna,
      valorHoraDomingoFeriado: valorHoraDomingoFeriado,
      totalHoras50: totalHoras50,
      totalHoras100: totalHoras100,
      totalAdicionalNoturno: totalAdicionalNoturno,
      totalDomingoFeriado: totalDomingoFeriado,
      dsrSobreExtras: dsrSobreExtras,
      totalHorasExtras: totalHorasExtras,
      reflexoFerias: reflexoFerias,
      reflexoDecimoTerceiro: reflexoDecimoTerceiro,
      totalBruto: totalBruto,
      descontoInss: descontoInss,
      descontoIrrf: descontoIrrf,
      totalLiquido: totalLiquido,
      aliquotaInss: aliquotaInss,
      aliquotaIrrf: aliquotaIrrf,
      horasTrabalhadasMes: horasTrabalhadasMes,
      horasExtrasMes: horasExtrasMes,
    );
  }
  
  Map<String, double> _calcularInss(double totalBruto) {
    double desconto = 0.0;
    double aliquota = 0.0;
    
    for (final faixa in CalculationConstants.faixasInss) {
      final min = faixa['min']!;
      final max = faixa['max']!;
      final aliquotaFaixa = faixa['aliquota']!;
      
      if (totalBruto > min) {
        final baseCalculo = totalBruto > max ? max : totalBruto;
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
  
  double calcularHorasTrabalhadasMes(int horasSemanais, int diasUteis) {
    return (horasSemanais * diasUteis) / CalculationConstants.diasTrabalhoSemana;
  }
  
  double calcularPercentualAumento(double totalBruto, double salarioBruto) {
    if (salarioBruto == 0) return 0.0;
    return ((totalBruto - salarioBruto) / salarioBruto) * 100;
  }
  
  String obterDicaHorasExtras(double totalHoras) {
    if (totalHoras == 0) {
      return 'Nenhuma hora extra cadastrada';
    }
    
    if (totalHoras <= 20) {
      return 'Quantidade normal de horas extras';
    }
    
    if (totalHoras <= 40) {
      return 'Quantidade elevada de horas extras';
    }
    
    return 'Quantidade muito alta de horas extras - verifique a legislação';
  }
}

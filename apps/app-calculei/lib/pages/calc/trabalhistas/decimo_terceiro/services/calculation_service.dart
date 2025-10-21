// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/trabalhistas/decimo_terceiro/services/models/decimo_terceiro_model.dart';

class CalculationService {
  DecimoTerceiroModel calculate({
    required double salarioBruto,
    required int mesesTrabalhados,
    required DateTime dataAdmissao,
    required DateTime dataCalculo,
    required int faltasNaoJustificadas,
    required bool antecipacao,
    int dependentes = 0,
  }) {
    // Calcula meses considerados (desconta faltas excessivas)
    final mesesConsiderados = _calcularMesesConsiderados(
      mesesTrabalhados, 
      faltasNaoJustificadas,
    );
    
    // Calcula valor por mês
    final valorPorMes = salarioBruto / CalculationConstants.mesesAno;
    
    // Calcula 13º bruto
    final decimoTerceiroBruto = valorPorMes * mesesConsiderados;
    
    // Calcula INSS
    final resultadoInss = _calcularInss(decimoTerceiroBruto);
    final descontoInss = resultadoInss['desconto']!;
    final aliquotaInss = resultadoInss['aliquota']!;
    
    // Base de cálculo do IRRF (13º bruto - INSS)
    final baseCalculoIrrf = decimoTerceiroBruto - descontoInss;
    
    // Calcula IRRF
    final resultadoIrrf = _calcularIrrf(baseCalculoIrrf, dependentes);
    final descontoIrrf = resultadoIrrf['desconto']!;
    final aliquotaIrrf = resultadoIrrf['aliquota']!;
    
    // Calcula 13º líquido
    final decimoTerceiroLiquido = decimoTerceiroBruto - descontoInss - descontoIrrf;
    
    // Calcula parcelas se for antecipação
    final primeiraParcela = antecipacao 
        ? decimoTerceiroBruto * CalculationConstants.percentualPrimeiraParcela
        : 0.0;
    
    final segundaParcela = antecipacao 
        ? decimoTerceiroLiquido - primeiraParcela
        : decimoTerceiroLiquido;
    
    return DecimoTerceiroModel(
      salarioBruto: salarioBruto,
      mesesTrabalhados: mesesTrabalhados,
      dataAdmissao: dataAdmissao,
      dataCalculo: dataCalculo,
      faltasNaoJustificadas: faltasNaoJustificadas,
      antecipacao: antecipacao,
      decimoTerceiroBruto: decimoTerceiroBruto,
      descontoInss: descontoInss,
      descontoIrrf: descontoIrrf,
      decimoTerceiroLiquido: decimoTerceiroLiquido,
      primeiraParcela: primeiraParcela,
      segundaParcela: segundaParcela,
      aliquotaInss: aliquotaInss,
      aliquotaIrrf: aliquotaIrrf,
      baseCalculoIrrf: baseCalculoIrrf,
      mesesConsiderados: mesesConsiderados,
      valorPorMes: valorPorMes,
    );
  }
  
  int _calcularMesesConsiderados(int mesesTrabalhados, int faltasNaoJustificadas) {
    // Cada 15 faltas não justificadas desconta 1 mês
    final mesesDesconto = faltasNaoJustificadas ~/ CalculationConstants.diasFaltaDesconto;
    final mesesConsiderados = mesesTrabalhados - mesesDesconto;
    
    return mesesConsiderados > 0 ? mesesConsiderados : 0;
  }
  
  Map<String, double> _calcularInss(double decimoTerceiroBruto) {
    double desconto = 0.0;
    double aliquota = 0.0;
    
    for (final faixa in CalculationConstants.faixasInss) {
      final min = faixa['min']!;
      final max = faixa['max']!;
      final aliquotaFaixa = faixa['aliquota']!;
      
      if (decimoTerceiroBruto > min) {
        final baseCalculo = decimoTerceiroBruto > max ? max : decimoTerceiroBruto;
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
  
  int calcularMesesTrabalhados(DateTime dataAdmissao, DateTime dataCalculo) {
    final diferenca = dataCalculo.difference(dataAdmissao);
    final meses = (diferenca.inDays / 30).floor();
    return meses > CalculationConstants.maxMeses 
        ? CalculationConstants.maxMeses 
        : meses;
  }
}

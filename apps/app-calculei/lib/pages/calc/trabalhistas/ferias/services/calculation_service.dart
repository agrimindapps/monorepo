// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/trabalhistas/ferias/services/models/ferias_model.dart';

class CalculationService {
  FeriasModel calculate({
    required double salarioBruto,
    required DateTime inicioAquisitivo,
    required DateTime fimAquisitivo,
    required int diasFerias,
    required int faltasNaoJustificadas,
    required bool abonoPecuniario,
    required int dependentes,
  }) {
    // Calcula meses do período aquisitivo
    final mesesAquisitivos = calcularMesesAquisitivos(inicioAquisitivo, fimAquisitivo);
    
    // Calcula dias de direito baseado nas faltas
    final diasDireito = calcularDiasDireito(faltasNaoJustificadas, mesesAquisitivos);
    
    // Calcula valor do dia
    final valorDia = salarioBruto / CalculationConstants.diasFeriasCompletas;
    
    // Calcula divisão dos dias
    final diasVendidos = abonoPecuniario ? (diasDireito / 3).floor() : 0;
    final diasGozados = diasFerias;
    
    // Valida se não está excedendo o direito
    final diasTotais = diasGozados + diasVendidos;
    if (diasTotais > diasDireito) {
      throw Exception('Dias solicitados excedem o direito de férias');
    }
    
    // Calcula férias proporcionais
    final feriasProporcionais = valorDia * diasGozados;
    
    // Calcula abono constitucional (1/3 sobre dias gozados)
    final abonoConstitucional = feriasProporcionais * CalculationConstants.percentualAbonoConstitucional;
    
    // Calcula abono pecuniário (venda de férias)
    final abonoPecuniarioValor = abonoPecuniario 
        ? (valorDia * diasVendidos) * (1 + CalculationConstants.percentualAbonoConstitucional)
        : 0.0;
    
    // Calcula férias bruto
    final feriasBruto = feriasProporcionais + abonoConstitucional + abonoPecuniarioValor;
    
    // Calcula INSS
    final resultadoInss = _calcularInss(feriasBruto);
    final descontoInss = resultadoInss['desconto']!;
    final aliquotaInss = resultadoInss['aliquota']!;
    
    // Base de cálculo do IRRF (férias bruto - INSS)
    final baseCalculoIrrf = feriasBruto - descontoInss;
    
    // Calcula IRRF
    final resultadoIrrf = _calcularIrrf(baseCalculoIrrf, dependentes);
    final descontoIrrf = resultadoIrrf['desconto']!;
    final aliquotaIrrf = resultadoIrrf['aliquota']!;
    
    // Calcula férias líquido
    final feriasLiquido = feriasBruto - descontoInss - descontoIrrf;
    
    return FeriasModel(
      salarioBruto: salarioBruto,
      inicioAquisitivo: inicioAquisitivo,
      fimAquisitivo: fimAquisitivo,
      diasFerias: diasFerias,
      faltasNaoJustificadas: faltasNaoJustificadas,
      abonoPecuniario: abonoPecuniario,
      dependentes: dependentes,
      feriasProporcionais: feriasProporcionais,
      abonoPecuniarioValor: abonoPecuniarioValor,
      abonoConstitucional: abonoConstitucional,
      feriasBruto: feriasBruto,
      descontoInss: descontoInss,
      descontoIrrf: descontoIrrf,
      feriasLiquido: feriasLiquido,
      aliquotaInss: aliquotaInss,
      aliquotaIrrf: aliquotaIrrf,
      baseCalculoIrrf: baseCalculoIrrf,
      diasDireito: diasDireito,
      diasVendidos: diasVendidos,
      diasGozados: diasGozados,
      mesesAquisitivos: mesesAquisitivos,
      valorDia: valorDia,
    );
  }
  
  int calcularMesesAquisitivos(DateTime inicio, DateTime fim) {
    final diferenca = fim.difference(inicio);
    final meses = (diferenca.inDays / CalculationConstants.diasMes).floor();
    return meses > CalculationConstants.mesesAno 
        ? CalculationConstants.mesesAno 
        : meses;
  }
  
  int calcularDiasDireito(int faltasNaoJustificadas, int mesesAquisitivos) {
    // Busca na tabela de faltas
    for (final faixa in CalculationConstants.tabelaFaltas) {
      final faltasMin = faixa['faltasMin']!;
      final faltasMax = faixa['faltasMax']!;
      
      if (faltasNaoJustificadas >= faltasMin && faltasNaoJustificadas <= faltasMax) {
        final diasBase = faixa['diasDireito']!;
        
        // Se não completou 12 meses, calcula proporcional
        if (mesesAquisitivos < CalculationConstants.mesesAno) {
          return ((diasBase * mesesAquisitivos) / CalculationConstants.mesesAno).floor();
        }
        
        return diasBase;
      }
    }
    
    return 0; // Sem direito
  }
  
  Map<String, double> _calcularInss(double feriasBruto) {
    double desconto = 0.0;
    double aliquota = 0.0;
    
    for (final faixa in CalculationConstants.faixasInss) {
      final min = faixa['min']!;
      final max = faixa['max']!;
      final aliquotaFaixa = faixa['aliquota']!;
      
      if (feriasBruto > min) {
        final baseCalculo = feriasBruto > max ? max : feriasBruto;
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
  
  int calcularDiasMaximosVenda(int diasDireito) {
    return (diasDireito * CalculationConstants.percentualMaximoAbonoPecuniario).floor();
  }
  
  bool validarDiasFerias(int diasFerias, int diasDireito, bool abonoPecuniario) {
    final diasVendidos = abonoPecuniario ? calcularDiasMaximosVenda(diasDireito) : 0;
    final diasDisponiveis = diasDireito - diasVendidos;
    
    return diasFerias <= diasDisponiveis && diasFerias >= CalculationConstants.diasMinimosFerias;
  }
}

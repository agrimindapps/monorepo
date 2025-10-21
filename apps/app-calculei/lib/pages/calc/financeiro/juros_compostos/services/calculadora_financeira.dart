// Dart imports:
import 'dart:math' as math;

/// Calculadora financeira genérica com diversos métodos de cálculo
class CalculadoraFinanceira {
  /// Calcula juros simples
  static double jurosSimples({
    required double capital,
    required double taxa,
    required int periodo,
  }) {
    return capital * taxa * periodo;
  }

  /// Calcula montante final com juros simples
  static double montanteJurosSimples({
    required double capital,
    required double taxa,
    required int periodo,
  }) {
    return capital +
        jurosSimples(capital: capital, taxa: taxa, periodo: periodo);
  }

  /// Calcula juros compostos básico (sem aportes)
  static double jurosCompostos({
    required double capital,
    required double taxa,
    required int periodo,
  }) {
    if (taxa == 0) return 0;
    return capital * math.pow(1 + taxa, periodo) - capital;
  }

  /// Calcula montante final com juros compostos básico
  static double montanteJurosCompostos({
    required double capital,
    required double taxa,
    required int periodo,
  }) {
    if (taxa == 0) return capital;
    return capital * math.pow(1 + taxa, periodo);
  }

  /// Calcula valor presente
  static double valorPresente({
    required double valorFuturo,
    required double taxa,
    required int periodo,
  }) {
    if (taxa == 0) return valorFuturo;
    return valorFuturo / math.pow(1 + taxa, periodo);
  }

  /// Calcula valor futuro de uma série de pagamentos (anuidades)
  static double valorFuturoAnuidade({
    required double pagamento,
    required double taxa,
    required int periodo,
  }) {
    if (taxa == 0) return pagamento * periodo;
    return pagamento * (math.pow(1 + taxa, periodo) - 1) / taxa;
  }

  /// Calcula valor presente de uma série de pagamentos (anuidades)
  static double valorPresenteAnuidade({
    required double pagamento,
    required double taxa,
    required int periodo,
  }) {
    if (taxa == 0) return pagamento * periodo;
    return pagamento * (1 - math.pow(1 + taxa, -periodo)) / taxa;
  }

  /// Calcula prestação de financiamento (sistema francês/price)
  static double calcularPrestacao({
    required double valorFinanciado,
    required double taxa,
    required int periodo,
  }) {
    if (taxa == 0) return valorFinanciado / periodo;
    return valorFinanciado *
        (taxa * math.pow(1 + taxa, periodo)) /
        (math.pow(1 + taxa, periodo) - 1);
  }

  /// Converte taxa anual para mensal
  static double taxaAnualParaMensal(double taxaAnual) {
    return math.pow(1 + taxaAnual, 1 / 12) - 1;
  }

  /// Converte taxa mensal para anual
  static double taxaMensalParaAnual(double taxaMensal) {
    return math.pow(1 + taxaMensal, 12) - 1;
  }

  /// Converte taxa nominal para efetiva
  static double taxaNominalParaEfetiva({
    required double taxaNominal,
    required int periodosCapitalizacao,
  }) {
    return math.pow(
            1 + taxaNominal / periodosCapitalizacao, periodosCapitalizacao) -
        1;
  }

  /// Calcula Taxa Interna de Retorno (TIR) simplificada
  static double calcularTIR({
    required double investimentoInicial,
    required List<double> fluxosCaixa,
  }) {
    // Implementação simplificada usando método iterativo
    double taxa = 0.1; // Chute inicial de 10%
    double precision = 0.0001;
    int maxIterations = 100;

    for (int i = 0; i < maxIterations; i++) {
      double vpl = calcularVPL(
        investimentoInicial: investimentoInicial,
        fluxosCaixa: fluxosCaixa,
        taxaDesconto: taxa,
      );

      if (vpl.abs() < precision) {
        return taxa;
      }

      // Ajuste da taxa baseado no sinal do VPL
      if (vpl > 0) {
        taxa += 0.01;
      } else {
        taxa -= 0.01;
      }

      // Prevenção de taxa negativa
      if (taxa < 0) taxa = 0.001;
    }

    return taxa;
  }

  /// Calcula Valor Presente Líquido (VPL)
  static double calcularVPL({
    required double investimentoInicial,
    required List<double> fluxosCaixa,
    required double taxaDesconto,
  }) {
    double vpl = -investimentoInicial;

    for (int i = 0; i < fluxosCaixa.length; i++) {
      vpl += fluxosCaixa[i] / math.pow(1 + taxaDesconto, i + 1);
    }

    return vpl;
  }

  /// Calcula payback simples
  static double calcularPaybackSimples({
    required double investimentoInicial,
    required List<double> fluxosCaixa,
  }) {
    double acumulado = 0;

    for (int i = 0; i < fluxosCaixa.length; i++) {
      acumulado += fluxosCaixa[i];
      if (acumulado >= investimentoInicial) {
        return i + 1 - (acumulado - investimentoInicial) / fluxosCaixa[i];
      }
    }

    return -1; // Não recupera o investimento
  }

  /// Calcula payback descontado
  static double calcularPaybackDescontado({
    required double investimentoInicial,
    required List<double> fluxosCaixa,
    required double taxaDesconto,
  }) {
    double acumulado = 0;

    for (int i = 0; i < fluxosCaixa.length; i++) {
      double fluxoDescontado =
          fluxosCaixa[i] / math.pow(1 + taxaDesconto, i + 1);
      acumulado += fluxoDescontado;

      if (acumulado >= investimentoInicial) {
        return i + 1 - (acumulado - investimentoInicial) / fluxoDescontado;
      }
    }

    return -1; // Não recupera o investimento
  }

  /// Calcula índice de rentabilidade
  static double calcularIndiceRentabilidade({
    required double investimentoInicial,
    required List<double> fluxosCaixa,
    required double taxaDesconto,
  }) {
    double valorPresenteFluxos = 0;

    for (int i = 0; i < fluxosCaixa.length; i++) {
      valorPresenteFluxos += fluxosCaixa[i] / math.pow(1 + taxaDesconto, i + 1);
    }

    return valorPresenteFluxos / investimentoInicial;
  }

  /// Converte diferentes períodos (dias, meses, anos)
  static double converterPeriodo({
    required double periodo,
    required String periodoOrigem,
    required String periodoDestino,
  }) {
    // Primeiro converte tudo para dias
    double dias = periodo;
    switch (periodoOrigem.toLowerCase()) {
      case 'meses':
        dias = periodo * 30;
        break;
      case 'anos':
        dias = periodo * 365;
        break;
    }

    // Depois converte para o período desejado
    switch (periodoDestino.toLowerCase()) {
      case 'meses':
        return dias / 30;
      case 'anos':
        return dias / 365;
      default:
        return dias;
    }
  }

  /// Calcula valor necessário para aposentadoria
  static double calcularAposentadoria({
    required double gastoMensalDesejado,
    required double taxaJuros,
    required int anosAposentadoria,
  }) {
    int meses = anosAposentadoria * 12;
    return valorPresenteAnuidade(
      pagamento: gastoMensalDesejado,
      taxa: taxaJuros,
      periodo: meses,
    );
  }

  /// Valida se um resultado matemático é válido
  static bool isResultadoValido(double resultado) {
    return !resultado.isInfinite && !resultado.isNaN && resultado >= 0;
  }
}

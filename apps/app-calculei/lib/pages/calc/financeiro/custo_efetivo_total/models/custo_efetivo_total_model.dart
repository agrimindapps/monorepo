// Dart imports:
import 'dart:math' as math;

class CustoEfetivoTotalModel {
  double valorEmprestimo = 0.0;
  int numeroParcelas = 12;
  double taxaJurosAnual = 0.15;
  double taxaAdministrativa = 0.0;
  double seguro = 0.0;
  double iof = 0.0038;
  double outrasTaxas = 0.0;

  double valorParcela = 0.0;
  double custoTotalEmprestimo = 0.0;
  double taxaJurosEfetivaMensal = 0.0;
  double taxaJurosEfetivaAnual = 0.0;
  double cetMensal = 0.0;
  double cetAnual = 0.0;
  double totalJuros = 0.0;
  double totalTaxasEncargos = 0.0;

  void calcular() {
    // Calcular taxa mensal nominal
    double taxaJurosMensal = math.pow(1 + taxaJurosAnual, 1 / 12) - 1;

    // Calcular valor da parcela (usando a fórmula do sistema Price/francês)
    valorParcela = valorEmprestimo *
        taxaJurosMensal *
        math.pow(1 + taxaJurosMensal, numeroParcelas) /
        (math.pow(1 + taxaJurosMensal, numeroParcelas) - 1);

    // Calcular custos adicionais
    double custoTaxaAdministrativa = valorEmprestimo * taxaAdministrativa;
    double custoIOF = valorEmprestimo * iof;
    totalTaxasEncargos =
        custoTaxaAdministrativa + seguro + custoIOF + outrasTaxas;

    // Calcular valor total pago
    custoTotalEmprestimo = valorParcela * numeroParcelas;
    totalJuros = custoTotalEmprestimo - valorEmprestimo;

    // Adicionar taxas ao fluxo de caixa para cálculo do CET
    double valorLiquido = valorEmprestimo - totalTaxasEncargos;

    // Calcular CET (usando a TIR - Taxa Interna de Retorno)
    cetMensal =
        _calcularTaxaInternaRetorno(valorLiquido, valorParcela, numeroParcelas);
    taxaJurosEfetivaMensal = taxaJurosMensal;

    // Calcular CET anual e taxa efetiva anual
    cetAnual = math.pow(1 + cetMensal, 12) - 1;
    taxaJurosEfetivaAnual = math.pow(1 + taxaJurosEfetivaMensal, 12) - 1;
  }

  double _calcularTaxaInternaRetorno(
      double valorInicial, double valorParcela, int numeroParcelas) {
    double taxaEstimada = 0.01; // Taxa inicial estimada (1%)

    for (int iteracao = 0; iteracao < 100; iteracao++) {
      double valorPresente = -valorInicial;
      double derivada = 0.0;

      for (int i = 1; i <= numeroParcelas; i++) {
        double fator = math.pow(1 + taxaEstimada, i).toDouble();
        valorPresente += valorParcela / fator;
        derivada -= i * valorParcela / (fator * (1 + taxaEstimada));
      }

      double novaTaxaEstimada = taxaEstimada - valorPresente / derivada;

      if ((novaTaxaEstimada - taxaEstimada).abs() < 0.000001) {
        return novaTaxaEstimada;
      }

      taxaEstimada = novaTaxaEstimada;
    }

    return taxaEstimada;
  }
}

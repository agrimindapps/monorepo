/// Serviço responsável pelos cálculos de custo real de crédito
///
/// Centraliza toda a lógica de cálculo financeiro, separando a responsabilidade
/// de cálculo da apresentação e controle de estado.
library;

// Dart imports:
import 'dart:math' as math;

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/custo_real_credito/services/models/custo_real_credito_model.dart';

class CalculationService {
  static final CalculationService _instance = CalculationService._internal();
  factory CalculationService() => _instance;
  CalculationService._internal();

  /// Executa o cálculo completo do custo real do crédito
  ///
  /// Recebe os parâmetros de entrada e retorna um modelo calculado
  /// com todos os valores derivados.
  CustoRealCreditoModel calculate({
    required double valorAVista,
    required double valorParcela,
    required int numeroParcelas,
    required double taxaInvestimento,
  }) {
    final model = CustoRealCreditoModel(
      valorAVista: valorAVista,
      valorParcela: valorParcela,
      numeroParcelas: numeroParcelas,
      taxaInvestimento: taxaInvestimento,
    );

    // Calcula o valor total pago no parcelamento
    model.valorTotalPago = _calculateTotalPaid(valorParcela, numeroParcelas);

    // Calcula o total de juros pagos
    model.totalJurosPagos =
        _calculateTotalInterest(model.valorTotalPago, valorAVista);

    // Calcula o ganho potencial do investimento
    model.ganhoInvestimento =
        _calculateInvestmentGain(valorAVista, taxaInvestimento, numeroParcelas);

    // Calcula o custo real efetivo
    model.custoRealEfetivo =
        _calculateRealCost(model.totalJurosPagos, model.ganhoInvestimento);

    return model;
  }

  /// Calcula o valor total pago no parcelamento
  double _calculateTotalPaid(double valorParcela, int numeroParcelas) {
    return valorParcela * numeroParcelas;
  }

  /// Calcula o total de juros pagos no parcelamento
  double _calculateTotalInterest(double valorTotalPago, double valorAVista) {
    return valorTotalPago - valorAVista;
  }

  /// Calcula o ganho potencial se o valor à vista fosse investido
  ///
  /// Simula rendimento mensal composto durante o período das parcelas
  double _calculateInvestmentGain(
      double valorAVista, double taxaMensal, int meses) {
    double valorInvestido = valorAVista;
    final taxaDecimal = taxaMensal / 100; // Converte porcentagem para decimal

    // Aplica juros compostos mensalmente
    for (int i = 0; i < meses; i++) {
      valorInvestido *= (1 + taxaDecimal);
    }

    // Retorna apenas o ganho (valor final - valor inicial)
    return valorInvestido - valorAVista;
  }

  /// Calcula o custo real efetivo da operação
  ///
  /// Soma os juros pagos com o ganho perdido do investimento
  double _calculateRealCost(double totalJurosPagos, double ganhoInvestimento) {
    return totalJurosPagos + ganhoInvestimento;
  }

  /// Verifica se é mais vantajoso pagar à vista ou parcelar
  ///
  /// Retorna true se for melhor pagar à vista
  bool isPaymentInCashBetter(CustoRealCreditoModel model) {
    return model.custoRealEfetivo > 0;
  }

  /// Calcula a economia potencial pagando à vista
  ///
  /// Retorna valor positivo se houver economia
  double calculatePotentialSavings(CustoRealCreditoModel model) {
    return model.custoRealEfetivo;
  }

  /// Calcula a taxa de juros efetiva mensal do parcelamento
  double calculateEffectiveMonthlyRate(
      double valorAVista, double valorParcela, int numeroParcelas) {
    if (valorAVista <= 0 || valorParcela <= 0 || numeroParcelas <= 0) {
      return 0.0;
    }
    final valorTotalPago = valorParcela * numeroParcelas;

    // Aproximação da taxa mensal efetiva
    // Fórmula simplificada: (ValorTotal/ValorAVista)^(1/meses) - 1
    final fatorTotal = valorTotalPago / valorAVista;
    final taxaMensal = (math.pow(fatorTotal, 1.0 / numeroParcelas) - 1) * 100;

    return taxaMensal.toDouble();
  }
}

// Importação desnecessária removida

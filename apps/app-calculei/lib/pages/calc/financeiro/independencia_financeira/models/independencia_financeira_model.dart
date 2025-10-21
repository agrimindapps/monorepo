// Package imports:
import 'package:fl_chart/fl_chart.dart';

class IndependenciaFinanceiraModel {
  final double patrimonioAtual;
  final double despesasMensais;
  final double aporteMensal;
  final double retornoAnual;
  final double taxaRetirada;

  double patrimonioAlvo = 0.0;
  double anosParaIndependencia = 0.0;
  double patrimonioNecessario = 0.0;
  double rendaMensalAtual = 0.0;
  List<FlSpot> pontosGrafico = [];

  IndependenciaFinanceiraModel({
    required this.patrimonioAtual,
    required this.despesasMensais,
    required this.aporteMensal,
    required this.retornoAnual,
    required this.taxaRetirada,
  });

  /// Modelo deve ser apenas um container de dados.
  /// Cálculos são realizados no CalculadoraFinanceiraService.

  // Helpers para acesso a dados formatados
  Map<String, double> getDadosResumo() {
    return {
      'patrimonioAtual': patrimonioAtual,
      'patrimonioNecessario': patrimonioNecessario,
      'rendaMensalAtual': rendaMensalAtual,
      'anosParaIndependencia': anosParaIndependencia,
    };
  }
}

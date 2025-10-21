// Dart imports:
import 'dart:math';

// Package imports:
import 'package:fl_chart/fl_chart.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/services/models/independencia_financeira_model.dart';

class CalculadoraFinanceiraService {
  double calcularTempoIndependencia({
    required double patrimonioAtual,
    required double despesasMensais,
    required double aporteMensal,
    required double retornoAnual,
    required double taxaRetirada,
  }) {
    final patrimonioNecessario = (despesasMensais * 12) / taxaRetirada;
    if (patrimonioAtual >= patrimonioNecessario) return 0;

    // Converte retorno anual para mensal usando juros compostos
    double retornoMensal = pow(1 + retornoAnual, 1 / 12) - 1;
    
    double patrimonioTotal = patrimonioAtual;
    int meses = 0;

    while (patrimonioTotal < patrimonioNecessario && meses < 1200) {
      patrimonioTotal = patrimonioTotal * (1 + retornoMensal) + aporteMensal;
      meses++;
    }

    return meses / 12;
  }

  double calcularPatrimonioNecessario({
    required double despesasMensais,
    required double taxaRetirada,
  }) {
    return (despesasMensais * 12) / taxaRetirada;
  }

  double calcularRendaMensalAtual({
    required double patrimonioAtual,
    required double taxaRetirada,
  }) {
    return (patrimonioAtual * taxaRetirada) / 12;
  }

  /// Calcula todos os dados da independência financeira e atualiza o modelo
  IndependenciaFinanceiraModel calcularCompleto({
    required double patrimonioAtual,
    required double despesasMensais,
    required double aporteMensal,
    required double retornoAnual,
    required double taxaRetirada,
  }) {
    final modelo = IndependenciaFinanceiraModel(
      patrimonioAtual: patrimonioAtual,
      despesasMensais: despesasMensais,
      aporteMensal: aporteMensal,
      retornoAnual: retornoAnual,
      taxaRetirada: taxaRetirada,
    );

    // Calcula patrimônio necessário
    final despesasAnuais = despesasMensais * 12;
    modelo.patrimonioAlvo = despesasAnuais / taxaRetirada;
    modelo.patrimonioNecessario = modelo.patrimonioAlvo;
    modelo.rendaMensalAtual = (patrimonioAtual * taxaRetirada) / 12;

    // Calcula tempo para independência e pontos do gráfico
    modelo.pontosGrafico = [];

    if (patrimonioAtual >= modelo.patrimonioAlvo) {
      modelo.anosParaIndependencia = 0;
      modelo.pontosGrafico = [
        FlSpot(0, patrimonioAtual),
        FlSpot(10, patrimonioAtual * pow(1 + retornoAnual, 10)),
      ];
    } else {
      double patrimonioProjetado = patrimonioAtual;
      double retornoMensal = pow(1 + retornoAnual, 1 / 12) - 1;

      modelo.pontosGrafico.add(FlSpot(0, patrimonioProjetado));

      int meses = 0;
      while (patrimonioProjetado < modelo.patrimonioAlvo && meses < 1200) {
        patrimonioProjetado = patrimonioProjetado * (1 + retornoMensal) + aporteMensal;
        meses++;

        if (meses % 12 == 0) {
          int ano = meses ~/ 12;
          modelo.pontosGrafico.add(FlSpot(ano.toDouble(), patrimonioProjetado));
        }
      }

      modelo.anosParaIndependencia = meses / 12;
    }

    return modelo;
  }
}

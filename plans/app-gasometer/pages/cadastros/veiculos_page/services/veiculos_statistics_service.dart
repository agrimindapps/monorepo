// Internal dependencies

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../models/veiculos_page_model.dart';

// Local imports

/// Service responsável pelos cálculos estatísticos de veículos
class VeiculosStatisticsService {
  // Calcula estatísticas por marca
  static Map<String, int> getEstatisticasPorMarca(VeiculosPageModel model) {
    return model.estatisticasPorMarca;
  }

  // Calcula estatísticas por ano
  static Map<int, int> getEstatisticasPorAno(VeiculosPageModel model) {
    return model.estatisticasPorAno;
  }

  // Calcula estatísticas por combustível
  static Map<int, int> getEstatisticasPorCombustivel(VeiculosPageModel model) {
    return model.estatisticasPorCombustivel;
  }

  // Calcula total de veículos
  static int getTotalVeiculos(List<VeiculoCar> veiculos) {
    return veiculos.length;
  }

  // Calcula odômetro médio
  static double getOdometroMedio(List<VeiculoCar> veiculos) {
    if (veiculos.isEmpty) return 0.0;

    final total = veiculos.fold<double>(
        0.0, (sum, veiculo) => sum + veiculo.odometroAtual);
    return total / veiculos.length;
  }

  // Calcula ano médio dos veículos
  static double getAnoMedio(List<VeiculoCar> veiculos) {
    if (veiculos.isEmpty) return 0.0;

    final total = veiculos.fold<int>(0, (sum, veiculo) => sum + veiculo.ano);
    return total / veiculos.length;
  }

  // Encontra veículo com maior odômetro
  static VeiculoCar? getVeiculoMaiorOdometro(List<VeiculoCar> veiculos) {
    if (veiculos.isEmpty) return null;

    return veiculos.reduce((atual, proximo) =>
        atual.odometroAtual > proximo.odometroAtual ? atual : proximo);
  }

  // Encontra veículo com menor odômetro
  static VeiculoCar? getVeiculoMenorOdometro(List<VeiculoCar> veiculos) {
    if (veiculos.isEmpty) return null;

    return veiculos.reduce((atual, proximo) =>
        atual.odometroAtual < proximo.odometroAtual ? atual : proximo);
  }

  // Calcula distribuição por marca
  static Map<String, double> getDistribuicaoPorMarca(
      List<VeiculoCar> veiculos) {
    if (veiculos.isEmpty) return {};

    final Map<String, int> contadores = {};

    for (final veiculo in veiculos) {
      contadores[veiculo.marca] = (contadores[veiculo.marca] ?? 0) + 1;
    }

    final total = veiculos.length;
    return contadores
        .map((marca, count) => MapEntry(marca, (count / total) * 100));
  }
}

// Internal dependencies

// Project imports:
import '../../../../database/21_veiculos_model.dart';

/// Service responsável pelos filtros e buscas de veículos
class VeiculosFilterService {
  // Busca veículos por termo
  static List<VeiculoCar> searchVeiculos(
      List<VeiculoCar> veiculos, String query) {
    if (query.isEmpty) return veiculos;

    return veiculos.where((veiculo) {
      final searchTerm = query.toLowerCase();
      return veiculo.marca.toLowerCase().contains(searchTerm) ||
          veiculo.modelo.toLowerCase().contains(searchTerm) ||
          veiculo.placa.toLowerCase().contains(searchTerm) ||
          veiculo.cor.toLowerCase().contains(searchTerm);
    }).toList();
  }

  // Filtra veículos por marca
  static List<VeiculoCar> filterByMarca(
      List<VeiculoCar> veiculos, String marca) {
    return veiculos
        .where((veiculo) =>
            veiculo.marca.toLowerCase().contains(marca.toLowerCase()))
        .toList();
  }

  // Filtra veículos por ano
  static List<VeiculoCar> filterByAno(List<VeiculoCar> veiculos, int ano) {
    return veiculos.where((veiculo) => veiculo.ano == ano).toList();
  }

  // Filtra veículos por faixa de anos
  static List<VeiculoCar> filterByAnoRange(
      List<VeiculoCar> veiculos, int anoInicio, int anoFim) {
    return veiculos
        .where((veiculo) => veiculo.ano >= anoInicio && veiculo.ano <= anoFim)
        .toList();
  }

  // Filtra veículos por combustível
  static List<VeiculoCar> filterByCombustivel(
      List<VeiculoCar> veiculos, int combustivel) {
    return veiculos
        .where((veiculo) => veiculo.combustivel == combustivel)
        .toList();
  }

  // Filtra veículos por cor
  static List<VeiculoCar> filterByCor(List<VeiculoCar> veiculos, String cor) {
    return veiculos
        .where(
            (veiculo) => veiculo.cor.toLowerCase().contains(cor.toLowerCase()))
        .toList();
  }

  // Filtra veículos por faixa de odômetro
  static List<VeiculoCar> filterByOdometroRange(
    List<VeiculoCar> veiculos,
    double odometroMin,
    double odometroMax,
  ) {
    return veiculos
        .where((veiculo) =>
            veiculo.odometroAtual >= odometroMin &&
            veiculo.odometroAtual <= odometroMax)
        .toList();
  }

  // Ordena veículos por marca
  static List<VeiculoCar> sortByMarca(List<VeiculoCar> veiculos,
      {bool ascending = true}) {
    final sorted = List<VeiculoCar>.from(veiculos);
    sorted.sort((a, b) =>
        ascending ? a.marca.compareTo(b.marca) : b.marca.compareTo(a.marca));
    return sorted;
  }

  // Ordena veículos por modelo
  static List<VeiculoCar> sortByModelo(List<VeiculoCar> veiculos,
      {bool ascending = true}) {
    final sorted = List<VeiculoCar>.from(veiculos);
    sorted.sort((a, b) => ascending
        ? a.modelo.compareTo(b.modelo)
        : b.modelo.compareTo(a.modelo));
    return sorted;
  }

  // Ordena veículos por ano
  static List<VeiculoCar> sortByAno(List<VeiculoCar> veiculos,
      {bool ascending = true}) {
    final sorted = List<VeiculoCar>.from(veiculos);
    sorted.sort(
        (a, b) => ascending ? a.ano.compareTo(b.ano) : b.ano.compareTo(a.ano));
    return sorted;
  }

  // Ordena veículos por odômetro atual
  static List<VeiculoCar> sortByOdometroAtual(List<VeiculoCar> veiculos,
      {bool ascending = true}) {
    final sorted = List<VeiculoCar>.from(veiculos);
    sorted.sort((a, b) => ascending
        ? a.odometroAtual.compareTo(b.odometroAtual)
        : b.odometroAtual.compareTo(a.odometroAtual));
    return sorted;
  }

  // Filtro combinado com múltiplos critérios
  static List<VeiculoCar> filterMultiple(
    List<VeiculoCar> veiculos, {
    String? searchQuery,
    String? marca,
    int? ano,
    int? anoInicio,
    int? anoFim,
    int? combustivel,
    String? cor,
    double? odometroMin,
    double? odometroMax,
  }) {
    List<VeiculoCar> result = veiculos;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      result = searchVeiculos(result, searchQuery);
    }

    if (marca != null && marca.isNotEmpty) {
      result = filterByMarca(result, marca);
    }

    if (ano != null) {
      result = filterByAno(result, ano);
    }

    if (anoInicio != null && anoFim != null) {
      result = filterByAnoRange(result, anoInicio, anoFim);
    }

    if (combustivel != null) {
      result = filterByCombustivel(result, combustivel);
    }

    if (cor != null && cor.isNotEmpty) {
      result = filterByCor(result, cor);
    }

    if (odometroMin != null && odometroMax != null) {
      result = filterByOdometroRange(result, odometroMin, odometroMax);
    }

    return result;
  }
}

// Flutter

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';

// External packages

// Internal dependencies

class VeiculosPageModel {
  final RxList<VeiculoCar> _veiculos = <VeiculoCar>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters for reactive state
  RxList<VeiculoCar> get veiculosRx => _veiculos;
  RxBool get isLoadingRx => _isLoading;
  RxBool get hasErrorRx => _hasError;
  RxString get errorMessageRx => _errorMessage;

  // Getters for current values
  List<VeiculoCar> get veiculos => _veiculos;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  bool get isEmpty => _veiculos.isEmpty;
  bool get isNotEmpty => _veiculos.isNotEmpty;
  int get length => _veiculos.length;

  // Setters
  void setVeiculos(List<VeiculoCar> veiculos) {
    debugPrint(
        'VeiculosPageModel: setVeiculos chamado com ${veiculos.length} veículos');
    _veiculos.assignAll(veiculos);
    debugPrint(
        'VeiculosPageModel: Após assignAll, _veiculos tem ${_veiculos.length} itens');
  }

  void addVeiculo(VeiculoCar veiculo) {
    _veiculos.add(veiculo);
  }

  void removeVeiculo(VeiculoCar veiculo) {
    _veiculos.remove(veiculo);
  }

  void removeVeiculoById(String id) {
    _veiculos.removeWhere((veiculo) => veiculo.id == id);
  }

  void updateVeiculo(VeiculoCar updatedVeiculo) {
    final index =
        _veiculos.indexWhere((veiculo) => veiculo.id == updatedVeiculo.id);
    if (index != -1) {
      _veiculos[index] = updatedVeiculo;
    }
  }

  void setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void setError(bool error, [String message = '']) {
    _hasError.value = error;
    _errorMessage.value = message;
  }

  void clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }

  // Utility methods
  VeiculoCar? getVeiculoById(String id) {
    try {
      return _veiculos.firstWhere((veiculo) => veiculo.id == id);
    } catch (e) {
      return null;
    }
  }

  bool hasVeiculoWithId(String id) {
    return _veiculos.any((veiculo) => veiculo.id == id);
  }

  void clear() {
    _veiculos.clear();
  }

  void reset() {
    _veiculos.clear();
    _isLoading.value = false;
    _hasError.value = false;
    _errorMessage.value = '';
  }

  // Filter and search methods
  List<VeiculoCar> getVeiculosByMarca(String marca) {
    return _veiculos
        .where((veiculo) =>
            veiculo.marca.toLowerCase().contains(marca.toLowerCase()))
        .toList();
  }

  List<VeiculoCar> getVeiculosByModelo(String modelo) {
    return _veiculos
        .where((veiculo) =>
            veiculo.modelo.toLowerCase().contains(modelo.toLowerCase()))
        .toList();
  }

  List<VeiculoCar> getVeiculosByAno(int ano) {
    return _veiculos.where((veiculo) => veiculo.ano == ano).toList();
  }

  List<VeiculoCar> getVeiculosByCombustivel(int combustivel) {
    return _veiculos
        .where((veiculo) => veiculo.combustivel == combustivel)
        .toList();
  }

  // Statistics
  int get totalVeiculos => _veiculos.length;

  Map<String, int> get estatisticasPorMarca {
    final Map<String, int> stats = {};
    for (final veiculo in _veiculos) {
      stats[veiculo.marca] = (stats[veiculo.marca] ?? 0) + 1;
    }
    return stats;
  }

  Map<int, int> get estatisticasPorAno {
    final Map<int, int> stats = {};
    for (final veiculo in _veiculos) {
      stats[veiculo.ano] = (stats[veiculo.ano] ?? 0) + 1;
    }
    return stats;
  }

  Map<int, int> get estatisticasPorCombustivel {
    final Map<int, int> stats = {};
    for (final veiculo in _veiculos) {
      stats[veiculo.combustivel] = (stats[veiculo.combustivel] ?? 0) + 1;
    }
    return stats;
  }

  // Convert to/from Map for persistence or serialization
  Map<String, dynamic> toMap() {
    return {
      'veiculos': _veiculos.map((v) => v.toMap()).toList(),
      'isLoading': _isLoading.value,
      'hasError': _hasError.value,
      'errorMessage': _errorMessage.value,
    };
  }

  void fromMap(Map<String, dynamic> map) {
    if (map['veiculos'] != null) {
      _veiculos.assignAll(
          (map['veiculos'] as List).map((v) => VeiculoCar.fromMap(v)).toList());
    }
    _isLoading.value = map['isLoading'] ?? false;
    _hasError.value = map['hasError'] ?? false;
    _errorMessage.value = map['errorMessage'] ?? '';
  }

  /// Dispose all observables to prevent memory leaks
  void dispose() {
    _veiculos.close();
    _isLoading.close();
    _hasError.close();
    _errorMessage.close();
  }
}

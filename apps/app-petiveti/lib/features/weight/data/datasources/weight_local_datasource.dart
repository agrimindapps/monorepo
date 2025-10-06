import '../models/weight_model.dart';

abstract class WeightLocalDataSource {
  /// Retorna todos os registros de peso não deletados
  Future<List<WeightModel>> getWeights();

  /// Retorna registros de peso de um animal específico
  Future<List<WeightModel>> getWeightsByAnimalId(String animalId);

  /// Retorna o último registro de peso de um animal
  Future<WeightModel?> getLatestWeightByAnimalId(String animalId);

  /// Retorna um registro de peso específico pelo ID
  Future<WeightModel?> getWeightById(String id);

  /// Adiciona/atualiza um registro de peso no cache local
  Future<void> cacheWeight(WeightModel weight);

  /// Adiciona/atualiza múltiplos registros de peso no cache local
  Future<void> cacheWeights(List<WeightModel> weights);

  /// Atualiza um registro de peso existente
  Future<void> updateWeight(WeightModel weight);

  /// Remove um registro de peso (soft delete)
  Future<void> deleteWeight(String id);

  /// Remove permanentemente um registro de peso
  Future<void> hardDeleteWeight(String id);

  Future<void> clearCache();

  /// Retorna stream de registros de peso para observar mudanças em tempo real
  Stream<List<WeightModel>> watchWeights();

  /// Retorna stream de registros de peso de um animal específico
  Stream<List<WeightModel>> watchWeightsByAnimalId(String animalId);

  /// Retorna registros de peso por período
  Future<List<WeightModel>> getWeightHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Conta total de registros de peso por animal
  Future<int> getWeightsCount(String animalId);

  /// Retorna estatísticas de peso (min, max, média)
  Future<Map<String, double>> getWeightStatistics(String animalId);
}

class WeightLocalDataSourceImpl implements WeightLocalDataSource {
  @override
  Future<List<WeightModel>> getWeights() async {
    return [];
  }

  @override
  Future<List<WeightModel>> getWeightsByAnimalId(String animalId) async {
    return [];
  }

  @override
  Future<WeightModel?> getLatestWeightByAnimalId(String animalId) async {
    return null;
  }

  @override
  Future<WeightModel?> getWeightById(String id) async {
    return null;
  }

  @override
  Future<void> cacheWeight(WeightModel weight) async {}

  @override
  Future<void> cacheWeights(List<WeightModel> weights) async {}

  @override
  Future<void> updateWeight(WeightModel weight) async {}

  @override
  Future<void> deleteWeight(String id) async {}

  @override
  Future<void> hardDeleteWeight(String id) async {}

  @override
  Future<void> clearCache() async {}

  @override
  Stream<List<WeightModel>> watchWeights() {
    return Stream.value([]);
  }

  @override
  Stream<List<WeightModel>> watchWeightsByAnimalId(String animalId) {
    return Stream.value([]);
  }

  @override
  Future<List<WeightModel>> getWeightHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return [];
  }

  @override
  Future<int> getWeightsCount(String animalId) async {
    return 0;
  }

  @override
  Future<Map<String, double>> getWeightStatistics(String animalId) async {
    return {'min': 0.0, 'max': 0.0, 'average': 0.0, 'current': 0.0};
  }
}

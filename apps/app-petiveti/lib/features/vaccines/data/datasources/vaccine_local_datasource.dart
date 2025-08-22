import '../models/vaccine_model.dart';

abstract class VaccineLocalDataSource {
  /// Retorna todas as vacinas não deletadas
  Future<List<VaccineModel>> getVaccines();

  /// Retorna vacinas de um animal específico
  Future<List<VaccineModel>> getVaccinesByAnimalId(String animalId);

  /// Retorna vacinas próximas do vencimento
  Future<List<VaccineModel>> getUpcomingVaccines();

  /// Retorna vacinas atrasadas
  Future<List<VaccineModel>> getOverdueVaccines();

  /// Retorna uma vacina específica pelo ID
  Future<VaccineModel?> getVaccineById(String id);

  /// Adiciona/atualiza uma vacina no cache local
  Future<void> cacheVaccine(VaccineModel vaccine);

  /// Adiciona/atualiza múltiplas vacinas no cache local
  Future<void> cacheVaccines(List<VaccineModel> vaccines);

  /// Atualiza uma vacina existente
  Future<void> updateVaccine(VaccineModel vaccine);

  /// Remove uma vacina (soft delete)
  Future<void> deleteVaccine(String id);

  /// Remove permanentemente uma vacina
  Future<void> hardDeleteVaccine(String id);

  /// Limpa todo o cache de vacinas
  Future<void> clearCache();

  /// Retorna stream de vacinas para observar mudanças em tempo real
  Stream<List<VaccineModel>> watchVaccines();

  /// Retorna stream de vacinas de um animal específico
  Stream<List<VaccineModel>> watchVaccinesByAnimalId(String animalId);

  /// Busca vacinas por nome
  Future<List<VaccineModel>> searchVaccines(String query);

  /// Retorna histórico de vacinas por período
  Future<List<VaccineModel>> getVaccineHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Conta total de vacinas por animal
  Future<int> getVaccinesCount(String animalId);
}

class VaccineLocalDataSourceImpl implements VaccineLocalDataSource {
  // TODO: Implementar com Hive quando os adapters estiverem disponíveis
  
  @override
  Future<List<VaccineModel>> getVaccines() async {
    // Placeholder implementation
    return [];
  }

  @override
  Future<List<VaccineModel>> getVaccinesByAnimalId(String animalId) async {
    // Placeholder implementation
    return [];
  }

  @override
  Future<List<VaccineModel>> getUpcomingVaccines() async {
    // Placeholder implementation
    return [];
  }

  @override
  Future<List<VaccineModel>> getOverdueVaccines() async {
    // Placeholder implementation
    return [];
  }

  @override
  Future<VaccineModel?> getVaccineById(String id) async {
    // Placeholder implementation
    return null;
  }

  @override
  Future<void> cacheVaccine(VaccineModel vaccine) async {
    // Placeholder implementation
  }

  @override
  Future<void> cacheVaccines(List<VaccineModel> vaccines) async {
    // Placeholder implementation
  }

  @override
  Future<void> updateVaccine(VaccineModel vaccine) async {
    // Placeholder implementation
  }

  @override
  Future<void> deleteVaccine(String id) async {
    // Placeholder implementation
  }

  @override
  Future<void> hardDeleteVaccine(String id) async {
    // Placeholder implementation
  }

  @override
  Future<void> clearCache() async {
    // Placeholder implementation
  }

  @override
  Stream<List<VaccineModel>> watchVaccines() {
    // Placeholder implementation
    return Stream.value([]);
  }

  @override
  Stream<List<VaccineModel>> watchVaccinesByAnimalId(String animalId) {
    // Placeholder implementation
    return Stream.value([]);
  }

  @override
  Future<List<VaccineModel>> searchVaccines(String query) async {
    // Placeholder implementation
    return [];
  }

  @override
  Future<List<VaccineModel>> getVaccineHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Placeholder implementation
    return [];
  }

  @override
  Future<int> getVaccinesCount(String animalId) async {
    // Placeholder implementation
    return 0;
  }
}
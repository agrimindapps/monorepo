abstract class IPlantasRepository {
  Future<void> initialize();
  Future<List<dynamic>> findByEspaco(String espacoId);
}

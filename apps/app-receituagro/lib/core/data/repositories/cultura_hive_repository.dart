import 'package:core/core.dart';
import '../models/cultura_hive.dart';

/// Repositório para CulturaHive
/// Implementa os métodos abstratos do BaseHiveRepository
class CulturaHiveRepository extends BaseHiveRepository<CulturaHive> {
  CulturaHiveRepository() : super(
    hiveManager: GetIt.instance<IHiveManager>(),
    boxName: 'receituagro_culturas',
  );


  /// Busca cultura por nome
  Future<CulturaHive?> findByName(String cultura) async {
    final result = await findBy((item) => item.cultura.toLowerCase() == cultura.toLowerCase());
    if (result.isError) return null;
    return result.data!.isNotEmpty ? result.data!.first : null;
  }

  /// Lista todas as culturas ativas
  Future<List<CulturaHive>> getActiveCulturas() async {
    final result = await getAll();
    if (result.isError) return [];
    return result.data!;
  }

  /// Busca por ID para manter compatibilidade com extensões
  Future<CulturaHive?> getById(String id) async {
    final result = await getByKey(id);
    return result.isSuccess ? result.data : null;
  }

  /// Carrega dados do JSON para o repositório
  Future<Result<void>> loadFromJson(List<Map<String, dynamic>> jsonData, String version) async {
    try {
      final Map<dynamic, CulturaHive> items = {};
      
      for (final json in jsonData) {
        final cultura = CulturaHive.fromJson(json);
        items[cultura.idReg] = cultura;
      }
      
      return await saveAll(items);
    } catch (e) {
      return Result.error(StorageError(
        message: 'Failed to load from JSON',
        code: 'LOAD_FROM_JSON_ERROR',
      ));
    }
  }
}

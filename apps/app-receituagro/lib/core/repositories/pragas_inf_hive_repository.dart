import 'package:core/core.dart';
import '../models/pragas_inf_hive.dart';

/// Repositório para PragasInfHive
/// Implementa os métodos abstratos do BaseHiveRepository
class PragasInfHiveRepository extends BaseHiveRepository<PragasInfHive> {
  PragasInfHiveRepository() : super(
    hiveManager: GetIt.instance<IHiveManager>(),
    boxName: 'receituagro_pragas_inf',
  );


  /// Busca informações complementares de uma praga
  Future<PragasInfHive?> findByIdReg(String idReg) async {
    final result = await getByKey(idReg);
    return result.isSuccess ? result.data : null;
  }

  /// Carrega dados do JSON para o repositório
  Future<Result<void>> loadFromJson(List<Map<String, dynamic>> jsonData, String version) async {
    try {
      final Map<dynamic, PragasInfHive> items = {};
      
      for (final json in jsonData) {
        final pragaInfo = PragasInfHive.fromJson(json);
        items[pragaInfo.idReg] = pragaInfo;
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
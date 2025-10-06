import 'package:core/core.dart';
import '../models/fitossanitario_info_hive.dart';

/// Repositório para FitossanitarioInfoHive
/// Implementa os métodos abstratos do BaseHiveRepository
class FitossanitarioInfoHiveRepository extends BaseHiveRepository<FitossanitarioInfoHive> {
  FitossanitarioInfoHiveRepository() : super(
    hiveManager: GetIt.instance<IHiveManager>(),
    boxName: 'receituagro_fitossanitarios_info',
  );


  /// Busca informações complementares de um fitossanitário
  Future<FitossanitarioInfoHive?> findByIdReg(String idReg) async {
    final result = await getByKey(idReg);
    return result.isSuccess ? result.data : null;
  }

  /// Carrega dados do JSON para o repositório
  Future<Result<void>> loadFromJson(List<Map<String, dynamic>> jsonData, String version) async {
    try {
      final Map<dynamic, FitossanitarioInfoHive> items = {};
      
      for (final json in jsonData) {
        final fitossanitarioInfo = FitossanitarioInfoHive.fromJson(json);
        items[fitossanitarioInfo.idReg] = fitossanitarioInfo;
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

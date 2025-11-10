import 'package:core/core.dart' hide Column;

import '../models/plantas_inf_hive.dart';

/// Repositório para PlantasInfHive
/// Implementa os métodos abstratos do BaseHiveRepository
class PlantasInfHiveRepository extends BaseHiveRepository<PlantasInfHive> {
  PlantasInfHiveRepository()
    : super(
        hiveManager: GetIt.instance<IHiveManager>(),
        boxName: 'receituagro_plantas_inf',
      );

  /// Busca informações de uma planta
  Future<PlantasInfHive?> findByIdReg(String idReg) async {
    final result = await getByKey(idReg);
    return result.isSuccess ? result.data : null;
  }

  /// Carrega dados do JSON para o repositório
  Future<Either<Failure, void>> loadFromJson(
    List<Map<String, dynamic>> jsonData,
    String version,
  ) async {
    try {
      final Map<dynamic, PlantasInfHive> items = {};

      for (final json in jsonData) {
        final plantaInfo = PlantasInfHive.fromJson(json);
        items[plantaInfo.idReg] = plantaInfo;
      }

      final result = await saveAll(items);
      if (result.isError) {
        return Left(CacheFailure(result.error!.message));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to load from JSON: $e'));
    }
  }
}

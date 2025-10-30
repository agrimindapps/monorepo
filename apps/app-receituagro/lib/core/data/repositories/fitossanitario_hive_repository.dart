import 'package:core/core.dart';

import '../models/fitossanitario_hive.dart';

/// Repositório para FitossanitarioHive
/// Implementa os métodos abstratos do BaseHiveRepository
class FitossanitarioHiveRepository extends BaseHiveRepository<FitossanitarioHive> {
  FitossanitarioHiveRepository() : super(
    hiveManager: GetIt.instance<IHiveManager>(),
    boxName: 'receituagro_fitossanitarios',
  );

  /// Busca defensivo por nome comum
  Future<FitossanitarioHive?> findByNomeComum(String nomeComum) async {
    final result = await findBy((item) => item.nomeComum.toLowerCase() == nomeComum.toLowerCase());
    return result.isSuccess && result.data!.isNotEmpty ? result.data!.first : null;
  }

  /// Lista defensivos por classe agronômica
  Future<List<FitossanitarioHive>> findByClasseAgronomica(String classeAgronomica) async {
    final result = await findBy((item) => 
        item.classeAgronomica?.toLowerCase() == classeAgronomica.toLowerCase());
    return result.isSuccess ? result.data! : [];
  }

  /// Lista defensivos por fabricante
  Future<List<FitossanitarioHive>> findByFabricante(String fabricante) async {
    final result = await findBy((item) => 
        item.fabricante?.toLowerCase() == fabricante.toLowerCase());
    return result.isSuccess ? result.data! : [];
  }

  /// Lista defensivos ativos/comercializados
  Future<List<FitossanitarioHive>> getActiveDefensivos() async {
    final result = await findBy((item) => item.status && item.comercializado == 1);
    return result.isSuccess ? result.data! : [];
  }

  /// Lista defensivos elegíveis
  Future<List<FitossanitarioHive>> getElegibleDefensivos() async {
    final result = await findBy((item) => item.elegivel);
    return result.isSuccess ? result.data! : [];
  }

  /// Busca por ID para manter compatibilidade com extensões
  Future<FitossanitarioHive?> getById(String id) async {
    final result = await getByKey(id);
    return result.isSuccess ? result.data : null;
  }

  /// Carrega dados do JSON para o repositório
  Future<Either<Failure, void>> loadFromJson(List<Map<String, dynamic>> jsonData, String version) async {
    try {
      final Map<dynamic, FitossanitarioHive> items = {};

      for (final json in jsonData) {
        final fitossanitario = FitossanitarioHive.fromJson(json);
        items[fitossanitario.idReg] = fitossanitario;
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

import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../models/pragas_hive.dart';

/// Repositório para PragasHive
/// Implementa os métodos abstratos do BaseHiveRepository
class PragasHiveRepository extends BaseHiveRepository<PragasHive> {
  PragasHiveRepository() : super(
    hiveManager: GetIt.instance<IHiveManager>(),
    boxName: 'receituagro_pragas',
  );


  /// Busca praga por nome comum
  Future<PragasHive?> findByNomeComum(String nomeComum) async {
    final result = await findBy((item) => item.nomeComum.toLowerCase() == nomeComum.toLowerCase());
    return result.isSuccess && result.data!.isNotEmpty ? result.data!.first : null;
  }

  /// Busca praga por nome científico
  Future<PragasHive?> findByNomeCientifico(String nomeCientifico) async {
    final result = await findBy((item) => item.nomeCientifico.toLowerCase() == nomeCientifico.toLowerCase());
    return result.isSuccess && result.data!.isNotEmpty ? result.data!.first : null;
  }

  /// Lista pragas por tipo
  Future<List<PragasHive>> findByTipo(String tipoPraga) async {
    final result = await findBy((item) => item.tipoPraga.toLowerCase() == tipoPraga.toLowerCase());
    return result.isSuccess ? result.data! : [];
  }

  /// Lista pragas por família
  Future<List<PragasHive>> findByFamilia(String familia) async {
    final result = await findBy((item) => item.familia?.toLowerCase() == familia.toLowerCase());
    return result.isSuccess ? result.data! : [];
  }

  /// Busca por ID para manter compatibilidade com extensões
  Future<PragasHive?> getById(String id) async {
    final result = await getByKey(id);
    return result.isSuccess ? result.data : null;
  }

  /// Carrega dados do JSON para o repositório
  Future<Either<Failure, void>> loadFromJson(List<Map<String, dynamic>> jsonData, String version) async {
    try {
      final Map<dynamic, PragasHive> items = {};

      for (final json in jsonData) {
        final praga = PragasHive.fromJson(json);
        items[praga.idReg] = praga;
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

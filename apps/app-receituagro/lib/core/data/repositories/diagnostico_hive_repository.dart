import 'package:core/core.dart';
import '../models/diagnostico_hive.dart';

/// Repositório para DiagnosticoHive
/// Implementa os métodos abstratos do BaseHiveRepository
class DiagnosticoHiveRepository extends BaseHiveRepository<DiagnosticoHive> {
  DiagnosticoHiveRepository() : super(
    hiveManager: GetIt.instance<IHiveManager>(),
    boxName: 'receituagro_diagnosticos',
  );

  /// Busca por objectId (ID do Firebase) se idReg não funcionar
  Future<DiagnosticoHive?> getByIdOrObjectId(String id) async {
    try {
      final result = await getByKey(id);
      if (result.isSuccess && result.data != null) {
        return result.data;
      }
      final matches = await findBy((item) => item.objectId == id);
      if (matches.isSuccess && matches.data!.isNotEmpty) {
        return matches.data!.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Busca diagnósticos por defensivo
  Future<List<DiagnosticoHive>> findByDefensivo(String fkIdDefensivo) async {
    final result = await findBy((item) => item.fkIdDefensivo == fkIdDefensivo);
    return result.isSuccess ? result.data! : [];
  }

  /// Busca diagnósticos por cultura
  Future<List<DiagnosticoHive>> findByCultura(String fkIdCultura) async {
    final result = await findBy((item) => item.fkIdCultura == fkIdCultura);
    return result.isSuccess ? result.data! : [];
  }

  /// Busca diagnósticos por praga
  Future<List<DiagnosticoHive>> findByPraga(String fkIdPraga) async {
    final result = await findBy((item) => item.fkIdPraga == fkIdPraga);
    return result.isSuccess ? result.data! : [];
  }

  /// Busca diagnósticos por cultura e defensivo
  Future<List<DiagnosticoHive>> findByCulturaAndDefensivo(String fkIdCultura, String fkIdDefensivo) async {
    final result = await findBy((item) => 
        item.fkIdCultura == fkIdCultura && item.fkIdDefensivo == fkIdDefensivo);
    return result.isSuccess ? result.data! : [];
  }

  /// Busca diagnósticos por múltiplos critérios
  Future<List<DiagnosticoHive>> findByMultipleCriteria({
    String? defensivoId,
    String? culturaId, 
    String? pragaId,
  }) async {
    final result = await findBy((item) {
      if (defensivoId != null && item.fkIdDefensivo != defensivoId) return false;
      if (culturaId != null && item.fkIdCultura != culturaId) return false;
      if (pragaId != null && item.fkIdPraga != pragaId) return false;
      return true;
    });
    return result.isSuccess ? result.data! : [];
  }

  /// Carrega dados do JSON para o repositório
  Future<Result<void>> loadFromJson(List<Map<String, dynamic>> jsonData, String version) async {
    try {
      final Map<dynamic, DiagnosticoHive> items = {};
      
      for (final json in jsonData) {
        final diagnostico = DiagnosticoHive.fromJson(json);
        items[diagnostico.idReg] = diagnostico;
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
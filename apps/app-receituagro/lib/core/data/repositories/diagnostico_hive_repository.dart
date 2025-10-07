import 'dart:developer' as developer;
import 'package:core/core.dart';
import '../models/diagnostico_hive.dart';

/// Repositório para DiagnosticoHive
/// Implementa os métodos abstratos do BaseHiveRepository
class DiagnosticoHiveRepository extends BaseHiveRepository<DiagnosticoHive> {
  DiagnosticoHiveRepository()
    : super(
        hiveManager: GetIt.instance<IHiveManager>(),
        boxName: 'receituagro_diagnosticos',
      );

  /// Busca por objectId (ID do Firebase) se idReg não funcionar
  Future<DiagnosticoHive?> getByIdOrObjectId(String id) async {
    try {
      // Try idReg first (stored as the key during import)
      final byIdReg = await getByKey(id);
      if (byIdReg.isSuccess && byIdReg.data != null) return byIdReg.data;

      // Fallback: search by objectId field
      final matches = await findBy((item) => item.objectId == id);
      if (matches.isSuccess && matches.data!.isNotEmpty)
        return matches.data!.first;

      // Final fallback: try searching by idReg equality (in case key types differ)
      final matches2 = await findBy((item) => item.idReg == id);
      if (matches2.isSuccess && matches2.data!.isNotEmpty)
        return matches2.data!.first;

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
  Future<List<DiagnosticoHive>> findByCulturaAndDefensivo(
    String fkIdCultura,
    String fkIdDefensivo,
  ) async {
    final result = await findBy(
      (item) =>
          item.fkIdCultura == fkIdCultura &&
          item.fkIdDefensivo == fkIdDefensivo,
    );
    return result.isSuccess ? result.data! : [];
  }

  /// Busca diagnósticos por múltiplos critérios
  Future<List<DiagnosticoHive>> findByMultipleCriteria({
    String? defensivoId,
    String? culturaId,
    String? pragaId,
  }) async {
    final result = await findBy((item) {
      if (defensivoId != null && item.fkIdDefensivo != defensivoId)
        return false;
      if (culturaId != null && item.fkIdCultura != culturaId) return false;
      if (pragaId != null && item.fkIdPraga != pragaId) return false;
      return true;
    });
    return result.isSuccess ? result.data! : [];
  }

  /// Carrega dados do JSON para o repositório
  Future<Result<void>> loadFromJson(
    List<Map<String, dynamic>> jsonData,
    String version,
  ) async {
    try {
      final Map<dynamic, DiagnosticoHive> items = {};

      for (final json in jsonData) {
        final diagnostico = DiagnosticoHive.fromJson(json);
        items[diagnostico.idReg] = diagnostico;
      }

      return await saveAll(items);
    } catch (e) {
      return Result.error(
        StorageError(
          message: 'Failed to load from JSON',
          code: 'LOAD_FROM_JSON_ERROR',
        ),
      );
    }
  }

  /// Salva um diagnóstico usando seu `idReg` como chave no box.
  /// Retorna um Result indicando sucesso ou falha.
  Future<Result<void>> saveWithIdReg(DiagnosticoHive item) async {
    try {
      final key = item.idReg;
      if (key.isEmpty) {
        return Result.error(
          StorageError(
            message: 'Cannot save Diagnostico: idReg is null or empty',
            code: 'MISSING_IDREG',
          ),
        );
      }

      // Use BaseHiveRepository.save with explicit key to guarantee consistent keying
      final result = await save(item, key: key);
      return result;
    } catch (e) {
      return Result.error(
        StorageError(
          message: 'Error saving Diagnostico: $e',
          code: 'SAVE_ERROR',
        ),
      );
    }
  }

  /// Salva um diagnóstico validando campos obrigatórios (fkIdDefensivo, fkIdCultura, fkIdPraga).
  /// Emite uma warning (developer.log) se algum campo faltar, mas ainda tenta salvar com idReg.
  Future<Result<void>> saveSafe(DiagnosticoHive item) async {
    try {
      final missing = <String>[];
      if (item.fkIdDefensivo.isEmpty) missing.add('fkIdDefensivo');
      if (item.fkIdCultura.isEmpty) missing.add('fkIdCultura');
      if (item.fkIdPraga.isEmpty) missing.add('fkIdPraga');

      if (missing.isNotEmpty) {
        developer.log(
          'Diagnostico.saveSafe: missing required fields: ${missing.join(', ')}',
          name: 'DiagnosticoHiveRepository',
        );
      }

      return await saveWithIdReg(item);
    } catch (e) {
      return Result.error(
        StorageError(message: 'Error in saveSafe: $e', code: 'SAVE_SAFE_ERROR'),
      );
    }
  }
}

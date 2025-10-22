import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
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
    developer.log(
      '🔍 findByDefensivo - Buscando diagnósticos para defensivo: $fkIdDefensivo',
      name: 'DiagnosticoRepository',
    );

    final result = await findBy((item) => item.fkIdDefensivo == fkIdDefensivo);

    if (result.isSuccess) {
      developer.log(
        '✅ findByDefensivo - Encontrados ${result.data!.length} diagnósticos',
        name: 'DiagnosticoRepository',
      );
      return result.data!;
    } else {
      developer.log(
        '❌ findByDefensivo - Erro: ${result.error?.message}',
        name: 'DiagnosticoRepository',
      );
      return [];
    }
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
    developer.log(
      '🔍 findByMultipleCriteria - Critérios: defensivo=$defensivoId, cultura=$culturaId, praga=$pragaId',
      name: 'DiagnosticoRepository',
    );

    // Primeiro, vamos ver quantos itens existem no total
    final allResult = await getAll();
    if (allResult.isSuccess) {
      developer.log(
        '📊 Total de diagnósticos na base: ${allResult.data!.length}',
        name: 'DiagnosticoRepository',
      );
    }

    final result = await findBy((item) {
      if (defensivoId != null && item.fkIdDefensivo != defensivoId) {
        return false;
      }
      if (culturaId != null && item.fkIdCultura != culturaId) {
        return false;
      }
      if (pragaId != null && item.fkIdPraga != pragaId) {
        return false;
      }
      return true;
    });

    if (result.isSuccess) {
      developer.log(
        '✅ findByMultipleCriteria - Encontrados ${result.data!.length} diagnósticos',
        name: 'DiagnosticoRepository',
      );

      // Log dos primeiros 3 resultados para debug
      if (result.data!.isNotEmpty) {
        final sample = result.data!.take(3);
        for (final diag in sample) {
          developer.log(
            '  → Diagnóstico: idReg=${diag.idReg}, defensivo=${diag.fkIdDefensivo}, cultura=${diag.fkIdCultura}, praga=${diag.fkIdPraga}',
            name: 'DiagnosticoRepository',
          );
        }
      }

      return result.data!;
    } else {
      developer.log(
        '❌ findByMultipleCriteria - Erro: ${result.error?.message}',
        name: 'DiagnosticoRepository',
      );
      return [];
    }
  }

  /// Carrega dados do JSON para o repositório
  Future<Either<Failure, void>> loadFromJson(
    List<Map<String, dynamic>> jsonData,
    String version,
  ) async {
    try {
      final Map<dynamic, DiagnosticoHive> items = {};

      for (final json in jsonData) {
        final diagnostico = DiagnosticoHive.fromJson(json);
        items[diagnostico.idReg] = diagnostico;
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

  /// Salva um diagnóstico usando seu `idReg` como chave no box.
  /// Retorna um Either indicando sucesso ou falha.
  Future<Either<Failure, void>> saveWithIdReg(DiagnosticoHive item) async {
    try {
      final key = item.idReg;
      if (key.isEmpty) {
        return Left(
          ValidationFailure('Cannot save Diagnostico: idReg is null or empty'),
        );
      }

      // Use BaseHiveRepository.save with explicit key to guarantee consistent keying
      final result = await save(item, key: key);
      if (result.isError) {
        return Left(CacheFailure(result.error!.message));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error saving Diagnostico: $e'));
    }
  }

  /// Salva um diagnóstico validando campos obrigatórios (fkIdDefensivo, fkIdCultura, fkIdPraga).
  /// Emite uma warning (developer.log) se algum campo faltar, mas ainda tenta salvar com idReg.
  Future<Either<Failure, void>> saveSafe(DiagnosticoHive item) async {
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
      return Left(CacheFailure('Error in saveSafe: $e'));
    }
  }
}

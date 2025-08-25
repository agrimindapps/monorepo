import 'package:core/core.dart';

import '../models/diagnostico_hive.dart';
import 'core_base_hive_repository.dart';

/// Repositório para DiagnosticoHive usando Core Package
/// Substitui DiagnosticoHiveRepository que usava Hive diretamente
class DiagnosticoCoreRepository extends CoreBaseHiveRepository<DiagnosticoHive> {
  DiagnosticoCoreRepository(ILocalStorageRepository storageService)
      : super(storageService, 'receituagro_diagnosticos');

  @override
  DiagnosticoHive createFromJson(Map<String, dynamic> json) {
    return DiagnosticoHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(DiagnosticoHive entity) {
    return entity.idReg;
  }

  /// Busca diagnósticos por defensivo de forma assíncrona
  Future<List<DiagnosticoHive>> findByDefensivo(String fkIdDefensivo) async {
    return findBy((item) => item.fkIdDefensivo == fkIdDefensivo);
  }

  /// Busca diagnósticos por cultura de forma assíncrona
  Future<List<DiagnosticoHive>> findByCultura(String fkIdCultura) async {
    return findBy((item) => item.fkIdCultura == fkIdCultura);
  }

  /// Busca diagnósticos por cultura e defensivo de forma assíncrona
  Future<List<DiagnosticoHive>> findByCulturaAndDefensivo(
      String fkIdCultura, String fkIdDefensivo) async {
    return findBy((item) => 
        item.fkIdCultura == fkIdCultura && item.fkIdDefensivo == fkIdDefensivo);
  }

  /// Busca diagnósticos por praga
  Future<List<DiagnosticoHive>> findByPraga(String fkIdPraga) async {
    return findBy((item) => item.fkIdPraga == fkIdPraga);
  }

  /// Busca diagnósticos complexa por múltiplos critérios
  Future<List<DiagnosticoHive>> findByMultipleCriteria({
    String? culturaId,
    String? defensivoId,
    String? pragaId,
    List<String>? culturaIds,
    List<String>? defensivoIds,
    List<String>? pragaIds,
  }) async {
    return findBy((diagnostico) {
      bool matches = true;

      // Critério único de cultura
      if (culturaId != null) {
        matches = matches && diagnostico.fkIdCultura == culturaId;
      }

      // Critério único de defensivo
      if (defensivoId != null) {
        matches = matches && diagnostico.fkIdDefensivo == defensivoId;
      }

      // Critério único de praga
      if (pragaId != null) {
        matches = matches && diagnostico.fkIdPraga == pragaId;
      }

      // Critérios múltiplos de culturas
      if (culturaIds != null && culturaIds.isNotEmpty) {
        matches = matches && culturaIds.contains(diagnostico.fkIdCultura);
      }

      // Critérios múltiplos de defensivos
      if (defensivoIds != null && defensivoIds.isNotEmpty) {
        matches = matches && defensivoIds.contains(diagnostico.fkIdDefensivo);
      }

      // Critérios múltiplos de pragas
      if (pragaIds != null && pragaIds.isNotEmpty) {
        matches = matches && pragaIds.contains(diagnostico.fkIdPraga);
      }

      return matches;
    });
  }

  /// Obter todos os defensivos relacionados a uma cultura
  Future<List<String>> getDefensivosByCultura(String culturaId) async {
    final diagnosticos = await findByCultura(culturaId);
    final defensivoIds = diagnosticos
        .map((d) => d.fkIdDefensivo)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    
    return defensivoIds;
  }

  /// Obter todas as culturas relacionadas a um defensivo
  Future<List<String>> getCulturasByDefensivo(String defensivoId) async {
    final diagnosticos = await findByDefensivo(defensivoId);
    final culturaIds = diagnosticos
        .map((d) => d.fkIdCultura)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    
    return culturaIds;
  }

  /// Obter todas as pragas relacionadas a uma cultura
  Future<List<String>> getPragasByCultura(String culturaId) async {
    final diagnosticos = await findByCultura(culturaId);
    final pragaIds = diagnosticos
        .map((d) => d.fkIdPraga)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    
    return pragaIds;
  }

  /// Verificar se existe relação entre cultura e defensivo
  Future<bool> existsRelation({
    String? culturaId,
    String? defensivoId,
    String? pragaId,
  }) async {
    final diagnosticos = await findByMultipleCriteria(
      culturaId: culturaId,
      defensivoId: defensivoId,
      pragaId: pragaId,
    );
    
    return diagnosticos.isNotEmpty;
  }

  /// Obter estatísticas de diagnósticos
  Future<Map<String, dynamic>> getDiagnosticoStats() async {
    final diagnosticos = getAll();
    
    // Contar relações únicas
    final culturaDefensivoRelations = <String>{};
    final culturaPragaRelations = <String>{};
    final defensivoPragaRelations = <String>{};
    
    for (final diagnostico in diagnosticos) {
      culturaDefensivoRelations.add('${diagnostico.fkIdCultura}_${diagnostico.fkIdDefensivo}');
      culturaPragaRelations.add('${diagnostico.fkIdCultura}_${diagnostico.fkIdPraga}');
      defensivoPragaRelations.add('${diagnostico.fkIdDefensivo}_${diagnostico.fkIdPraga}');
    }

    return {
      'totalDiagnosticos': diagnosticos.length,
      'uniqueCulturaDefensivoRelations': culturaDefensivoRelations.length,
      'uniqueCulturaPragaRelations': culturaPragaRelations.length,
      'uniqueDefensivoPragaRelations': defensivoPragaRelations.length,
      'uniqueCulturas': diagnosticos.map((d) => d.fkIdCultura).toSet().length,
      'uniqueDefensivos': diagnosticos.map((d) => d.fkIdDefensivo).toSet().length,
      'uniquePragas': diagnosticos.map((d) => d.fkIdPraga).toSet().length,
    };
  }

  /// Buscar diagnósticos paginados
  Future<List<DiagnosticoHive>> findPaginated({
    int page = 0,
    int limit = 50,
    String? culturaFilter,
    String? defensivoFilter,
    String? pragaFilter,
  }) async {
    List<DiagnosticoHive> diagnosticos;

    if (culturaFilter != null || defensivoFilter != null || pragaFilter != null) {
      diagnosticos = await findByMultipleCriteria(
        culturaId: culturaFilter,
        defensivoId: defensivoFilter,
        pragaId: pragaFilter,
      );
    } else {
      diagnosticos = getAll();
    }

    final startIndex = page * limit;
    final endIndex = startIndex + limit;

    if (startIndex >= diagnosticos.length) return [];

    return diagnosticos.sublist(
      startIndex,
      endIndex > diagnosticos.length ? diagnosticos.length : endIndex,
    );
  }

  /// Validar integridade dos dados de diagnóstico
  Future<List<Map<String, dynamic>>> validateDataIntegrity() async {
    final diagnosticos = getAll();
    final issues = <Map<String, dynamic>>[];

    for (final diagnostico in diagnosticos) {
      final problems = <String>[];

      // Verificar campos obrigatórios
      if (diagnostico.idReg.isEmpty) {
        problems.add('ID vazio');
      }
      if (diagnostico.fkIdCultura.isEmpty) {
        problems.add('Cultura ID vazia');
      }
      if (diagnostico.fkIdDefensivo.isEmpty) {
        problems.add('Defensivo ID vazio');
      }
      if (diagnostico.fkIdPraga.isEmpty) {
        problems.add('Praga ID vazia');
      }

      if (problems.isNotEmpty) {
        issues.add({
          'diagnosticoId': diagnostico.idReg,
          'problems': problems,
        });
      }
    }

    return issues;
  }
}
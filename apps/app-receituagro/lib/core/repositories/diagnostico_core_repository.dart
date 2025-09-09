import 'package:core/core.dart';

import '../models/diagnostico_hive.dart';
import 'core_base_hive_repository.dart';

/// Repositório para DiagnosticoHive usando Core Package
/// Substitui DiagnosticoHiveRepository que usava Hive diretamente
class DiagnosticoCoreRepository extends CoreBaseHiveRepository<DiagnosticoHive> {
  // Cache de consultas frequentes para otimização
  Map<String, List<DiagnosticoHive>>? _pragaCache;
  Map<String, List<DiagnosticoHive>>? _culturaCache;
  Map<String, List<DiagnosticoHive>>? _defensivoCache;
  DateTime? _cacheExpiry;
  static const Duration _cacheDuration = Duration(minutes: 15);

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

  /// Verifica se o cache está válido
  bool _isCacheValid() {
    return _cacheExpiry != null && DateTime.now().isBefore(_cacheExpiry!);
  }


  /// Inicializa o cache com dados otimizados
  Future<void> _initializeCache() async {
    if (_isCacheValid()) return;

    final diagnosticos = await getAllAsync();
    _pragaCache = <String, List<DiagnosticoHive>>{};
    _culturaCache = <String, List<DiagnosticoHive>>{};
    _defensivoCache = <String, List<DiagnosticoHive>>{};

    // Agrupa diagnósticos por índices para busca rápida
    for (final diagnostico in diagnosticos) {
      // Index por praga
      _pragaCache!.putIfAbsent(diagnostico.fkIdPraga, () => []).add(diagnostico);
      
      // Index por cultura
      _culturaCache!.putIfAbsent(diagnostico.fkIdCultura, () => []).add(diagnostico);
      
      // Index por defensivo
      _defensivoCache!.putIfAbsent(diagnostico.fkIdDefensivo, () => []).add(diagnostico);
    }

    _cacheExpiry = DateTime.now().add(_cacheDuration);
  }

  /// Limpa cache manualmente (útil após atualizações de dados)
  void clearCache() {
    _pragaCache = null;
    _culturaCache = null;
    _defensivoCache = null;
    _cacheExpiry = null;
  }

  /// Força rebuild do cache
  Future<void> rebuildCache() async {
    clearCache();
    await _initializeCache();
  }

  /// Busca diagnósticos por defensivo de forma assíncrona OTIMIZADA
  Future<List<DiagnosticoHive>> findByDefensivo(String fkIdDefensivo) async {
    await _initializeCache();
    return _defensivoCache?[fkIdDefensivo] ?? [];
  }

  /// Busca diagnósticos por cultura de forma assíncrona OTIMIZADA
  Future<List<DiagnosticoHive>> findByCultura(String fkIdCultura) async {
    await _initializeCache();
    return _culturaCache?[fkIdCultura] ?? [];
  }

  /// Busca diagnósticos por cultura e defensivo de forma assíncrona OTIMIZADA
  Future<List<DiagnosticoHive>> findByCulturaAndDefensivo(
      String fkIdCultura, String fkIdDefensivo) async {
    await _initializeCache();
    
    // Intersecção entre as duas listas usando cache
    final porCultura = _culturaCache?[fkIdCultura] ?? [];
    final porDefensivo = _defensivoCache?[fkIdDefensivo] ?? [];
    
    // Retorna interseção (diagnósticos que aparecem em ambas as listas)
    return porCultura.where((diagnostico) => 
      porDefensivo.any((d) => d.idReg == diagnostico.idReg)).toList();
  }

  /// Busca diagnósticos por praga OTIMIZADA
  Future<List<DiagnosticoHive>> findByPraga(String fkIdPraga) async {
    await _initializeCache();
    return _pragaCache?[fkIdPraga] ?? [];
  }

  /// Busca diagnósticos complexa por múltiplos critérios OTIMIZADA
  Future<List<DiagnosticoHive>> findByMultipleCriteria({
    String? culturaId,
    String? defensivoId,
    String? pragaId,
    List<String>? culturaIds,
    List<String>? defensivoIds,
    List<String>? pragaIds,
  }) async {
    await _initializeCache();
    
    List<DiagnosticoHive> results = [];
    
    // Otimização: começar com o critério mais restritivo
    if (pragaId != null) {
      results = _pragaCache?[pragaId] ?? [];
    } else if (defensivoId != null) {
      results = _defensivoCache?[defensivoId] ?? [];
    } else if (culturaId != null) {
      results = _culturaCache?[culturaId] ?? [];
    } else if (pragaIds != null && pragaIds.isNotEmpty) {
      results = [];
      for (final id in pragaIds) {
        results.addAll(_pragaCache?[id] ?? []);
      }
    } else if (defensivoIds != null && defensivoIds.isNotEmpty) {
      results = [];
      for (final id in defensivoIds) {
        results.addAll(_defensivoCache?[id] ?? []);
      }
    } else if (culturaIds != null && culturaIds.isNotEmpty) {
      results = [];
      for (final id in culturaIds) {
        results.addAll(_culturaCache?[id] ?? []);
      }
    } else {
      // Se não há critérios específicos, retorna todos
      return await getAllAsync();
    }

    // Aplica filtros adicionais nos resultados iniciais
    return results.where((diagnostico) {
      bool matches = true;

      if (culturaId != null) {
        matches = matches && diagnostico.fkIdCultura == culturaId;
      }
      if (defensivoId != null) {
        matches = matches && diagnostico.fkIdDefensivo == defensivoId;
      }
      if (pragaId != null) {
        matches = matches && diagnostico.fkIdPraga == pragaId;
      }
      if (culturaIds != null && culturaIds.isNotEmpty) {
        matches = matches && culturaIds.contains(diagnostico.fkIdCultura);
      }
      if (defensivoIds != null && defensivoIds.isNotEmpty) {
        matches = matches && defensivoIds.contains(diagnostico.fkIdDefensivo);
      }
      if (pragaIds != null && pragaIds.isNotEmpty) {
        matches = matches && pragaIds.contains(diagnostico.fkIdPraga);
      }

      return matches;
    }).toList();
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
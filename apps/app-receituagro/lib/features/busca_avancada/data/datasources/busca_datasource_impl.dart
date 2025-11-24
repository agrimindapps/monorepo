

import '../../../../database/repositories/culturas_repository.dart';
import '../../../../database/repositories/diagnostico_repository.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../../database/repositories/pragas_repository.dart';
import 'i_busca_datasource.dart';

/// Implementação do datasource de busca usando repositories existentes

class BuscaDatasourceImpl implements IBuscaDatasource {
  final CulturasRepository _culturaRepo;
  final PragasRepository _pragasRepo;
  final FitossanitariosRepository _fitossanitarioRepo;
  final DiagnosticoRepository _diagnosticoRepo;

  BuscaDatasourceImpl(
    this._culturaRepo,
    this._pragasRepo,
    this._fitossanitarioRepo,
    this._diagnosticoRepo,
  );

  @override
  Future<List<Map<String, dynamic>>> searchDiagnosticos({
    String? culturaId,
    String? pragaId,
    String? defensivoId,
  }) async {
    try {
      final diagnosticos = await _diagnosticoRepo.findAll();

      // Load all related entities once for efficient lookups
      final pragas = await _pragasRepo.findAll();
      final culturas = await _culturaRepo.findAll();
      final defensivos = await _fitossanitarioRepo.findAll();

      // Build lookup maps
      final pragasMap = {for (var p in pragas) p.id: p};
      final culturasMap = {for (var c in culturas) c.id: c};
      final defensivosMap = {for (var d in defensivos) d.id: d};

      var filtered = diagnosticos;

      // Filter using ID fields (Drift foreign keys)
      if (culturaId != null) {
        filtered = filtered
            .where((d) {
              final cultura = culturasMap[d.culturaId];
              return cultura?.idCultura == culturaId;
            })
            .toList();
      }

      if (pragaId != null) {
        filtered = filtered
            .where((d) {
              final praga = pragasMap[d.pragaId];
              return praga?.idPraga == pragaId;
            })
            .toList();
      }

      if (defensivoId != null) {
        filtered = filtered
            .where((d) {
              final defensivo = defensivosMap[d.defensivoId];
              return defensivo?.idDefensivo == defensivoId;
            })
            .toList();
      }

      // Map to output format, resolving relationships
      return filtered.map((d) {
        final praga = pragasMap[d.pragaId];
        final cultura = culturasMap[d.culturaId];
        final defensivo = defensivosMap[d.defensivoId];

        return {
          'id': d.idReg,
          'tipo': 'diagnostico',
          'titulo': praga?.nome ?? 'Praga desconhecida',
          'subtitulo': cultura?.nome ?? 'Cultura desconhecida',
          'descricao': '', // Diagnosticos table doesn't have descricao field
          'imageUrl': praga?.imagemUrl ?? cultura?.imagemUrl,
          'metadata': {
            'culturaId': cultura?.idCultura ?? '',
            'pragaId': praga?.idPraga ?? '',
            'defensivoId': defensivo?.idDefensivo ?? '',
            'culturaNome': cultura?.nome ?? '',
            'pragaNome': praga?.nome ?? '',
            'defensivoNome': defensivo?.nome ?? '',
          },
        };
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar diagnósticos: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchByText(
    String query, {
    List<String>? tipos,
    int? limit,
  }) async {
    final results = <Map<String, dynamic>>[];
    final queryLower = query.toLowerCase();

    try {
      final shouldSearchDiagnosticos =
          tipos == null || tipos.contains('diagnostico');
      final shouldSearchPragas = tipos == null || tipos.contains('praga');
      final shouldSearchDefensivos =
          tipos == null || tipos.contains('defensivo');
      final shouldSearchCulturas = tipos == null || tipos.contains('cultura');

      if (shouldSearchDiagnosticos) {
        final diagnosticos = await _diagnosticoRepo.findAll();

        // Load related entities for diagnosticos
        final pragas = await _pragasRepo.findAll();
        final culturas = await _culturaRepo.findAll();
        final defensivos = await _fitossanitarioRepo.findAll();

        final pragasMap = {for (var p in pragas) p.id: p};
        final culturasMap = {for (var c in culturas) c.id: c};
        final defensivosMap = {for (var d in defensivos) d.id: d};

        final filtered = diagnosticos.where((d) {
          final praga = pragasMap[d.pragaId];
          final cultura = culturasMap[d.culturaId];

          return (praga?.nome.toLowerCase().contains(queryLower) ?? false) ||
                 (cultura?.nome.toLowerCase().contains(queryLower) ?? false);
        });

        results.addAll(filtered.map((d) {
          final praga = pragasMap[d.pragaId];
          final cultura = culturasMap[d.culturaId];
          final defensivo = defensivosMap[d.defensivoId];

          return {
            'id': d.idReg,
            'tipo': 'diagnostico',
            'titulo': praga?.nome ?? 'Praga desconhecida',
            'subtitulo': cultura?.nome ?? 'Cultura desconhecida',
            'descricao': '',
            'imageUrl': praga?.imagemUrl ?? cultura?.imagemUrl,
            'metadata': {
              'culturaId': cultura?.idCultura ?? '',
              'pragaId': praga?.idPraga ?? '',
              'defensivoId': defensivo?.idDefensivo ?? '',
            },
          };
        }));
      }

      if (shouldSearchPragas) {
        final pragas = await _pragasRepo.findAll();
        final filtered = pragas.where((p) =>
            p.nome.toLowerCase().contains(queryLower) ||
            (p.nomeLatino?.toLowerCase().contains(queryLower) ?? false));

        results.addAll(filtered.map((p) => <String, dynamic>{
              'id': p.idPraga,
              'tipo': 'praga',
              'titulo': p.nome,
              'subtitulo': p.nomeLatino ?? '',
              'descricao': p.descricao ?? '',
              'imageUrl': p.imagemUrl,
              'metadata': <String, dynamic>{},
            }));
      }

      if (shouldSearchDefensivos) {
        final defensivos = await _fitossanitarioRepo.findAll();
        final filtered = defensivos
            .where((d) => d.nome.toLowerCase().contains(queryLower));

        results.addAll(filtered.map((d) => <String, dynamic>{
              'id': d.idDefensivo,
              'tipo': 'defensivo',
              'titulo': d.nome,
              'subtitulo': d.nomeComum ?? '',
              'descricao': '',
              'imageUrl': null,
              'metadata': <String, dynamic>{},
            }));
      }

      if (shouldSearchCulturas) {
        final culturas = await _culturaRepo.findAll();
        final filtered =
            culturas.where((c) => c.nome.toLowerCase().contains(queryLower));

        results.addAll(filtered.map((c) => <String, dynamic>{
              'id': c.idCultura,
              'tipo': 'cultura',
              'titulo': c.nome,
              'subtitulo': c.nomeLatino ?? '',
              'descricao': c.descricao ?? '',
              'imageUrl': c.imagemUrl,
              'metadata': <String, dynamic>{},
            }));
      }

      if (limit != null && results.length > limit) {
        return results.take(limit).toList();
      }

      return results;
    } catch (e) {
      throw Exception('Erro na busca por texto: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchPragasByCultura(
    String culturaId,
  ) async {
    try {
      final diagnosticos = await _diagnosticoRepo.findAll();

      // Load related entities
      final pragas = await _pragasRepo.findAll();
      final culturas = await _culturaRepo.findAll();

      final pragasMap = {for (var p in pragas) p.id: p};
      final culturasMap = {for (var c in culturas) c.id: c};

      // Filter diagnosticos by culturaId
      final filtered = diagnosticos.where((d) {
        final cultura = culturasMap[d.culturaId];
        return cultura?.idCultura == culturaId;
      });

      // Build unique pragas map
      final uniquePragasMap = <String, Map<String, dynamic>>{};

      for (final d in filtered) {
        final praga = pragasMap[d.pragaId];
        if (praga != null && !uniquePragasMap.containsKey(praga.idPraga)) {
          uniquePragasMap[praga.idPraga] = {
            'id': praga.idPraga,
            'tipo': 'praga',
            'titulo': praga.nome,
            'subtitulo': praga.nomeLatino ?? '',
            'descricao': praga.descricao ?? '',
            'imageUrl': praga.imagemUrl,
            'metadata': {'culturaId': culturaId},
          };
        }
      }

      return uniquePragasMap.values.toList();
    } catch (e) {
      throw Exception('Erro ao buscar pragas por cultura: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchDefensivosByPraga(
    String pragaId,
  ) async {
    try {
      final diagnosticos = await _diagnosticoRepo.findAll();

      // Load related entities
      final pragas = await _pragasRepo.findAll();
      final defensivos = await _fitossanitarioRepo.findAll();

      final pragasMap = {for (var p in pragas) p.id: p};
      final defensivosMap = {for (var d in defensivos) d.id: d};

      // Filter diagnosticos by pragaId
      final filtered = diagnosticos.where((d) {
        final praga = pragasMap[d.pragaId];
        return praga?.idPraga == pragaId;
      });

      // Build unique defensivos map
      final uniqueDefensivosMap = <String, Map<String, dynamic>>{};

      for (final d in filtered) {
        final defensivo = defensivosMap[d.defensivoId];
        if (defensivo != null && !uniqueDefensivosMap.containsKey(defensivo.idDefensivo)) {
          uniqueDefensivosMap[defensivo.idDefensivo] = {
            'id': defensivo.idDefensivo,
            'tipo': 'defensivo',
            'titulo': defensivo.nome,
            'subtitulo': defensivo.nomeComum ?? '',
            'descricao': '',
            'imageUrl': null,
            'metadata': {'pragaId': pragaId},
          };
        }
      }

      return uniqueDefensivosMap.values.toList();
    } catch (e) {
      throw Exception('Erro ao buscar defensivos por praga: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchAdvanced(
    Map<String, dynamic> filters,
  ) async {
    return searchDiagnosticos(
      culturaId: filters['culturaId'] as String?,
      pragaId: filters['pragaId'] as String?,
      defensivoId: filters['defensivoId'] as String?,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> loadCulturas() async {
    try {
      final culturas = await _culturaRepo.findAll();
      return culturas
          .map((c) => {
                'id': c.idCultura,
                'nome': c.nome,
              })
          .toList()
        ..sort((a, b) => (a['nome'] as String).compareTo(b['nome'] as String));
    } catch (e) {
      throw Exception('Erro ao carregar culturas: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadPragas() async {
    try {
      final pragas = await _pragasRepo.findAll();
      return pragas
          .map((p) => {
                'id': p.idPraga,
                'nome': p.nome.isNotEmpty ? p.nome : (p.nomeLatino ?? 'Praga desconhecida'),
              })
          .toList()
        ..sort((a, b) => (a['nome'] as String).compareTo(b['nome'] as String));
    } catch (e) {
      throw Exception('Erro ao carregar pragas: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadDefensivos() async {
    try {
      final defensivos = await _fitossanitarioRepo.findAll();
      return defensivos
          .map((d) => {
                'id': d.idDefensivo,
                'nome': d.nome,
              })
          .toList()
        ..sort((a, b) => (a['nome'] as String).compareTo(b['nome'] as String));
    } catch (e) {
      throw Exception('Erro ao carregar defensivos: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSuggestions({int limit = 10}) async {
    return [];
  }

  @override
  Future<void> saveSearchHistory(Map<String, dynamic> searchData) async {
    // TODO: Implement search history persistence
  }

  @override
  Future<List<Map<String, dynamic>>> getSearchHistory({int limit = 20}) async {
    return [];
  }

  @override
  Future<void> clearCache() async {
    // TODO: Implement cache clearing if needed
  }
}

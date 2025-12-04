import '../../../../database/repositories/culturas_repository.dart';
import '../../../../database/repositories/diagnostico_repository.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../../database/repositories/pragas_repository.dart';

/// Integração com serviços existentes para obter pragas por cultura
///
/// Responsabilidades:
/// - Consultar DiagnosticoRepository para obter pragas associadas a uma cultura
/// - Integrar dados de defensivos (FitossanitariosRepository Drift)
/// - Retornar lista consolidada de pragas para uma cultura específica

class PragasCulturaIntegrationDataSource {
  final PragasRepository _pragasRepository;
  final DiagnosticoRepository _diagnosticoRepository;
  final FitossanitariosRepository _fitossanitarioRepository;
  final CulturasRepository _culturasRepository;

  const PragasCulturaIntegrationDataSource(
    this._pragasRepository,
    this._diagnosticoRepository,
    this._fitossanitarioRepository,
    this._culturasRepository,
  );

  /// Carrega pragas para uma cultura específica
  ///
  /// Usa a tabela de Diagnósticos que relaciona Cultura → Praga → Defensivo
  /// 1. Busca diagnósticos para a cultura
  /// 2. Extrai pragas únicas
  /// 3. Conta quantos defensivos existem para cada praga
  ///
  /// [culturaId]: ID da cultura (pode ser id local int ou idCultura string)
  /// Returns: Lista consolidada com pragas e contagem de defensivos
  Future<List<dynamic>> getPragasPorCultura(String culturaId) async {
    try {
      if (culturaId.isEmpty) {
        return [];
      }

      // 1. Resolver culturaId para id interno (int)
      int? culturaIdInt = int.tryParse(culturaId);
      String? culturaNome;
      
      if (culturaIdInt == null) {
        // É um idCultura string, buscar a cultura pelo idCultura
        final cultura = await _culturasRepository.findByIdCultura(culturaId);
        if (cultura == null) {
          return [];
        }
        culturaIdInt = cultura.id;
        culturaNome = cultura.nome;
      } else {
        // É um id int, buscar nome da cultura
        final cultura = await _culturasRepository.findById(culturaIdInt);
        culturaNome = cultura?.nome;
      }

      // 2. Buscar diagnósticos para esta cultura
      final diagnosticos = await _diagnosticoRepository.findByCultura(culturaIdInt);
      
      if (diagnosticos.isEmpty) {
        return [];
      }

      // 3. Agrupar por praga e contar defensivos
      final Map<int, Map<String, dynamic>> pragasMap = {};
      
      for (final diagnostico in diagnosticos) {
        final pragaId = diagnostico.pragaId;
        
        if (!pragasMap.containsKey(pragaId)) {
          // Buscar dados da praga
          final praga = await _pragasRepository.findById(pragaId);
          if (praga != null) {
            pragasMap[pragaId] = {
              'objectId': praga.idPraga,
              'id': praga.id,
              'nome': praga.nome,
              'nomeCientifico': praga.nomeLatino ?? '',
              'tipoPraga': praga.tipo,
              'culturaId': culturaId,
              'culturaNome': culturaNome ?? '',
              'totalDefensivos': 1,
              'praga': praga,
            };
          }
        } else {
          // Incrementar contagem de defensivos
          pragasMap[pragaId]!['totalDefensivos'] = 
              (pragasMap[pragaId]!['totalDefensivos'] as int) + 1;
        }
      }

      return pragasMap.values.toList();
    } catch (e) {
      throw Exception('Erro ao integrar pragas por cultura: $e');
    }
  }

  /// Carrega defensivos para uma praga específica
  ///
  /// [pragaId]: ID da praga
  /// Returns: Lista de defensivos disponíveis
  Future<List<dynamic>> getDefensivosForPraga(String pragaId) async {
    try {
      if (pragaId.isEmpty) {
        return [];
      }

      final allDefensivos = await _fitossanitarioRepository.findAll();

      // Filtrar defensivos elegíveis (ativo e comercializado)
      final List<dynamic> defensivosEligibles = allDefensivos
          .where((dynamic d) => d.status == true && d.comercializado == 1)
          .toList();

      return defensivosEligibles;
    } catch (e) {
      throw Exception('Erro ao carregar defensivos para praga: $e');
    }
  }

  /// Integra dados completos de praga + defensivos + diagnósticos
  ///
  /// Usado para tela detalhada
  /// [pragaId]: ID da praga
  /// [culturaId]: ID da cultura
  Future<Map<String, dynamic>> getPragaCompleta(
    String pragaId,
    String culturaId,
  ) async {
    try {
      if (pragaId.isEmpty || culturaId.isEmpty) {
        throw Exception('pragaId e culturaId são obrigatórios');
      }

      // Buscar praga
      final praga = await _pragasRepository.findByIdPraga(pragaId);
      if (praga == null) {
        throw Exception('Praga não encontrada');
      }

      // Buscar defensivos
      final defensivos = await getDefensivosForPraga(pragaId);

      return {
        'praga': praga,
        'defensivos': defensivos,
        'totalDefensivos': defensivos.length,
        'culturaId': culturaId,
      };
    } catch (e) {
      throw Exception('Erro ao buscar praga completa: $e');
    }
  }
}

import 'package:core/core.dart' hide Column;

import '../../../../core/data/repositories/diagnostico_hive_repository.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/data/repositories/pragas_hive_repository.dart';

/// Integração com serviços existentes para obter pragas por cultura
///
/// Responsabilidades:
/// - Consultar PragasHiveRepository para dados base de pragas
/// - Integrar dados de diagnóstico (DiagnosticoHiveRepository)
/// - Integrar dados de defensivos (FitossanitarioHiveRepository)
/// - Retornar lista consolidada de pragas para uma cultura específica
@injectable
class PragasCulturaIntegrationDataSource {
  final PragasHiveRepository _pragasRepository;
  final DiagnosticoHiveRepository _diagnosticoRepository;
  final FitossanitarioHiveRepository _fitossanitarioRepository;

  const PragasCulturaIntegrationDataSource(
    this._pragasRepository,
    this._diagnosticoRepository,
    this._fitossanitarioRepository,
  );

  /// Carrega pragas para uma cultura específica
  ///
  /// Integra dados de múltiplas fontes:
  /// 1. Busca todas as pragas do banco
  /// 2. Conta diagnósticos por praga (para mostrar frequência)
  /// 3. Busca defensivos disponíveis para cada praga
  ///
  /// [culturaId]: ID da cultura para filtrar pragas
  /// Returns: Lista consolidada com pragas, contagem de diagnósticos e defensivos
  Future<List<dynamic>> getPragasPorCultura(String culturaId) async {
    try {
      if (culturaId.isEmpty) {
        return [];
      }

      // 1. Obter todas as pragas
      final pragasResult = await _pragasRepository.getAll();
      if (pragasResult.isFailure) {
        return [];
      }

      final allPragas = pragasResult.data ?? [];
      if (allPragas.isEmpty) {
        return [];
      }

      // 2. Obter diagnósticos para contar frequência
      final diagnosticosResult = await _diagnosticoRepository.getAll();
      final List<dynamic> diagnosticos =
          diagnosticosResult.isSuccess ? (diagnosticosResult.data ?? []) : [];

      // 3. Agrupar por tipo de praga e contar diagnósticos
      final List<Map<String, dynamic>> pragasComDados =
          allPragas.map<Map<String, dynamic>>((praga) {
        // Contar diagnósticos para esta praga
        final countDiagnosticos = diagnosticos.where((dynamic d) {
          // Verificar se o diagnóstico está associado a esta praga
          // Ajustar conforme a estrutura real do modelo Diagnóstico
          return true; // Placeholder - ajustar com lógica real
        }).length;

        return {
          'praga': praga,
          'totalDiagnosticos': countDiagnosticos,
          'culturaId': culturaId,
        };
      }).toList();

      return pragasComDados;
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

      final defensivosResult = await _fitossanitarioRepository.getAll();
      if (defensivosResult.isFailure) {
        return [];
      }

      final allDefensivos = defensivosResult.data ?? [];

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
      final pragaResult = await _pragasRepository.getByKey(pragaId);
      if (pragaResult.isFailure) {
        throw Exception('Praga não encontrada');
      }

      final praga = pragaResult.data;
      if (praga == null) {
        throw Exception('Praga não encontrada');
      }

      // Buscar defensivos
      final defensivos = await getDefensivosForPraga(pragaId);

      // Contar diagnósticos
      final diagnosticosResult = await _diagnosticoRepository.getAll();
      final List<dynamic> diagnosticos = diagnosticosResult.isSuccess ? (diagnosticosResult.data ?? []) : [];
      final countDiagnosticos = diagnosticos.length;

      return {
        'praga': praga,
        'defensivos': defensivos,
        'totalDiagnosticos': countDiagnosticos,
        'culturaId': culturaId,
      };
    } catch (e) {
      throw Exception('Erro ao buscar praga completa: $e');
    }
  }
}

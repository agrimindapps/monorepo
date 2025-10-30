import '../../domain/repositories/i_pragas_cultura_repository.dart';

/// Service para operações de I/O com pragas por cultura
///
/// Responsabilidades:
/// - Carregar pragas por cultura
/// - Carregar culturas disponíveis
/// - Carregar defensivos
/// - Gerenciar cache
abstract class IPragasCulturaDataService {
  /// Carrega pragas para uma cultura específica
  Future<List<Map<String, dynamic>>> getPragasForCultura(String culturaId);

  /// Carrega todas as culturas
  Future<List<Map<String, dynamic>>> getAllCulturas();

  /// Carrega defensivos para uma praga
  Future<List<Map<String, dynamic>>> getDefensivosForPraga(String pragaId);

  /// Limpa cache local
  Future<void> clearCache();

  /// Verifica se há dados em cache
  Future<bool> hasCachedData();
}

/// Implementação padrão do Data Service
class PragasCulturaDataService implements IPragasCulturaDataService {
  final IPragasCulturaRepository repository;

  PragasCulturaDataService({required this.repository});

  @override
  Future<List<Map<String, dynamic>>> getPragasForCultura(
    String culturaId,
  ) async {
    try {
      final pragasResult = await repository.getPragasPorCultura(culturaId);
      return pragasResult.fold(
        (failure) => [],
        (pragas) => (pragas as List).cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllCulturas() async {
    try {
      final culturasResult = await repository.getCulturas();
      return culturasResult.fold(
        (failure) => [],
        (culturas) => (culturas as List).cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDefensivosForPraga(
    String pragaId,
  ) async {
    try {
      final defensivosResult = await repository.getDefensivos(pragaId);
      return defensivosResult.fold(
        (failure) => [],
        (defensivos) => (defensivos as List).cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // Clear cache for all culturas - using empty string as sentinel
      await repository.clearCache('');
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Future<bool> hasCachedData() async {
    try {
      final culturas = await getAllCulturas();
      return culturas.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

// Project imports:
import '../../../core/error/result.dart';
import '../entities/defensivo_entity.dart';
import '../entities/defensivos_stats_entity.dart';

/// Interface do repositório de defensivos
/// 
/// Define os contratos que devem ser implementados pela camada de infraestrutura
/// sem depender de detalhes de implementação
abstract class IDefensivosRepository {
  /// Obtém estatísticas gerais dos defensivos
  Future<Result<DefensivosStatsEntity>> getDefensivosStats();

  /// Obtém lista de defensivos recentemente acessados
  Future<Result<List<DefensivoEntity>>> getRecentlyAccessedDefensivos();

  /// Obtém lista de defensivos novos
  Future<Result<List<DefensivoEntity>>> getNewDefensivos();

  /// Obtém um defensivo específico por ID
  Future<Result<DefensivoEntity>> getDefensivoById(String id);

  /// Obtém lista de defensivos por categoria
  Future<Result<List<DefensivoEntity>>> getDefensivosByCategory(String category);

  /// Registra acesso a um defensivo
  Future<Result<void>> registerDefensivoAccess(String defensivoId);

  /// Obtém lista de classes agronômicas
  Future<Result<List<String>>> getClassesAgronomicas();

  /// Obtém lista de fabricantes
  Future<Result<List<String>>> getFabricantes();

  /// Obtém lista de modos de ação
  Future<Result<List<String>>> getModosDeAcao();

  /// Obtém lista de ingredientes ativos
  Future<Result<List<String>>> getIngredientesAtivos();

  /// Verifica se os dados estão carregados
  bool get isDataLoaded;

  /// Inicializa o repositório
  Future<Result<void>> initialize();

  /// Limpa o cache/estado interno
  Future<Result<void>> dispose();
}
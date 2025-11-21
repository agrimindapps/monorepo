import 'package:core/core.dart' hide Column;
import '../entities/defensivo_entity.dart';

/// Interface para repositório de defensivos
/// Segue padrões Clean Architecture - domain layer define contratos
abstract class IDefensivosRepository {

  Future<Either<Failure, List<DefensivoEntity>>> getAllDefensivos();
  
  /// Busca defensivos por classe agronômica
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosByClasse(String classe);
  
  /// Busca defensivo por ID
  Future<Either<Failure, DefensivoEntity?>> getDefensivoById(String id);
  
  /// Pesquisa defensivos por nome ou ingrediente ativo
  Future<Either<Failure, List<DefensivoEntity>>> searchDefensivos(String query);
  
  /// Busca defensivos por fabricante
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosByFabricante(String fabricante);
  
  /// Busca defensivos por modo de ação
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosByModoAcao(String modoAcao);
  
  /// Busca classes agronômicas disponíveis
  Future<Either<Failure, List<String>>> getClassesAgronomicas();
  
  /// Busca fabricantes disponíveis
  Future<Either<Failure, List<String>>> getFabricantes();
  
  /// Busca modos de ação disponíveis
  Future<Either<Failure, List<String>>> getModosAcao();
  
  /// Busca defensivos recentes (ordenados por lastUpdated)
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosRecentes({int limit = 10});
  
  /// Busca estatísticas dos defensivos
  Future<Either<Failure, Map<String, int>>> getDefensivosStats();
  
  /// Verifica se defensivo está ativo
  Future<Either<Failure, bool>> isDefensivoActive(String defensivoId);
  
  /// Busca defensivos agrupados por tipo de agrupamento
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosAgrupados({
    required String tipoAgrupamento,
    String? filtroTexto,
  });
  
  /// Busca defensivos completos para comparação
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosCompletos();
  
  /// Busca defensivos por filtros avançados
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosComFiltros({
    String? ordenacao,
    String? filtroToxicidade,
    String? filtroTipo,
    bool apenasComercializados = false,
    bool apenasElegiveis = false,
  });
}

import 'package:core/core.dart';
import '../entities/busca_entity.dart';

/// Interface para repositório de busca avançada
/// Segue padrões Clean Architecture - domain layer define contratos
abstract class IBuscaRepository {
  /// Realiza busca com filtros específicos
  Future<Either<Failure, List<BuscaResultEntity>>> buscarComFiltros(
    BuscaFiltersEntity filters,
  );
  
  /// Busca por query de texto livre
  Future<Either<Failure, List<BuscaResultEntity>>> buscarPorTexto(
    String query, {
    List<String>? tipos,
    int? limit,
  });
  
  /// Busca diagnósticos por cultura e praga
  Future<Either<Failure, List<BuscaResultEntity>>> buscarDiagnosticos({
    String? culturaId,
    String? pragaId,
    String? defensivoId,
  });
  
  /// Busca pragas por cultura
  Future<Either<Failure, List<BuscaResultEntity>>> buscarPragasPorCultura(
    String culturaId,
  );
  
  /// Busca defensivos por praga
  Future<Either<Failure, List<BuscaResultEntity>>> buscarDefensivosPorPraga(
    String pragaId,
  );
  
  /// Carrega metadados para dropdowns de filtros
  Future<Either<Failure, BuscaMetadataEntity>> getMetadados();
  
  /// Busca sugestões baseadas em histórico
  Future<Either<Failure, List<BuscaResultEntity>>> getSugestoes({
    int limit = 10,
  });
  
  /// Salva histórico de busca
  Future<Either<Failure, void>> salvarHistoricoBusca(
    BuscaFiltersEntity filters,
    List<BuscaResultEntity> resultados,
  );
  
  /// Busca no histórico
  Future<Either<Failure, List<BuscaFiltersEntity>>> getHistoricoBusca({
    int limit = 20,
  });
  
  /// Limpa cache de busca
  Future<Either<Failure, void>> limparCache();
}

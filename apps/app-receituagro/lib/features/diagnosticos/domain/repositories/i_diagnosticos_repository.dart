import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../entities/diagnostico_entity.dart';

/// Interface do repositório de diagnósticos (Domain Layer)
/// Define contratos para acesso aos dados seguindo Dependency Inversion Principle
abstract class IDiagnosticosRepository {
  /// Busca todos os diagnósticos com paginação opcional
  Future<Either<Failure, List<DiagnosticoEntity>>> getAll({
    int? limit,
    int? offset,
  });

  /// Busca diagnóstico por ID
  Future<Either<Failure, DiagnosticoEntity?>> getById(String id);

  /// Busca diagnósticos por defensivo
  Future<Either<Failure, List<DiagnosticoEntity>>> getByDefensivo(String idDefensivo);

  /// Busca diagnósticos por cultura
  Future<Either<Failure, List<DiagnosticoEntity>>> getByCultura(String idCultura);

  /// Busca diagnósticos por praga
  Future<Either<Failure, List<DiagnosticoEntity>>> getByPraga(String idPraga);

  /// Busca diagnósticos por combinação defensivo-cultura-praga
  Future<Either<Failure, List<DiagnosticoEntity>>> getByTriplaCombinacao({
    String? idDefensivo,
    String? idCultura,
    String? idPraga,
  });

  /// Busca diagnósticos por nome do defensivo
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByNomeDefensivo(String nome);

  /// Busca diagnósticos por nome da cultura
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByNomeCultura(String nome);

  /// Busca diagnósticos por nome da praga
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByNomePraga(String nome);

  /// Busca diagnósticos por tipo de aplicação
  Future<Either<Failure, List<DiagnosticoEntity>>> getByTipoAplicacao(TipoAplicacao tipo);

  /// Busca diagnósticos por nível de completude
  Future<Either<Failure, List<DiagnosticoEntity>>> getByCompletude(DiagnosticoCompletude completude);

  /// Busca diagnósticos por faixa de dosagem
  Future<Either<Failure, List<DiagnosticoEntity>>> getByFaixaDosagem({
    required double dosagemMinima,
    required double dosagemMaxima,
  });

  /// Busca com filtros estruturados
  Future<Either<Failure, List<DiagnosticoEntity>>> searchWithFilters(
    DiagnosticoSearchFilters filters,
  );

  /// Busca diagnósticos similares (mesmo defensivo ou mesma praga)
  Future<Either<Failure, List<DiagnosticoEntity>>> getSimilarDiagnosticos(
    String diagnosticoId, {
    int limit = 5,
  });

  /// Busca recomendações para uma combinação cultura-praga
  Future<Either<Failure, List<DiagnosticoEntity>>> getRecomendacoesPara({
    required String idCultura,
    required String idPraga,
    int limit = 10,
  });

  /// Obter estatísticas dos diagnósticos
  Future<Either<Failure, DiagnosticosStats>> getStatistics();

  /// Obter diagnósticos mais populares/usados
  Future<Either<Failure, List<DiagnosticoPopular>>> getPopularDiagnosticos({
    int limit = 10,
  });

  /// Verificar se diagnóstico existe
  Future<Either<Failure, bool>> exists(String id);

  /// Contar diagnósticos por filtros
  Future<Either<Failure, int>> countByFilters(DiagnosticoSearchFilters filters);

  /// Obter todos os defensivos únicos nos diagnósticos
  Future<Either<Failure, List<String>>> getAllDefensivos();

  /// Obter todas as culturas únicas nos diagnósticos
  Future<Either<Failure, List<String>>> getAllCulturas();

  /// Obter todas as pragas únicas nos diagnósticos
  Future<Either<Failure, List<String>>> getAllPragas();

  /// Validar compatibilidade defensivo-cultura-praga
  Future<Either<Failure, bool>> validarCompatibilidade({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  });

  /// Obter unidades de medida disponíveis
  Future<Either<Failure, List<String>>> getUnidadesMedida();

  /// Buscar por padrão geral (nome defensivo, cultura ou praga)
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByPattern(String pattern);
}

/// Interface para dados de filtros de diagnósticos
abstract class IDiagnosticoFiltersDataRepository {
  /// Obter dados para montagem de filtros
  Future<Either<Failure, DiagnosticoFiltersData>> getFiltersData();
}
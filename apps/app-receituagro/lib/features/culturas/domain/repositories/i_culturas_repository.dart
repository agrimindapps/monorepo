import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../entities/cultura_entity.dart';

/// Interface para repositório de culturas
/// Segue padrões Clean Architecture - domain layer define contratos
abstract class ICulturasRepository {
  /// Busca todas as culturas disponíveis
  Future<Either<Failure, List<CulturaEntity>>> getAllCulturas();
  
  /// Busca culturas por grupo específico
  Future<Either<Failure, List<CulturaEntity>>> getCulturasByGrupo(String grupo);
  
  /// Busca cultura por ID
  Future<Either<Failure, CulturaEntity?>> getCulturaById(String id);
  
  /// Busca culturas por nome (pesquisa)
  Future<Either<Failure, List<CulturaEntity>>> searchCulturas(String query);
  
  /// Busca grupos de culturas disponíveis
  Future<Either<Failure, List<String>>> getGruposCulturas();
  
  /// Verifica se cultura está ativa
  Future<Either<Failure, bool>> isCulturaActive(String culturaId);
}
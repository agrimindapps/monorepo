import 'package:core/core.dart';

import '../entities/praga_entity.dart';

/// Interface do repositório de pragas (Domain Layer)
/// Princípios: Dependency Inversion + Interface Segregation
/// Segue padrão Either&lt;Failure, T&gt; para error handling consistente
abstract class IPragasRepository {
  /// Operações básicas de consulta
  Future<Either<Failure, List<PragaEntity>>> getAll();
  Future<Either<Failure, PragaEntity?>> getById(String id);
  Future<Either<Failure, List<PragaEntity>>> getByTipo(String tipo);

  /// Busca e filtros
  Future<Either<Failure, List<PragaEntity>>> searchByName(String searchTerm);
  Future<Either<Failure, List<PragaEntity>>> getByFamilia(String familia);
  Future<Either<Failure, List<PragaEntity>>> getByCultura(String culturaId);

  /// Operações de contagem
  Future<Either<Failure, int>> getCountByTipo(String tipo);
  Future<Either<Failure, int>> getTotalCount();

  /// Operações avançadas
  Future<Either<Failure, List<PragaEntity>>> getPragasRecentes({
    int limit = 10,
  });
  Future<Either<Failure, Map<String, int>>> getPragasStats();
  Future<Either<Failure, List<String>>> getTiposPragas();
  Future<Either<Failure, List<String>>> getFamiliasPragas();
}

/// Interface para operações de cache/histórico
/// Princípio: Interface Segregation - Responsabilidade específica
abstract class IPragasHistoryRepository {
  Future<Either<Failure, List<PragaEntity>>> getRecentlyAccessed();
  Future<Either<Failure, void>> markAsAccessed(String pragaId);
  Future<Either<Failure, List<PragaEntity>>> getSuggested(int limit);
}

/// Interface para formatação de dados
/// Princípio: Interface Segregation - Responsabilidade específica
abstract class IPragasFormatter {
  String formatImageName(String nomeCientifico);
  Map<String, dynamic> formatForDisplay(PragaEntity praga);
  String formatNomeComum(String nomeCompleto);
}

/// Interface para informações adicionais de pragas
/// Princípio: Interface Segregation - Responsabilidade específica
abstract class IPragasInfoRepository {
  Future<Either<Failure, PragaInfo?>> getInfoByPragaId(String pragaId);
  Future<Either<Failure, PlantaInfo?>> getPlantaInfoByPragaId(String pragaId);
}

/// Value Objects para informações adicionais
class PragaInfo {
  final String descricao;
  final String sintomas;
  final String bioecologia;
  final String controle;

  const PragaInfo({
    required this.descricao,
    required this.sintomas,
    required this.bioecologia,
    required this.controle,
  });
}

class PlantaInfo {
  final String ciclo;
  final String reproducao;
  final String habitat;
  final String adaptacoes;
  final String altura;

  const PlantaInfo({
    required this.ciclo,
    required this.reproducao,
    required this.habitat,
    required this.adaptacoes,
    required this.altura,
  });
}

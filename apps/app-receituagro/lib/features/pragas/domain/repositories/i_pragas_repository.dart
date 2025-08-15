import '../entities/praga_entity.dart';

/// Interface do repositório de pragas (Domain Layer)
/// Princípios: Dependency Inversion + Interface Segregation
abstract class IPragasRepository {
  /// Operações básicas de consulta
  Future<List<PragaEntity>> getAll();
  Future<PragaEntity?> getById(String id);
  Future<List<PragaEntity>> getByTipo(String tipo);
  
  /// Busca e filtros
  Future<List<PragaEntity>> searchByName(String searchTerm);
  Future<List<PragaEntity>> getByFamilia(String familia);
  Future<List<PragaEntity>> getByCultura(String culturaId);
  
  /// Operações de contagem
  Future<int> getCountByTipo(String tipo);
  Future<int> getTotalCount();
}

/// Interface para operações de cache/histórico
/// Princípio: Interface Segregation - Responsabilidade específica
abstract class IPragasHistoryRepository {
  Future<List<PragaEntity>> getRecentlyAccessed();
  Future<void> markAsAccessed(String pragaId);
  Future<List<PragaEntity>> getSuggested(int limit);
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
  Future<PragaInfo?> getInfoByPragaId(String pragaId);
  Future<PlantaInfo?> getPlantaInfoByPragaId(String pragaId);
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
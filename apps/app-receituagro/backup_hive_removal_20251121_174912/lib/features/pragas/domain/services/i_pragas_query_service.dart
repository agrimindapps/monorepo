import '../entities/praga_entity.dart';

/// Service responsible for querying and filtering pragas by various criteria.
///
/// This service encapsulates logic for querying pragas by type, family, culture,
/// and extracting metadata. Separating this from the repository improves
/// Single Responsibility Principle (SRP) compliance.
///
/// Responsibilities:
/// - Query pragas by tipo (inseto, doença, planta)
/// - Query pragas by família (taxonomia)
/// - Query pragas by cultura
/// - Extract distinct tipos (metadata)
/// - Extract distinct famílias (metadata)
/// - Get recent pragas
abstract class IPragasQueryService {
  /// Get all pragas filtered by tipo
  List<PragaEntity> getByTipo(List<PragaEntity> pragas, String tipo);

  /// Get all pragas filtered by família
  List<PragaEntity> getByFamilia(List<PragaEntity> pragas, String familia);

  /// Get all pragas filtered by cultura
  List<PragaEntity> getByCultura(List<PragaEntity> pragas, String culturaId);

  /// Get most recent pragas (first N items)
  List<PragaEntity> getRecentes(
    List<PragaEntity> pragas, {
    int limit = 10,
  });

  /// Extract all distinct tipos from pragas
  List<String> getTiposPragas(List<PragaEntity> pragas);

  /// Extract all distinct famílias from pragas
  List<String> getFamiliasPragas(List<PragaEntity> pragas);
}

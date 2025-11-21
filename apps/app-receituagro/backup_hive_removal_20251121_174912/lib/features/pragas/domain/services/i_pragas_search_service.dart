import '../entities/praga_entity.dart';

/// Service responsible for searching pragas with relevance ranking.
///
/// This service encapsulates search logic with sophisticated relevance ranking,
/// supporting exact matches, prefix matches, and partial matches. Separating
/// this from the repository improves Single Responsibility Principle (SRP).
///
/// Responsibilities:
/// - Search pragas by name with relevance ranking
/// - Support multiple name formats (common names, alternative names, scientific names)
/// - Implement relevance sorting (exact > prefix > partial)
abstract class IPragasSearchService {
  /// Search pragas by name with relevance ranking
  /// Searches in: nomeComum, nomesSecundarios, nomeCientifico
  /// Returns results sorted by relevance
  List<PragaEntity> searchByName(
    List<PragaEntity> pragas,
    String searchTerm,
  );

  /// Search with custom predicate function
  List<PragaEntity> searchCustom(
    List<PragaEntity> pragas,
    bool Function(PragaEntity) predicate,
  );
}

import '../../domain/entities/praga_entity.dart';

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

/// Default implementation of search service with relevance ranking
class PragasSearchService implements IPragasSearchService {
  @override
  List<PragaEntity> searchByName(
    List<PragaEntity> pragas,
    String searchTerm,
  ) {
    if (searchTerm.trim().isEmpty) {
      return [];
    }

    final term = searchTerm.trim().toLowerCase();
    final filtered = pragas.where((praga) {
      final nomeComumLower = praga.nomeComum.toLowerCase();
      final nomeCientificoLower = praga.nomeCientifico.toLowerCase();

      // Check main names
      final nomeComumMatch = nomeComumLower.contains(term);
      final nomeCientificoMatch = nomeCientificoLower.contains(term);

      // Check secondary names (separated by semicolon)
      final nomesSecundariosMatch = praga.nomeComum.contains(';') &&
          praga.nomeComum.toLowerCase().split(';').any((name) =>
              name.trim().toLowerCase().contains(term));

      return nomeComumMatch || nomeCientificoMatch || nomesSecundariosMatch;
    }).toList();

    // Sort by relevance
    filtered.sort((a, b) {
      final aNameLower = a.nomeComum.toLowerCase();
      final bNameLower = b.nomeComum.toLowerCase();

      // Exact match has highest priority
      if (aNameLower == term && bNameLower != term) return -1;
      if (bNameLower == term && aNameLower != term) return 1;

      // Prefix match has second priority
      final aStartsWith = aNameLower.startsWith(term);
      final bStartsWith = bNameLower.startsWith(term);
      if (aStartsWith && !bStartsWith) return -1;
      if (bStartsWith && !aStartsWith) return 1;

      // Alphabetical order for same relevance
      return a.nomeComum.compareTo(b.nomeComum);
    });

    return filtered;
  }

  @override
  List<PragaEntity> searchCustom(
    List<PragaEntity> pragas,
    bool Function(PragaEntity) predicate,
  ) {
    return pragas.where(predicate).toList();
  }
}

import '../../domain/entities/cultura_entity.dart';

/// Service responsible for querying and extracting metadata from culturas.
///
/// This service encapsulates logic for extracting distinct values and
/// querying culturas by various criteria. Separating this from the repository
/// improves Single Responsibility Principle (SRP) compliance.
///
/// Responsibilities:
/// - Extract distinct grupos from culturas
/// - Query culturas by grupo
/// - Check if cultura is active
abstract class ICulturasQueryService {
  /// Get all distinct grupos from culturas
  List<String> getGrupos(List<CulturaEntity> culturas);

  /// Filter culturas by grupo
  List<CulturaEntity> getByGrupo(List<CulturaEntity> culturas, String grupo);

  /// Check if cultura is active by ID
  bool isCulturaActive(List<CulturaEntity> culturas, String culturaId);
}

/// Default implementation of query service
class CulturasQueryService implements ICulturasQueryService {
  @override
  List<String> getGrupos(List<CulturaEntity> culturas) {
    final grupos = culturas
        .map((cultura) => cultura.grupo)
        .where((grupo) => grupo != null && grupo.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    grupos.sort();
    return grupos;
  }

  @override
  List<CulturaEntity> getByGrupo(List<CulturaEntity> culturas, String grupo) {
    if (grupo.isEmpty) {
      return [];
    }

    return culturas.where((cultura) {
      return cultura.grupo?.toLowerCase().contains(grupo.toLowerCase()) ?? false;
    }).toList();
  }

  @override
  bool isCulturaActive(List<CulturaEntity> culturas, String culturaId) {
    return culturas.any((c) => c.id == culturaId);
  }
}

import '../../domain/entities/praga_entity.dart';

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

/// Default implementation of query service
class PragasQueryService implements IPragasQueryService {
  @override
  List<PragaEntity> getByTipo(List<PragaEntity> pragas, String tipo) {
    if (tipo.isEmpty) {
      return [];
    }
    return pragas.where((p) => p.tipoPraga == tipo).toList();
  }

  @override
  List<PragaEntity> getByFamilia(List<PragaEntity> pragas, String familia) {
    if (familia.isEmpty) {
      return [];
    }
    return pragas.where((p) => p.familia == familia).toList();
  }

  @override
  List<PragaEntity> getByCultura(List<PragaEntity> pragas, String culturaId) {
    if (culturaId.isEmpty) {
      return [];
    }
    // Note: Pragas are not directly linked to cultura in the model
    // This method returns all pragas (can be used for general queries)
    return pragas;
  }

  @override
  List<PragaEntity> getRecentes(
    List<PragaEntity> pragas, {
    int limit = 10,
  }) {
    return pragas.take(limit).toList();
  }

  @override
  List<String> getTiposPragas(List<PragaEntity> pragas) {
    final tipos = pragas
        .map((praga) => praga.tipoPraga)
        .where((tipo) => tipo.isNotEmpty)
        .toSet()
        .toList();

    tipos.sort();
    return tipos;
  }

  @override
  List<String> getFamiliasPragas(List<PragaEntity> pragas) {
    final familias = pragas
        .map((praga) => praga.familia)
        .where((familia) => familia != null && familia.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    familias.sort();
    return familias;
  }
}

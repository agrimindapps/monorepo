import 'package:injectable/injectable.dart';

import '../../domain/entities/cultura_entity.dart';

/// Service responsible for searching culturas.
///
/// This service encapsulates search logic, separating it from the repository
/// to improve Single Responsibility Principle (SRP) compliance.
///
/// Responsibilities:
/// - Search culturas by name/query
/// - Support custom predicates
abstract class ICulturasSearchService {
  /// Search culturas by query string
  /// Searches in: nome, cultura, grupo
  List<CulturaEntity> search(List<CulturaEntity> culturas, String query);

  /// Search with custom predicate function
  List<CulturaEntity> searchCustom(
    List<CulturaEntity> culturas,
    bool Function(CulturaEntity) predicate,
  );
}

/// Default implementation of search service
@LazySingleton(as: ICulturasSearchService)
class CulturasSearchService implements ICulturasSearchService {
  @override
  List<CulturaEntity> search(List<CulturaEntity> culturas, String query) {
    if (query.trim().isEmpty) {
      return culturas;
    }

    final queryLower = query.toLowerCase();
    return culturas.where((cultura) {
      final nomeMatch = cultura.nome.toLowerCase().contains(queryLower);
      final grupoMatch =
          cultura.grupo?.toLowerCase().contains(queryLower) == true;

      return nomeMatch || grupoMatch;
    }).toList();
  }

  @override
  List<CulturaEntity> searchCustom(
    List<CulturaEntity> culturas,
    bool Function(CulturaEntity) predicate,
  ) {
    return culturas.where(predicate).toList();
  }
}

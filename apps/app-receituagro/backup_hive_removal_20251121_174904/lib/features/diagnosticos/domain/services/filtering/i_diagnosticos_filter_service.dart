import 'package:core/core.dart' hide Column;

import '../../entities/diagnostico_entity.dart';

/// Interface for filtering diagnosticos by different criteria
/// Follows Single Responsibility Principle (SOLID)
///
/// This service handles all filtering operations for diagnosticos,
/// including server-side queries (delegating to repository) and
/// client-side filtering (in-memory operations).
abstract class IDiagnosticosFilterService {
  /// Filter diagnosticos by defensivo ID
  ///
  /// Delegates to repository for efficient querying.
  /// Returns list of diagnosticos that match the specified defensivo.
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByDefensivo(
    String idDefensivo,
  );

  /// Filter diagnosticos by cultura ID
  ///
  /// Delegates to repository for efficient querying.
  /// Returns list of diagnosticos that match the specified cultura.
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByCultura(
    String idCultura,
  );

  /// Filter diagnosticos by praga ID
  ///
  /// Delegates to repository for efficient querying.
  /// Returns list of diagnosticos that match the specified praga.
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByPraga(
    String idPraga,
  );

  /// Filter diagnosticos by triple combination (defensivo-cultura-praga)
  ///
  /// All parameters are optional. At least one must be provided.
  /// Returns diagnosticos matching all specified criteria (AND operation).
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByTriplaCombinacao({
    String? idDefensivo,
    String? idCultura,
    String? idPraga,
  });

  /// Filter diagnosticos by application type (terrestre or aerea)
  ///
  /// Delegates to repository for efficient querying.
  /// Returns diagnosticos that support the specified application type.
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByTipoAplicacao(
    TipoAplicacao tipo,
  );

  /// Filter diagnosticos by completeness level
  ///
  /// Levels: completo, parcial, incompleto
  /// Delegates to repository for efficient querying.
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByCompletude(
    DiagnosticoCompletude completude,
  );

  /// Filter diagnosticos by dosage range
  ///
  /// Returns diagnosticos with dosage maximum between specified range.
  /// Validates that min < max.
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByFaixaDosagem({
    required double min,
    required double max,
  });

  // ========== Client-side filtering methods ==========
  // These operate on in-memory lists for additional filtering

  /// Filter in-memory list by application type
  ///
  /// Useful for client-side filtering after initial query.
  /// Returns diagnosticos that support the specified application type.
  List<DiagnosticoEntity> filterListByTipoAplicacao(
    List<DiagnosticoEntity> diagnosticos,
    TipoAplicacao tipo,
  );

  /// Filter in-memory list by completeness level
  ///
  /// Useful for client-side filtering after initial query.
  List<DiagnosticoEntity> filterListByCompletude(
    List<DiagnosticoEntity> diagnosticos,
    DiagnosticoCompletude completude,
  );

  /// Filter in-memory list by dosage range
  ///
  /// Returns diagnosticos with dosage maximum between specified range.
  /// Validates that min < max before filtering.
  List<DiagnosticoEntity> filterListByFaixaDosagem(
    List<DiagnosticoEntity> diagnosticos, {
    required double min,
    required double max,
  });
}

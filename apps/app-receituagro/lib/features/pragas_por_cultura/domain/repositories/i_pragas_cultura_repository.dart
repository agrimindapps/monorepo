import 'package:core/core.dart';

/// Repository interface for pragas por cultura feature
///
/// Handles:
/// - Loading culturas
/// - Loading pragas for a specific cultura
/// - Integration with multiple data sources
abstract class IPragasCulturaRepository {
  /// Get all culturas available
  /// Returns: Either of List of CulturaEntity
  /// Failures: CacheFailure, ServerFailure
  Future<Either<Failure, List<dynamic>>> getCulturas();

  /// Get pragas for a specific cultura
  /// Integrates data from:
  /// - PragasHive (base praga data)
  /// - DiagnosticoHive (diagnostic count)
  /// - FitossanitarioHive (defensive data)
  ///
  /// [culturaId]: ID da cultura
  /// Returns: Either of List of PragaPorCultura
  /// Failures: ValidationFailure, ServerFailure, CacheFailure
  Future<Either<Failure, List<dynamic>>> getPragasPorCultura(
    String culturaId,
  );

  /// Get defensivos for a specific praga
  /// [pragaId]: ID da praga
  /// Returns: Either of List of FitossanitarioEntity
  Future<Either<Failure, List<dynamic>>> getDefensivos(
    String pragaId,
  );

  /// Cache pragas locally (optional optimization)
  Future<Either<Failure, void>> cachePragas(
    String culturaId,
    List<dynamic> pragas,
  );

  /// Clear cache for a cultura
  Future<Either<Failure, void>> clearCache(String culturaId);
}

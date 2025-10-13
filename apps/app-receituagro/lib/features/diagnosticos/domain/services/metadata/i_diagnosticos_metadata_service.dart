import 'package:core/core.dart';

import '../../entities/diagnostico_entity.dart';

/// Interface for metadata extraction from diagnosticos
/// Follows Single Responsibility Principle (SOLID)
///
/// This service handles extraction of unique values and
/// metadata from diagnosticos for use in filters, dropdowns,
/// and UI components.
abstract class IDiagnosticosMetadataService {
  /// Get all unique defensivo IDs from diagnosticos
  ///
  /// Returns sorted list of defensivo IDs.
  /// Useful for populating filter dropdowns.
  Future<Either<Failure, List<String>>> getAllDefensivos();

  /// Get all unique cultura IDs from diagnosticos
  ///
  /// Returns sorted list of cultura IDs.
  /// Useful for populating filter dropdowns.
  Future<Either<Failure, List<String>>> getAllCulturas();

  /// Get all unique praga IDs from diagnosticos
  ///
  /// Returns sorted list of praga IDs.
  /// Useful for populating filter dropdowns.
  Future<Either<Failure, List<String>>> getAllPragas();

  /// Get all unique measurement units used in diagnosticos
  ///
  /// Returns sorted list of measurement units (e.g., "L/ha", "kg/ha").
  /// Useful for:
  /// - Dosage input validation
  /// - Unit conversion
  /// - UI consistency
  Future<Either<Failure, List<String>>> getUnidadesMedida();

  /// Get comprehensive filter data for UI
  ///
  /// Returns all metadata needed to populate filter forms:
  /// - List of defensivos
  /// - List of culturas
  /// - List of pragas
  /// - List of measurement units
  /// - List of application types
  ///
  /// This is an optimization to fetch all filter data in a single call.
  Future<Either<Failure, DiagnosticoFiltersData>> getFiltersData();

  // ========== Client-side metadata methods ==========

  /// Extract filter data from in-memory list
  ///
  /// Useful for client-side filter building after initial query.
  /// Extracts unique values for all filter fields.
  DiagnosticoFiltersData extractFiltersDataFromList(
    List<DiagnosticoEntity> diagnosticos,
  );
}

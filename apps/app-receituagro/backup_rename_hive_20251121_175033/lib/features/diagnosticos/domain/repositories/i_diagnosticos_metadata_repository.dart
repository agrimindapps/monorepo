import 'package:core/core.dart' hide Column;

/// Repository for metadata lookup operations
///
/// Responsibilities:
/// - Retrieve list of all defensivos
/// - Retrieve list of all culturas
/// - Retrieve list of all pragas
/// - Retrieve available measurement units
///
/// These are lookup/reference data operations used by UI and services.
/// Used by DiagnosticosMetadataService for populating dropdowns and filters.
///
/// Part of the Interface Segregation Principle refactoring.
abstract class IDiagnosticosMetadataRepository {
  /// Obter todos os defensivos disponíveis
  ///
  /// Returns list of unique defensivos from diagnosticos.
  /// Each map contains 'id' and 'nome' fields.
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllDefensivos();

  /// Obter todas as culturas disponíveis
  ///
  /// Returns list of unique culturas from diagnosticos.
  /// Each map contains 'id' and 'nome' fields.
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllCulturas();

  /// Obter todas as pragas disponíveis
  ///
  /// Returns list of unique pragas from diagnosticos.
  /// Each map contains 'id' and 'nome' fields.
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllPragas();

  /// Obter unidades de medida disponíveis
  ///
  /// Returns list of all measurement units (UM) used in diagnosticos.
  /// Sorted alphabetically.
  Future<Either<Failure, List<String>>> getUnidadesMedida();
}

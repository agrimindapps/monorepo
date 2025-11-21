import 'package:core/core.dart' hide Column;

import '../entities/diagnostico_entity.dart';

/// Read-only repository for basic CRUD and access operations
///
/// Responsibilities:
/// - Retrieve all diagnosticos with optional pagination
/// - Retrieve single diagnostico by ID
///
/// Part of the Interface Segregation Principle refactoring.
/// Separates read operations from queries, search, metadata, etc.
abstract class IDiagnosticosReadRepository {

  ///
  /// Core read operation for diagnosticos.
  /// Returns all diagnosticos with optional pagination support.
  Future<Either<Failure, List<DiagnosticoEntity>>> getAll({
    int? limit,
    int? offset,
  });

  /// Busca diagnóstico por ID
  ///
  /// Core read operation by unique identifier.
  /// Returns single diagnostico or null if not found.
  Future<Either<Failure, DiagnosticoEntity?>> getById(String id);
}

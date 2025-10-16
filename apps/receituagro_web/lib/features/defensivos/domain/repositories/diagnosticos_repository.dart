import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/diagnostico.dart';

/// Diagnosticos repository contract (interface)
/// Manages the many-to-many relationship between Defensivo, Cultura, and Praga
abstract class DiagnosticosRepository {
  /// Get all diagnosticos for a specific defensivo
  Future<Either<Failure, List<Diagnostico>>> getDiagnosticosByDefensivoId(
    String defensivoId,
  );

  /// Get a single diagnostico by ID
  Future<Either<Failure, Diagnostico>> getDiagnosticoById(String id);

  /// Create a new diagnostico entry
  Future<Either<Failure, Diagnostico>> createDiagnostico(Diagnostico diagnostico);

  /// Update an existing diagnostico
  Future<Either<Failure, Diagnostico>> updateDiagnostico(Diagnostico diagnostico);

  /// Delete a diagnostico by ID
  Future<Either<Failure, Unit>> deleteDiagnostico(String id);

  /// Delete all diagnosticos for a specific defensivo
  Future<Either<Failure, Unit>> deleteDiagnosticosByDefensivoId(
    String defensivoId,
  );
}

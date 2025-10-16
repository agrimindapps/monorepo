import '../models/diagnostico_model.dart';

/// Remote data source contract for diagnosticos
/// Handles CRUD operations for the many-to-many relationship table
abstract class DiagnosticosRemoteDataSource {
  /// Get all diagnosticos for a specific defensivo
  Future<List<DiagnosticoModel>> getDiagnosticosByDefensivoId(String defensivoId);

  /// Get a single diagnostico by ID
  Future<DiagnosticoModel> getDiagnosticoById(String id);

  /// Create a new diagnostico entry
  Future<DiagnosticoModel> createDiagnostico(DiagnosticoModel diagnostico);

  /// Update an existing diagnostico
  Future<DiagnosticoModel> updateDiagnostico(DiagnosticoModel diagnostico);

  /// Delete a diagnostico by ID
  Future<void> deleteDiagnostico(String id);

  /// Delete all diagnosticos for a specific defensivo
  Future<void> deleteDiagnosticosByDefensivoId(String defensivoId);
}

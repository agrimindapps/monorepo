import '../models/defensivo_model.dart';

/// Remote data source contract for defensivos
abstract class DefensivosRemoteDataSource {
  /// Get all defensivos from remote source
  Future<List<DefensivoModel>> getAllDefensivos();

  /// Get a single defensivo by ID
  Future<DefensivoModel> getDefensivoById(String id);

  /// Search defensivos by query
  Future<List<DefensivoModel>> searchDefensivos(String query);

  /// Create a new defensivo
  Future<DefensivoModel> createDefensivo(DefensivoModel defensivo);

  /// Update an existing defensivo
  Future<DefensivoModel> updateDefensivo(DefensivoModel defensivo);

  /// Delete a defensivo by ID
  Future<void> deleteDefensivo(String id);
}

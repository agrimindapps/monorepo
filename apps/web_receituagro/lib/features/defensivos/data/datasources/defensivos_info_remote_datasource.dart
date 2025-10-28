import '../models/defensivo_info_model.dart';

/// Remote data source contract for defensivos complementary information
/// Handles CRUD operations for the 1:1 relationship table
abstract class DefensivosInfoRemoteDataSource {
  /// Get defensivo info by defensivo ID (1:1 relationship)
  Future<DefensivoInfoModel?> getDefensivoInfoByDefensivoId(String defensivoId);

  /// Get defensivo info by its own ID
  Future<DefensivoInfoModel> getDefensivoInfoById(String id);

  /// Create new defensivo info
  Future<DefensivoInfoModel> createDefensivoInfo(DefensivoInfoModel info);

  /// Update existing defensivo info
  Future<DefensivoInfoModel> updateDefensivoInfo(DefensivoInfoModel info);

  /// Delete defensivo info by ID
  Future<void> deleteDefensivoInfo(String id);

  /// Delete defensivo info by defensivo ID
  Future<void> deleteDefensivoInfoByDefensivoId(String defensivoId);
}

import '../entities/export_request.dart';

abstract class DataExportRepository {
  /// Check availability of data export for the current user
  Future<ExportAvailabilityResult> checkExportAvailability({
    required String userId,
    required Set<DataType> requestedDataTypes,
  });

  /// Request data export
  Future<ExportRequest> requestExport({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  });

  /// Load export history for user
  Future<List<ExportRequest>> getExportHistory(String userId);

  /// Download export file
  Future<bool> downloadExport(String exportId);

  /// Delete export request and associated file
  Future<bool> deleteExport(String exportId);

  /// Get user's plants data for export
  Future<List<PlantExportData>> getUserPlantsData(String userId);

  /// Get user's plant tasks data for export
  Future<List<TaskExportData>> getUserTasksData(String userId);

  /// Get user's spaces data for export
  Future<List<SpaceExportData>> getUserSpacesData(String userId);

  /// Get user's settings data for export
  Future<UserSettingsExportData> getUserSettingsData(String userId);

  /// Get user's plant photos data for export
  Future<List<PlantPhotoExportData>> getUserPlantPhotosData(String userId);

  /// Get user's plant comments data for export
  Future<List<PlantCommentExportData>> getUserPlantCommentsData(String userId);

  /// Generate export file in specified format
  Future<String> generateExportFile({
    required ExportRequest request,
    required Map<DataType, dynamic> exportData,
  });
}

import 'package:core/core.dart' hide Column;

import '../entities/export_request.dart';

abstract class DataExportRepository {
  /// Check availability of data export for the current user
  Future<Either<Failure, ExportAvailabilityResult>> checkExportAvailability({
    required String userId,
    required Set<DataType> requestedDataTypes,
  });

  /// Request data export
  Future<Either<Failure, ExportRequest>> requestExport({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  });

  /// Load export history for user
  Future<Either<Failure, List<ExportRequest>>> getExportHistory(String userId);

  /// Download export file
  Future<Either<Failure, bool>> downloadExport(String exportId);

  /// Delete export request and associated file
  Future<Either<Failure, bool>> deleteExport(String exportId);

  /// Get user's plants data for export
  Future<Either<Failure, List<PlantExportData>>> getUserPlantsData(
    String userId,
  );

  /// Get user's plant tasks data for export
  Future<Either<Failure, List<TaskExportData>>> getUserTasksData(
    String userId,
  );

  /// Get user's spaces data for export
  Future<Either<Failure, List<SpaceExportData>>> getUserSpacesData(
    String userId,
  );

  /// Get user's settings data for export
  Future<Either<Failure, UserSettingsExportData>> getUserSettingsData(
    String userId,
  );

  /// Get user's plant photos data for export
  Future<Either<Failure, List<PlantPhotoExportData>>> getUserPlantPhotosData(
    String userId,
  );

  /// Get user's plant comments data for export
  Future<Either<Failure, List<PlantCommentExportData>>>
      getUserPlantCommentsData(String userId);

  /// Generate export file in specified format
  Future<Either<Failure, String>> generateExportFile({
    required ExportRequest request,
    required Map<DataType, dynamic> exportData,
  });
}

import '../../domain/entities/export_request.dart';

/// Calculates export data statistics
/// Extracted from notifier for better separation
class ExportStatisticsCalculator {
  /// Gets available data types for export
  Set<DataType> getAvailableDataTypes() {
    return {
      DataType.plants,
      DataType.plantTasks,
      DataType.spaces,
      DataType.plantPhotos,
      DataType.plantComments,
      DataType.settings,
      DataType.customCare,
      DataType.reminders,
      DataType.userProfile,
    };
  }

  /// Placeholder for statistics calculation
  /// In actual implementation, would calculate from repository
  Future<Map<DataType, int>> calculateStatistics(String userId) async {
    // This is a placeholder - actual implementation would call repository methods
    // and count items for each data type
    return {
      DataType.plants: 0,
      DataType.plantTasks: 0,
      DataType.spaces: 0,
      DataType.plantPhotos: 0,
      DataType.plantComments: 0,
      DataType.customCare: 0,
      DataType.reminders: 0,
      DataType.settings: 1,
      DataType.userProfile: 1,
    };
  }
}

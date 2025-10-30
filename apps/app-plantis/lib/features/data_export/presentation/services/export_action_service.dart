import '../../domain/usecases/delete_export_usecase.dart';
import '../../domain/usecases/download_export_usecase.dart';

/// Service for export-related actions (download, delete)
/// Extracted from notifier for better separation
class ExportActionService {
  final DownloadExportUseCase _downloadUseCase;
  final DeleteExportUseCase _deleteUseCase;

  ExportActionService({
    required DownloadExportUseCase downloadUseCase,
    required DeleteExportUseCase deleteUseCase,
  }) : _downloadUseCase = downloadUseCase,
       _deleteUseCase = deleteUseCase;

  /// Downloads export file by ID
  /// Returns true if successful
  Future<bool> downloadExport(String exportId) async {
    final result = await _downloadUseCase(exportId);
    return result.fold((failure) => false, (success) => success);
  }

  /// Deletes export by ID
  /// Returns true if successful
  Future<bool> deleteExport(String exportId) async {
    final result = await _deleteUseCase(exportId);
    return result.fold((failure) => false, (success) => success);
  }
}

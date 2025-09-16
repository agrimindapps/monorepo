import '../entities/export_request.dart';
import '../repositories/data_export_repository.dart';

class RequestExportUseCase {
  final DataExportRepository _repository;

  RequestExportUseCase(this._repository);

  Future<ExportRequest> call({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    return await _repository.requestExport(
      userId: userId,
      dataTypes: dataTypes,
      format: format,
    );
  }
}
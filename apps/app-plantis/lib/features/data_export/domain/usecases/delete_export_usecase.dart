import '../repositories/data_export_repository.dart';

class DeleteExportUseCase {
  final DataExportRepository _repository;

  DeleteExportUseCase(this._repository);

  Future<bool> call(String exportId) async {
    return await _repository.deleteExport(exportId);
  }
}

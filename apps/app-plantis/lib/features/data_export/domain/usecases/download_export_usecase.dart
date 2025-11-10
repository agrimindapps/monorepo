import 'package:core/core.dart' hide Column;

import '../repositories/data_export_repository.dart';

class DownloadExportUseCase {
  final DataExportRepository _repository;

  DownloadExportUseCase(this._repository);

  Future<Either<Failure, bool>> call(String exportId) async {
    return await _repository.downloadExport(exportId);
  }
}

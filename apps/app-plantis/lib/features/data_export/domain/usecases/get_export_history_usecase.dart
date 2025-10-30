import 'package:core/core.dart';

import '../entities/export_request.dart';
import '../repositories/data_export_repository.dart';

class GetExportHistoryUseCase {
  final DataExportRepository _repository;

  GetExportHistoryUseCase(this._repository);

  Future<Either<Failure, List<ExportRequest>>> call(String userId) async {
    return await _repository.getExportHistory(userId);
  }
}

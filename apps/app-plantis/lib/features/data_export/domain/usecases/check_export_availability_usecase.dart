import 'package:core/core.dart';

import '../entities/export_request.dart';
import '../repositories/data_export_repository.dart';

class CheckExportAvailabilityUseCase {
  final DataExportRepository _repository;

  CheckExportAvailabilityUseCase(this._repository);

  Future<Either<Failure, ExportAvailabilityResult>> call({
    required String userId,
    required Set<DataType> requestedDataTypes,
  }) async {
    return await _repository.checkExportAvailability(
      userId: userId,
      requestedDataTypes: requestedDataTypes,
    );
  }
}

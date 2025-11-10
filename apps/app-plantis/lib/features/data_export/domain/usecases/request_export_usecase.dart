import 'package:core/core.dart' hide Column;

import '../entities/export_request.dart';
import '../repositories/data_export_repository.dart';

class RequestExportUseCase {
  final DataExportRepository _repository;

  RequestExportUseCase(this._repository);

  Future<Either<Failure, ExportRequest>> call({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    // Validate input
    if (dataTypes.isEmpty) {
      return const Left(
        ValidationFailure(
          'Selecione ao menos um tipo de dado para exportar',
          code: 'EMPTY_DATA_TYPES',
        ),
      );
    }

    return await _repository.requestExport(
      userId: userId,
      dataTypes: dataTypes,
      format: format,
    );
  }
}

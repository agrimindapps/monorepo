import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../services/export_progress_service.dart';
import '../../services/export_validation_service.dart';

part 'data_export_providers.g.dart';

@riverpod
ExportProgressService exportProgressService(ExportProgressServiceRef ref) {
  return di.sl<ExportProgressService>();
}

@riverpod
ExportValidationService exportValidationService(ExportValidationServiceRef ref) {
  return di.sl<ExportValidationService>();
}

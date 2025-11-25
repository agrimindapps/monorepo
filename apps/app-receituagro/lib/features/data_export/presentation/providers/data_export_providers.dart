import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/export_progress_service.dart';
import '../../services/export_validation_service.dart';

part 'data_export_providers.g.dart';

@riverpod
ExportProgressService exportProgressService(Ref ref) {
  return ExportProgressService();
}

@riverpod
ExportValidationService exportValidationService(
    Ref ref) {
  return ExportValidationService();
}

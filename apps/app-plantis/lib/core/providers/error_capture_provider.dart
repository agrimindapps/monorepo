import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/error_capture_service.dart';

part 'error_capture_provider.g.dart';

/// Provider for ErrorCaptureService
@riverpod
ErrorCaptureService errorCaptureService(ErrorCaptureServiceRef ref) {
  final errorLogService = ref.watch(errorLogServiceProvider);
  final service = ErrorCaptureService(errorLogService: errorLogService);

  // Initialize on first access
  service.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

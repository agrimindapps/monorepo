import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../managers/export_action_handler.dart';
import '../managers/export_dialog_manager.dart';
import '../managers/export_status_mapper.dart';
import '../services/export_action_service.dart';
import '../services/export_progress_monitor.dart';
import '../services/export_rate_limiter.dart';
import '../services/export_statistics_calculator.dart';

part 'export_managers_providers.g.dart';

/// Provides access to export dialog manager
@riverpod
ExportDialogManager exportDialogManager(Ref ref) {
  return ExportDialogManager();
}

/// Provides access to export status mapper
@riverpod
ExportStatusMapper exportStatusMapper(Ref ref) {
  return ExportStatusMapper();
}

/// Provides access to export action handler
@riverpod
ExportActionHandler exportActionHandler(Ref ref) {
  return ExportActionHandler();
}

/// Provides access to export progress monitor
@riverpod
ExportProgressMonitor exportProgressMonitor(Ref ref) {
  return ExportProgressMonitor();
}

/// Provides access to export rate limiter
@riverpod
ExportRateLimiter exportRateLimiter(Ref ref) {
  return ExportRateLimiter();
}

/// Provides access to export statistics calculator
@riverpod
ExportStatisticsCalculator exportStatisticsCalculator(
  Ref ref,
) {
  return ExportStatisticsCalculator();
}

/// Provides access to export action service
@riverpod
ExportActionService exportActionService(Ref ref) {
  // These would normally be injected from the repository
  // For now, returning a placeholder - actual implementation depends on setup
  throw UnimplementedError(
    'exportActionService requires usecases to be configured',
  );
}

import '../../domain/entities/export_request.dart';

/// Manages export rate limiting logic (1 export per hour)
/// Extracted from notifier for better testability
class ExportRateLimiter {
  /// Checks if user can request a new export
  /// Returns false if rate limit exceeded
  bool canRequestExport(List<ExportRequest> exportHistory) {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    final recentRequest = exportHistory.where(
      (request) => request.requestDate.isAfter(oneHourAgo),
    );

    return recentRequest.isEmpty;
  }

  /// Gets time until next export is allowed
  /// Returns null if user can export now
  Duration? getTimeUntilNextExportAllowed(List<ExportRequest> exportHistory) {
    if (canRequestExport(exportHistory)) return null;

    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    final mostRecentRequest = exportHistory
        .where((request) => request.requestDate.isAfter(oneHourAgo))
        .fold<ExportRequest?>(
          null,
          (most, current) =>
              most == null || current.requestDate.isAfter(most.requestDate)
              ? current
              : most,
        );

    if (mostRecentRequest == null) return null;

    final nextAllowedTime = mostRecentRequest.requestDate.add(
      const Duration(hours: 1),
    );
    return nextAllowedTime.difference(DateTime.now());
  }
}

import '../repositories/data_export_repository.dart';

class CheckExportAvailabilityUsecase {
  final DataExportRepository _repository;

  CheckExportAvailabilityUsecase(this._repository);

  Future<ExportAvailabilityResult> execute() async {
    try {
      final canExport = await _repository.canExport();

      if (canExport) {
        return ExportAvailabilityResult.available();
      }

      final lastExportDate = await _repository.getLastExportDate();
      final nextAvailableDate = lastExportDate?.add(const Duration(days: 1));

      return ExportAvailabilityResult.rateLimited(
        nextAvailableDate: nextAvailableDate,
        lastExportDate: lastExportDate,
      );
    } catch (e) {
      return ExportAvailabilityResult.error(e.toString());
    }
  }
}

class ExportAvailabilityResult {
  final bool isAvailable;
  final DateTime? nextAvailableDate;
  final DateTime? lastExportDate;
  final String? error;

  const ExportAvailabilityResult._({
    required this.isAvailable,
    this.nextAvailableDate,
    this.lastExportDate,
    this.error,
  });

  factory ExportAvailabilityResult.available() {
    return const ExportAvailabilityResult._(isAvailable: true);
  }

  factory ExportAvailabilityResult.rateLimited({
    DateTime? nextAvailableDate,
    DateTime? lastExportDate,
  }) {
    return ExportAvailabilityResult._(
      isAvailable: false,
      nextAvailableDate: nextAvailableDate,
      lastExportDate: lastExportDate,
    );
  }

  factory ExportAvailabilityResult.error(String error) {
    return ExportAvailabilityResult._(
      isAvailable: false,
      error: error,
    );
  }

  bool get hasError => error != null;

  Duration? get timeUntilNextExport {
    if (nextAvailableDate == null) return null;
    final now = DateTime.now();
    if (nextAvailableDate!.isBefore(now)) return null;
    return nextAvailableDate!.difference(now);
  }
}
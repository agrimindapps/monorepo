import '../../../../core/validation/input_sanitizer.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../notifiers/maintenance_form_state.dart';

/// Helper class for building MaintenanceEntity from form state
///
/// Responsibilities:
/// - Sanitizing form inputs
/// - Parsing formatted values
/// - Building entity with proper defaults
class MaintenanceEntityBuilder {
  const MaintenanceEntityBuilder();

  /// Builds a MaintenanceEntity from form state and controller values
  MaintenanceEntity buildFromForm({
    required MaintenanceFormState state,
    required String title,
    required String description,
    required String cost,
    required String odometer,
    required String workshopName,
    required String workshopPhone,
    required String workshopAddress,
    required String nextOdometer,
    required String notes,
  }) {
    final sanitizedTitle = InputSanitizer.sanitize(title);
    final sanitizedDescription = InputSanitizer.sanitizeDescription(description);
    final sanitizedWorkshopName = InputSanitizer.sanitizeName(workshopName);
    final sanitizedWorkshopPhone = InputSanitizer.sanitize(workshopPhone);
    final sanitizedWorkshopAddress = InputSanitizer.sanitize(workshopAddress);
    final sanitizedNotes = InputSanitizer.sanitizeDescription(notes);

    final parsedCost = _parseNumericValue(cost);
    final parsedOdometer = _parseNumericValue(odometer);
    final parsedNextOdometer = nextOdometer.isNotEmpty
        ? _parseNumericValue(nextOdometer)
        : null;

    final now = DateTime.now();
    final allPhotosPaths = [
      ...state.photosPaths,
      if (state.receiptImagePath != null) state.receiptImagePath!,
    ];

    return MaintenanceEntity(
      id: state.id.isEmpty ? now.millisecondsSinceEpoch.toString() : state.id,
      vehicleId: state.vehicleId,
      userId: state.userId,
      type: state.type,
      status: state.status,
      title: sanitizedTitle,
      description: sanitizedDescription,
      cost: parsedCost,
      odometer: parsedOdometer,
      workshopName: _nullIfEmpty(sanitizedWorkshopName),
      workshopPhone: _nullIfEmpty(sanitizedWorkshopPhone),
      workshopAddress: _nullIfEmpty(sanitizedWorkshopAddress),
      serviceDate: state.serviceDate ?? now,
      nextServiceDate: state.nextServiceDate,
      nextServiceOdometer: parsedNextOdometer,
      photosPaths: allPhotosPaths,
      invoicesPaths: state.invoicesPaths,
      parts: state.parts,
      notes: _nullIfEmpty(sanitizedNotes),
      createdAt: state.id.isEmpty
          ? now
          : DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(state.id) ?? now.millisecondsSinceEpoch,
            ),
      updatedAt: now,
      metadata: const {},
    );
  }

  double _parseNumericValue(String value) {
    return double.tryParse(
          value
              .replaceAll(RegExp(r'[^\d,.]'), '')
              .replaceAll(',', '.'),
        ) ??
        0.0;
  }

  String? _nullIfEmpty(String value) {
    return value.isNotEmpty ? value : null;
  }
}

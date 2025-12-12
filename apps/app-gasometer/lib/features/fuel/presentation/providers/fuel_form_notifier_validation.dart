part of 'fuel_form_notifier.dart';

/// Extension for FuelFormNotifier validation methods
extension FuelFormNotifierValidation on FuelFormNotifier {
  /// Validates a single form field
  String? validateField(String field, String? value) {
    return _validatorHandler.validateField(
      field,
      value,
      tankCapacity: state.formModel.vehicle?.tankCapacity,
      currentOdometer: state.formModel.vehicle?.currentOdometer,
      lastRecordOdometer: state.lastOdometerReading,
    );
  }

  /// Validates the complete form
  /// Returns (isValid, firstErrorField)
  (bool, String?) validateForm() {
    final errors = _validatorHandler.validateCompleteForm(
      liters: litersController.text,
      pricePerLiter: pricePerLiterController.text,
      odometer: odometerController.text,
      fuelType: state.formModel.fuelType,
      date: state.formModel.date,
      gasStationName: gasStationController.text,
      notes: notesController.text,
      vehicle: state.formModel.vehicle,
      lastRecordOdometer: state.lastOdometerReading,
    );

    state = state.copyWith(formModel: state.formModel.copyWith(errors: errors));

    if (errors.isEmpty) return (true, null);

    const fieldPriority = [
      'liters',
      'pricePerLiter',
      'odometer',
      'fuelType',
      'gasStationName',
      'notes',
    ];

    for (final field in fieldPriority) {
      if (errors.containsKey(field)) return (false, field);
    }

    return (false, errors.keys.first);
  }
}

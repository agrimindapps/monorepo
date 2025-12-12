part of 'maintenance_form_notifier.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

/// Extension for validation-related methods of MaintenanceFormNotifier
extension MaintenanceFormNotifierValidation on MaintenanceFormNotifier {
  // Controller change handlers using validator handler
  void _onTitleChanged() {
    _validatorHandler.validateTitleWithDebounce(
      value: titleController.text,
      onSanitizedValue: (sanitized) {
        state = state
            .copyWith(title: sanitized, hasChanges: true)
            .clearFieldError('title');
      },
      onSuggestedType: (suggestedType) {
        if (suggestedType != null) {
          updateType(suggestedType);
        }
      },
      currentType: state.type,
    );
  }

  void _onDescriptionChanged() {
    _validatorHandler.validateDescriptionWithDebounce(
      value: descriptionController.text,
      onSanitizedValue: (sanitized) {
        state = state
            .copyWith(description: sanitized, hasChanges: true)
            .clearFieldError('description');
      },
    );
  }

  void _onCostChanged() {
    _validatorHandler.validateCostWithDebounce(
      value: costController.text,
      onParsedValue: (value) {
        state = state
            .copyWith(cost: value, hasChanges: true)
            .clearFieldError('cost');
      },
    );
  }

  void _onOdometerChanged() {
    _validatorHandler.validateOdometerWithDebounce(
      value: odometerController.text,
      onParsedValue: (value) {
        state = state
            .copyWith(odometer: value, hasChanges: true)
            .clearFieldError('odometer');
      },
    );
  }

  void _onWorkshopNameChanged() {
    final sanitized = _validatorHandler.sanitizeWorkshopName(
      workshopNameController.text,
    );
    state = state
        .copyWith(workshopName: sanitized, hasChanges: true)
        .clearFieldError('workshopName');
  }

  void _onWorkshopPhoneChanged() {
    final formatted = _validatorHandler.formatPhone(workshopPhoneController.text);
    _controllerManager.updatePhoneFormatted(formatted);
    state = state
        .copyWith(workshopPhone: formatted, hasChanges: true)
        .clearFieldError('workshopPhone');
  }

  void _onWorkshopAddressChanged() {
    final sanitized = _validatorHandler.sanitizeWorkshopAddress(
      workshopAddressController.text,
    );
    state = state
        .copyWith(workshopAddress: sanitized, hasChanges: true)
        .clearFieldError('workshopAddress');
  }

  void _onNextOdometerChanged() {
    final value = _validatorHandler.parseNextOdometer(
      nextOdometerController.text,
    );
    state = state
        .copyWith(
          nextServiceOdometer: value,
          hasChanges: true,
        )
        .clearFieldError('nextServiceOdometer');
  }

  void _onNotesChanged() {
    final sanitized = _validatorHandler.sanitizeNotes(notesController.text);
    state = state
        .copyWith(notes: sanitized, hasChanges: true)
        .clearFieldError('notes');
  }

  /// Limpa mensagem de erro
  void clearError() {
    state = state.clearError();
  }

  /// Limpa erro de imagem
  void clearImageError() {
    state = state.clearImageError();
  }

  /// Valida campo específico (para TextFormField)
  String? validateField(String field, String? value) {
    return _validatorHandler.validateField(
      field,
      value,
      type: state.type,
      currentOdometer: state.vehicle?.currentOdometer,
    );
  }

  /// Valida formulário completo
  bool validateForm() {
    debugPrint('[MAINTENANCE VALIDATION] Starting form validation...');

    final errors = _validatorHandler.validator.validateCompleteForm(
      type: state.type,
      title: titleController.text,
      description: descriptionController.text,
      cost: costController.text,
      odometer: odometerController.text,
      serviceDate: state.serviceDate,
      workshopName: workshopNameController.text,
      workshopPhone: workshopPhoneController.text,
      workshopAddress: workshopAddressController.text,
      nextServiceDate: state.nextServiceDate,
      nextServiceOdometer: nextOdometerController.text,
      notes: notesController.text,
      vehicle: state.vehicle,
    );

    debugPrint('[MAINTENANCE VALIDATION] Validation errors: $errors');
    debugPrint(
      '[MAINTENANCE VALIDATION] Form is ${errors.isEmpty ? "VALID" : "INVALID"}',
    );

    state = state.copyWith(fieldErrors: errors);
    return errors.isEmpty;
  }
}

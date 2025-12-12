part of 'fuel_form_notifier.dart';

/// Extension for FuelFormNotifier state management methods
extension FuelFormNotifierState on FuelFormNotifier {
  // Controller change handlers
  void _onLitersChanged() {
    _validatorHandler.validateLitersWithDebounce(
      value: litersController.text,
      onParsedValue: _updateLiters,
    );
  }

  void _onPricePerLiterChanged() {
    _validatorHandler.validatePriceWithDebounce(
      value: pricePerLiterController.text,
      onParsedValue: _updatePricePerLiter,
    );
  }

  void _onOdometerChanged() {
    _validatorHandler.validateOdometerWithDebounce(
      value: odometerController.text,
      onParsedValue: _updateOdometer,
    );
  }

  void _onGasStationChanged() {
    final sanitized =
        _validatorHandler.sanitizeGasStationName(gasStationController.text);
    _updateGasStationName(sanitized);
  }

  void _onGasStationBrandChanged() {
    final sanitized = _validatorHandler
        .sanitizeGasStationBrand(gasStationBrandController.text);
    _updateGasStationBrand(sanitized);
  }

  void _onNotesChanged() {
    final sanitized = _validatorHandler.sanitizeNotes(notesController.text);
    _updateNotes(sanitized);
  }

  // Internal state update methods
  void _updateLiters(double value) {
    if (state.formModel.liters == value) return;
    state = state.copyWith(
      formModel: state.formModel
          .copyWith(liters: value, hasChanges: true)
          .clearFieldError('liters'),
    );
    _calculateTotalPrice();
  }

  void _updatePricePerLiter(double value) {
    if (state.formModel.pricePerLiter == value) return;
    state = state.copyWith(
      formModel: state.formModel
          .copyWith(pricePerLiter: value, hasChanges: true)
          .clearFieldError('pricePerLiter'),
    );
    _calculateTotalPrice();
  }

  void _updateOdometer(double value) {
    if (state.formModel.odometer == value) return;
    state = state.copyWith(
      formModel: state.formModel
          .copyWith(odometer: value, hasChanges: true)
          .clearFieldError('odometer'),
    );
  }

  void _updateGasStationName(String value) {
    if (state.formModel.gasStationName == value) return;
    state = state.copyWith(
      formModel: state.formModel
          .copyWith(gasStationName: value, hasChanges: true)
          .clearFieldError('gasStationName'),
    );
  }

  void _updateGasStationBrand(String value) {
    if (state.formModel.gasStationBrand == value) return;
    state = state.copyWith(
      formModel: state.formModel
          .copyWith(gasStationBrand: value, hasChanges: true)
          .clearFieldError('gasStationBrand'),
    );
  }

  void _updateNotes(String value) {
    if (state.formModel.notes == value) return;
    state = state.copyWith(
      formModel: state.formModel
          .copyWith(notes: value, hasChanges: true)
          .clearFieldError('notes'),
    );
  }

  // Public update methods
  /// Updates the fuel type
  void updateFuelType(FuelType fuelType) {
    if (state.formModel.fuelType == fuelType) return;
    state = state.copyWith(
      formModel: state.formModel
          .copyWith(fuelType: fuelType, hasChanges: true)
          .clearFieldError('fuelType'),
    );
  }

  /// Updates the fuel supply date
  void updateDate(DateTime date) {
    if (state.formModel.date == date) return;
    state = state.copyWith(
      formModel: state.formModel
          .copyWith(date: date, hasChanges: true)
          .clearFieldError('date'),
    );
  }

  /// Updates the full tank flag
  void updateFullTank(bool fullTank) {
    if (state.formModel.fullTank == fullTank) return;
    state = state.copyWith(
      formModel: state.formModel.copyWith(fullTank: fullTank, hasChanges: true),
    );
  }

  /// Calculates total price from liters and price per liter
  void _calculateTotalPrice() {
    if (state.isCalculating) return;
    state = state.copyWith(isCalculating: true);

    final total = _calculator.calculateTotalPrice(
      state.formModel.liters,
      state.formModel.pricePerLiter,
    );

    state = state.copyWith(
      formModel: state.formModel.copyWith(totalPrice: total),
      isCalculating: false,
    );
  }
}

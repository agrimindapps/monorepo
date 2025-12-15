part of 'fuel_form_notifier.dart';

/// Extension for FuelFormNotifier initialization methods
extension FuelFormNotifierInitialization on FuelFormNotifier {
  /// Initializes the form with optional vehicle and user IDs
  Future<void> initialize({String? vehicleId, String? userId}) async {
    try {
      final selectedVehicleId = vehicleId ?? state.formModel.vehicleId;

      if (selectedVehicleId.isEmpty) {
        throw Exception('Nenhum veículo selecionado');
      }

      final formModel =
          FuelFormModel.initial(selectedVehicleId, userId ?? '');
      // ignore: unawaited_futures
      Future.microtask(() {
        state = state.copyWith(formModel: formModel, isLoading: true);
      });

      await _loadVehicleData(selectedVehicleId);
      _setupControllers();
      _controllerManager.updateFromModel(state.formModel);

      state = state.copyWith(isInitialized: true, isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao inicializar formulário: $e');
      }
      state = state.copyWith(
        lastError: 'Erro ao inicializar: $e',
        isLoading: false,
      );
    }
  }

  /// Sets up controller listeners
  void _setupControllers() {
    if (_listenersSetup) return;

    _controllerManager.addListeners(
      onLitersChanged: _onLitersChanged,
      onPricePerLiterChanged: _onPricePerLiterChanged,
      onOdometerChanged: _onOdometerChanged,
      onGasStationChanged: _onGasStationChanged,
      onGasStationBrandChanged: _onGasStationBrandChanged,
      onNotesChanged: _onNotesChanged,
    );
    _listenersSetup = true;
  }

  /// Loads vehicle data from repository
  Future<void> _loadVehicleData(String vehicleId) async {
    try {
      final vehiclesNotifier = ref.read(vehiclesProvider.notifier);
      final vehicle = await vehiclesNotifier.getVehicleById(vehicleId);

      if (vehicle != null) {
        state = state.copyWith(
          formModel: state.formModel.copyWith(
            vehicle: vehicle,
            fuelType: vehicle.supportedFuels.isNotEmpty
                ? vehicle.supportedFuels.first
                : FuelType.gasoline,
          ),
          lastOdometerReading: vehicle.currentOdometer,
        );
      } else {
        throw Exception('Veículo não encontrado');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao carregar dados do veículo: $e');
      }
      state = state.copyWith(lastError: 'Erro ao carregar veículo: $e');
    }
  }

  /// Loads form from existing fuel record
  Future<void> loadFromFuelRecord(FuelRecordEntity record) async {
    try {
      state = state.copyWith(formModel: FuelFormModel.fromFuelRecord(record));
      await _loadVehicleData(record.vehicleId);
      _controllerManager.updateFromModel(state.formModel);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao carregar registro: $e');
      }
      state = state.copyWith(lastError: 'Erro ao carregar registro: $e');
    }
  }

  /// Clears all form fields and state
  void clearForm() {
    _controllerManager.clearAll();
    state = state.copyWith(
      formModel: FuelFormModel.initial(
        state.formModel.vehicleId,
        state.formModel.userId,
      ),
      clearImagePaths: true,
      clearImageError: true,
    );
  }

  /// Resets form to initial state
  void resetForm() {
    clearForm();
    state = state.copyWith(
      formModel: state.formModel.copyWith(
        hasChanges: false,
        errors: const {},
        lastError: null,
      ),
      clearError: true,
    );
  }
}

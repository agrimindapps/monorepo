import 'package:flutter/foundation.dart';
import '../../domain/entities/odometer_entity.dart';
import '../../data/repositories/odometer_repository.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../services/odometer_validation_service.dart';
import '../constants/odometer_constants.dart';

/// Provider for managing odometer records operations
///
/// This provider handles CRUD operations for odometer records and integrates
/// with the vehicles provider to maintain data consistency.
class OdometerProvider extends ChangeNotifier {
  final OdometerRepository _repository;
  final VehiclesProvider _vehiclesProvider;
  final OdometerValidationService _validationService;

  // Internal state
  final List<OdometerEntity> _odometers = [];
  bool _isLoading = false;
  String _error = '';

  OdometerProvider(
    this._repository,
    this._vehiclesProvider,
  ) : _validationService = OdometerValidationService(_vehiclesProvider) {
    _initialize();
  }

  /// Inicializa o provider
  Future<void> _initialize() async {
    await _repository.initialize();
    await loadOdometers();
  }

  // ===========================================
  // GETTERS
  // ===========================================

  List<OdometerEntity> get odometers => List.unmodifiable(_odometers);
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

  /// Gets odometers for a specific vehicle
  List<OdometerEntity> getOdometersByVehicle(String vehicleId) {
    return _odometers.where((o) => o.vehicleId == vehicleId).toList();
  }

  /// Gets the latest odometer reading for a vehicle
  OdometerEntity? getLatestOdometerForVehicle(String vehicleId) {
    final vehicleOdometers = getOdometersByVehicle(vehicleId);
    if (vehicleOdometers.isEmpty) return null;
    
    vehicleOdometers.sort((a, b) => b.registrationDate.compareTo(a.registrationDate));
    return vehicleOdometers.first;
  }

  // ===========================================
  // LOADING OPERATIONS
  // ===========================================

  /// Loads all odometer records
  Future<void> loadOdometers() async {
    _setLoading(true);
    _setError('');

    try {
      final odometers = await _repository.getAllOdometerReadings();
      _odometers.clear();
      _odometers.addAll(odometers);
      
    } catch (e) {
      debugPrint('Error loading odometers: $e');
      _setError(OdometerConstants.errorMessages['carregarOdometros']!);
    } finally {
      _setLoading(false);
    }
  }

  /// Loads odometers for a specific vehicle
  Future<void> loadOdometersByVehicle(String vehicleId) async {
    _setLoading(true);
    _setError('');

    try {
      final odometers = await _repository.getOdometerReadingsByVehicle(vehicleId);
      _odometers.removeWhere((o) => o.vehicleId == vehicleId);
      _odometers.addAll(odometers);
      
    } catch (e) {
      debugPrint('Error loading odometers for vehicle $vehicleId: $e');
      _setError(OdometerConstants.errorMessages['carregarOdometros']!);
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================
  // CRUD OPERATIONS
  // ===========================================

  /// Adds a new odometer record
  Future<bool> addOdometer(OdometerEntity odometer) async {
    _setLoading(true);
    _setError('');

    try {
      // Validate with context
      final validationResult = await _validationService.validateOdometerWithContext(
        vehicleId: odometer.vehicleId,
        odometerValue: odometer.value,
      );

      if (!validationResult.isValid) {
        _setError(validationResult.errorMessage!);
        return false;
      }

      final savedOdometer = await _repository.saveOdometerReading(odometer);
      if (savedOdometer == null) {
        _setError(OdometerConstants.errorMessages['salvarOdometro']!);
        return false;
      }
      
      // Update local state
      _odometers.add(savedOdometer);

      // Update vehicle's current odometer if this is the latest reading
      await _updateVehicleOdometer(odometer);

      debugPrint('Odometer record added successfully: ${odometer.id}');
      return true;

    } catch (e) {
      debugPrint('Error adding odometer: $e');
      _setError(OdometerConstants.errorMessages['salvarOdometro']!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing odometer record
  Future<bool> updateOdometer(OdometerEntity odometer) async {
    _setLoading(true);
    _setError('');

    try {
      // Validate with context (for editing)
      final validationResult = await _validationService.validateOdometerWithContext(
        vehicleId: odometer.vehicleId,
        odometerValue: odometer.value,
        currentOdometerId: odometer.id,
      );

      if (!validationResult.isValid) {
        _setError(validationResult.errorMessage!);
        return false;
      }

      final updatedOdometer = await _repository.updateOdometerReading(odometer);
      if (updatedOdometer == null) {
        _setError(OdometerConstants.errorMessages['atualizarOdometro']!);
        return false;
      }

      // Update local state
      final index = _odometers.indexWhere((o) => o.id == odometer.id);
      if (index != -1) {
        _odometers[index] = updatedOdometer;
      }

      // Update vehicle's current odometer if necessary
      await _updateVehicleOdometer(odometer);

      debugPrint('Odometer record updated successfully: ${odometer.id}');
      return true;

    } catch (e) {
      debugPrint('Error updating odometer: $e');
      _setError(OdometerConstants.errorMessages['atualizarOdometro']!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes an odometer record
  Future<bool> deleteOdometer(String odometerId) async {
    _setLoading(true);
    _setError('');

    try {
      final success = await _repository.deleteOdometerReading(odometerId);
      if (!success) {
        _setError(OdometerConstants.errorMessages['excluirOdometro']!);
        return false;
      }

      // Update local state
      final removedOdometer = _odometers.firstWhere((o) => o.id == odometerId);
      _odometers.removeWhere((o) => o.id == odometerId);

      // Recalculate vehicle's current odometer
      await _recalculateVehicleOdometer(removedOdometer.vehicleId);

      debugPrint('Odometer record deleted successfully: $odometerId');
      return true;

    } catch (e) {
      debugPrint('Error deleting odometer: $e');
      _setError(OdometerConstants.errorMessages['excluirOdometro']!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================
  // VEHICLE INTEGRATION
  // ===========================================

  /// Updates the vehicle's current odometer reading
  Future<void> _updateVehicleOdometer(OdometerEntity odometer) async {
    try {
      final vehicle = await _vehiclesProvider.getVehicleById(odometer.vehicleId);
      if (vehicle == null) return;

      // Check if this is the latest reading for the vehicle
      final latestOdometer = getLatestOdometerForVehicle(odometer.vehicleId);
      if (latestOdometer?.id == odometer.id && odometer.value > vehicle.currentOdometer) {
        // Update vehicle's current odometer
        final updatedVehicle = vehicle.copyWith(
          currentOdometer: odometer.value,
          updatedAt: DateTime.now(),
        );
        
        await _vehiclesProvider.updateVehicle(updatedVehicle);
        debugPrint('Updated vehicle ${vehicle.id} current odometer to ${odometer.value}');
      }
    } catch (e) {
      debugPrint('Error updating vehicle odometer: $e');
      // Don't throw error here, as the odometer operation was successful
    }
  }

  /// Recalculates the vehicle's current odometer after deletion
  Future<void> _recalculateVehicleOdometer(String vehicleId) async {
    try {
      final vehicle = await _vehiclesProvider.getVehicleById(vehicleId);
      if (vehicle == null) return;

      final latestOdometer = getLatestOdometerForVehicle(vehicleId);
      final newCurrentOdometer = latestOdometer?.value ?? vehicle.currentOdometer;

      if (newCurrentOdometer != vehicle.currentOdometer) {
        final updatedVehicle = vehicle.copyWith(
          currentOdometer: newCurrentOdometer,
          updatedAt: DateTime.now(),
        );
        
        await _vehiclesProvider.updateVehicle(updatedVehicle);
        debugPrint('Recalculated vehicle $vehicleId current odometer to $newCurrentOdometer');
      }
    } catch (e) {
      debugPrint('Error recalculating vehicle odometer: $e');
    }
  }

  // ===========================================
  // HELPER METHODS
  // ===========================================

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setError(String value) {
    if (_error != value) {
      _error = value;
      notifyListeners();
    }
  }

  void clearError() {
    _setError('');
  }

  /// Gets validation service for external use
  OdometerValidationService get validationService => _validationService;

  /// Gets statistics for a vehicle using repository
  Future<Map<String, dynamic>> getVehicleOdometerStats(String vehicleId) async {
    try {
      return await _repository.getVehicleStats(vehicleId);
    } catch (e) {
      debugPrint('Error getting vehicle stats: $e');
      return {
        'totalRecords': 0,
        'currentOdometer': 0.0,
        'firstReading': null,
        'lastReading': null,
        'totalDistance': 0.0,
      };
    }
  }

  /// Busca leituras por texto
  Future<List<OdometerEntity>> searchOdometerReadings(String query) async {
    try {
      return await _repository.searchOdometerReadings(query);
    } catch (e) {
      debugPrint('Error searching odometer readings: $e');
      return [];
    }
  }

  /// Carrega leituras por período
  Future<List<OdometerEntity>> getOdometerReadingsByPeriod(DateTime start, DateTime end) async {
    try {
      return await _repository.getOdometerReadingsByPeriod(start, end);
    } catch (e) {
      debugPrint('Error loading odometer readings by period: $e');
      return [];
    }
  }

  /// Carrega leituras por tipo
  Future<List<OdometerEntity>> getOdometerReadingsByType(OdometerType type) async {
    try {
      return await _repository.getOdometerReadingsByType(type);
    } catch (e) {
      debugPrint('Error loading odometer readings by type: $e');
      return [];
    }
  }

  /// Busca duplicatas
  Future<List<OdometerEntity>> findDuplicateReadings() async {
    try {
      return await _repository.findDuplicates();
    } catch (e) {
      debugPrint('Error finding duplicates: $e');
      return [];
    }
  }

  /// Limpa todas as leituras (apenas debug)
  Future<void> clearAllReadings() async {
    try {
      await _repository.clearAllOdometerReadings();
      _odometers.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing all readings: $e');
    }
  }
}
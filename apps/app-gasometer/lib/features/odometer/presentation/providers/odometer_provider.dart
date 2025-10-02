import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/providers/base_provider.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../data/repositories/odometer_repository.dart';
import '../../domain/entities/odometer_entity.dart';
import '../../domain/usecases/add_odometer_reading.dart';
import '../../domain/usecases/delete_odometer_reading.dart';
import '../../domain/usecases/get_all_odometer_readings.dart';
import '../../domain/usecases/get_odometer_readings_by_vehicle.dart';
import '../../domain/usecases/update_odometer_reading.dart';
import '../services/odometer_validation_service.dart';

/// Provider for managing odometer records operations
///
/// This provider handles CRUD operations for odometer records and integrates
/// with the vehicles provider to maintain data consistency.
@injectable
class OdometerProvider extends BaseProvider {

  OdometerProvider(
    this._getAllOdometerReadingsUseCase,
    this._getOdometerReadingsByVehicleUseCase,
    this._addOdometerReadingUseCase,
    this._updateOdometerReadingUseCase,
    this._deleteOdometerReadingUseCase,
    this._repository,
    this._vehiclesProvider,
  ) : _validationService = OdometerValidationService(_vehiclesProvider) {
    _initialize();
  }

  final GetAllOdometerReadingsUseCase _getAllOdometerReadingsUseCase;
  final GetOdometerReadingsByVehicleUseCase _getOdometerReadingsByVehicleUseCase;
  final AddOdometerReadingUseCase _addOdometerReadingUseCase;
  final UpdateOdometerReadingUseCase _updateOdometerReadingUseCase;
  final DeleteOdometerReadingUseCase _deleteOdometerReadingUseCase;
  final OdometerRepository _repository;
  final VehiclesProvider _vehiclesProvider;
  final OdometerValidationService _validationService;

  // Internal state
  List<OdometerEntity> _odometers = [];

  /// Initializes the provider
  Future<void> _initialize() async {
    await _repository.initialize();
    await loadOdometers();
  }

  // ===========================================
  // GETTERS
  // ===========================================

  List<OdometerEntity> get odometers => List.unmodifiable(_odometers);

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
    await executeListOperation(
      () async {
        final result = await _getAllOdometerReadingsUseCase(NoParams());
        return result.fold(
          (failure) => throw failure,
          (odometers) => odometers,
        );
      },
      operationName: 'loadOdometers',
      onSuccess: (odometers) {
        _odometers = odometers;
      },
    );
  }

  /// Alias for loadOdometers for backward compatibility
  Future<void> loadOdometerReadings() async {
    await loadOdometers();
  }

  /// Loads odometers for a specific vehicle
  Future<void> loadOdometersByVehicle(String vehicleId) async {
    await executeListOperation(
      () async {
        final result = await _getOdometerReadingsByVehicleUseCase(vehicleId);
        return result.fold(
          (failure) => throw failure,
          (odometers) => odometers,
        );
      },
      operationName: 'loadOdometersByVehicle',
      onSuccess: (odometers) {
        _odometers.removeWhere((o) => o.vehicleId == vehicleId);
        _odometers.addAll(odometers);
      },
    );
  }

  // ===========================================
  // CRUD OPERATIONS
  // ===========================================

  /// Adds a new odometer record
  Future<bool> addOdometer(OdometerEntity odometer) async {
    // Validate with context first
    final validationResult = await _validationService.validateOdometerWithContext(
      vehicleId: odometer.vehicleId,
      odometerValue: odometer.value,
    );

    if (!validationResult.isValid) {
      final error = ValidationError(
        message: 'Odometer validation failed',
        userFriendlyMessage: validationResult.errorMessage ?? 'Erro de validação',
      );
      logError(error);
      setState(ProviderState.error, error: error);
      return false;
    }

    return await executeDataOperation(
      () async {
        final result = await _addOdometerReadingUseCase(odometer);
        return result.fold(
          (failure) => throw failure,
          (savedOdometer) => savedOdometer,
        );
      },
      operationName: 'addOdometer',
      onSuccess: (savedOdometer) async {
        if (savedOdometer != null) {
          _odometers.add(savedOdometer);
          // Update vehicle's current odometer if this is the latest reading
          await _updateVehicleOdometer(odometer);
          debugPrint('Odometer record added successfully: ${odometer.id}');
        }
      },
    ).then((result) => result != null);
  }

  /// Updates an existing odometer record
  Future<bool> updateOdometer(OdometerEntity odometer) async {
    // Validate with context first (for editing)
    final validationResult = await _validationService.validateOdometerWithContext(
      vehicleId: odometer.vehicleId,
      odometerValue: odometer.value,
      currentOdometerId: odometer.id,
    );

    if (!validationResult.isValid) {
      final error = ValidationError(
        message: 'Odometer validation failed',
        userFriendlyMessage: validationResult.errorMessage ?? 'Erro de validação',
      );
      logError(error);
      setState(ProviderState.error, error: error);
      return false;
    }

    return await executeDataOperation(
      () async {
        final result = await _updateOdometerReadingUseCase(odometer);
        return result.fold(
          (failure) => throw failure,
          (updatedOdometer) => updatedOdometer,
        );
      },
      operationName: 'updateOdometer',
      onSuccess: (updatedOdometer) async {
        if (updatedOdometer != null) {
          final index = _odometers.indexWhere((o) => o.id == odometer.id);
          if (index != -1) {
            _odometers[index] = updatedOdometer;
          }
          // Update vehicle's current odometer if necessary
          await _updateVehicleOdometer(odometer);
          debugPrint('Odometer record updated successfully: ${odometer.id}');
        }
      },
    ).then((result) => result != null);
  }

  /// Deletes an odometer record
  Future<bool> deleteOdometer(String odometerId) async {
    // Get the odometer before deletion for vehicle update
    final removedOdometer = _odometers.cast<OdometerEntity?>().firstWhere(
      (o) => o?.id == odometerId,
      orElse: () => null,
    );

    return await executeDataOperation(
      () async {
        final result = await _deleteOdometerReadingUseCase(odometerId);
        return result.fold(
          (failure) => throw failure,
          (success) => success,
        );
      },
      operationName: 'deleteOdometer',
      onSuccess: (success) async {
        if (success && removedOdometer != null) {
          _odometers.removeWhere((o) => o.id == odometerId);
          // Recalculate vehicle's current odometer
          await _recalculateVehicleOdometer(removedOdometer.vehicleId);
          debugPrint('Odometer record deleted successfully: $odometerId');
        }
      },
    ).then((result) => result == true);
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

  /// Searches readings by text
  Future<List<OdometerEntity>> searchOdometerReadings(String query) async {
    try {
      return await _repository.searchOdometerReadings(query);
    } catch (e) {
      debugPrint('Error searching odometer readings: $e');
      return [];
    }
  }

  /// Loads readings by period
  Future<List<OdometerEntity>> getOdometerReadingsByPeriod(DateTime start, DateTime end) async {
    try {
      return await _repository.getOdometerReadingsByPeriod(start, end);
    } catch (e) {
      debugPrint('Error loading odometer readings by period: $e');
      return [];
    }
  }

  /// Loads readings by type
  Future<List<OdometerEntity>> getOdometerReadingsByType(OdometerType type) async {
    try {
      return await _repository.getOdometerReadingsByType(type);
    } catch (e) {
      debugPrint('Error loading odometer readings by type: $e');
      return [];
    }
  }

  /// Finds duplicates
  Future<List<OdometerEntity>> findDuplicateReadings() async {
    try {
      return await _repository.findDuplicates();
    } catch (e) {
      debugPrint('Error finding duplicates: $e');
      return [];
    }
  }

  /// Clears all readings (debug only)
  Future<void> clearAllReadings() async {
    try {
      await _repository.clearAllOdometerReadings();
      _odometers.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing all readings: $e');
    }
  }

  /// Converts a Map to OdometerEntity with validation
  /// 
  /// This method provides a safe conversion with proper error handling
  /// and validation, following Clean Architecture principles
  Future<OdometerEntity?> convertMapToEntity(Map<String, dynamic> map) async {
    try {
      // Validar estrutura básica do map
      if (!map.containsKey('id') || map['id'] == null || map['id'].toString().isEmpty) {
        debugPrint('Invalid odometer data: missing or empty id');
        return null;
      }

      // Validar campos obrigatórios
      final requiredFields = ['vehicleId', 'userId', 'value', 'date'];
      for (final field in requiredFields) {
        if (!map.containsKey(field) || map[field] == null) {
          debugPrint('Invalid odometer data: missing required field $field');
          return null;
        }
      }

      // Converter com validação de tipos
      final entity = OdometerEntity.fromMap(map);
      
      // Validar regras de negócio usando o service
      final validationResult = await _validationService.validateOdometerReading(
        entity.vehicleId,
        entity.value,
        context: 'editing',
      );
      
      if (!validationResult.isValid) {
        debugPrint('Odometer validation failed: ${validationResult.errorMessage}');
        // Retorna entity mesmo com validation error para permitir edição
        // mas registra o warning
      }
      
      return entity;
    } catch (e) {
      debugPrint('Error converting map to OdometerEntity: $e');
      return null;
    }
  }
}
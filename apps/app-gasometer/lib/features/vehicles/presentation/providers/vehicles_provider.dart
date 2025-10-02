import 'dart:async';

import 'package:core/core.dart' hide ValidationError;
import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/providers/base_provider.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/usecases/add_vehicle.dart';
import '../../domain/usecases/delete_vehicle.dart';
import '../../domain/usecases/get_all_vehicles.dart';
import '../../domain/usecases/get_vehicle_by_id.dart';
import '../../domain/usecases/search_vehicles.dart';
import '../../domain/usecases/update_vehicle.dart';
import '../../domain/usecases/watch_vehicles.dart';
import '../services/vehicle_filters_service.dart';
import '../services/vehicle_formatter_service.dart';
import '../services/vehicle_validation_service.dart';

/// Provider for managing vehicles operations
///
/// This provider handles CRUD operations for vehicles and integrates
/// real-time updates through streams.
@injectable
class VehiclesProvider extends BaseProvider {
  VehiclesProvider({
    required GetAllVehicles getAllVehicles,
    required GetVehicleById getVehicleById,
    required AddVehicle addVehicle,
    required UpdateVehicle updateVehicle,
    required DeleteVehicle deleteVehicle,
    required SearchVehicles searchVehicles,
    required WatchVehicles watchVehicles,
  })  : _getAllVehicles = getAllVehicles,
        _getVehicleById = getVehicleById,
        _addVehicle = addVehicle,
        _updateVehicle = updateVehicle,
        _deleteVehicle = deleteVehicle,
        _searchVehicles = searchVehicles,
        _watchVehicles = watchVehicles,
        _validationService = VehicleValidationService(),
        _formatterService = VehicleFormatterService(),
        _filtersService = VehicleFiltersService();

  // Use Cases
  final GetAllVehicles _getAllVehicles;
  final GetVehicleById _getVehicleById;
  final AddVehicle _addVehicle;
  final UpdateVehicle _updateVehicle;
  final DeleteVehicle _deleteVehicle;
  final SearchVehicles _searchVehicles;
  final WatchVehicles _watchVehicles;

  // Services
  final VehicleValidationService _validationService;
  final VehicleFormatterService _formatterService;
  final VehicleFiltersService _filtersService;

  // Internal state
  List<VehicleEntity> _vehicles = [];
  bool _isInitialized = false;
  StreamSubscription<Either<Failure, List<VehicleEntity>>>? _vehicleSubscription;

  // ===========================================
  // GETTERS
  // ===========================================

  List<VehicleEntity> get vehicles => List.unmodifiable(_vehicles);
  List<VehicleEntity> get activeVehicles => _filtersService.filterActive(_vehicles);
  bool get isInitialized => _isInitialized;
  bool get hasVehicles => _vehicles.isNotEmpty;
  int get vehicleCount => _vehicles.length;
  int get activeVehicleCount => activeVehicles.length;

  // Service getters for external use
  VehicleValidationService get validationService => _validationService;
  VehicleFormatterService get formatterService => _formatterService;
  VehicleFiltersService get filtersService => _filtersService;

  // ===========================================
  // INITIALIZATION
  // ===========================================

  /// Initializes the provider by loading vehicles and starting stream
  Future<void> initialize() async {
    if (_isInitialized) return;

    await executeListOperation(
      () async => await loadVehicles(),
      operationName: 'initialize',
      onSuccess: (_) {
        _startWatchingVehicles();
        _isInitialized = true;
        logInfo('VehiclesProvider initialized successfully');
      },
    );
  }

  /// Starts watching vehicles stream for real-time updates
  void _startWatchingVehicles() {
    _vehicleSubscription?.cancel();
    _vehicleSubscription = _watchVehicles().listen(
      (result) {
        result.fold(
          (failure) {
            if (!_isInitialized) {
              debugPrint('Error in vehicle stream: ${failure.message}');
              final error = ValidationError(message: failure.message);
              setState(ProviderState.error, error: error);
            }
          },
          (vehicles) {
            _vehicles = vehicles;
            setState(ProviderState.loaded);
            notifyListeners();
          },
        );
      },
      onError: (Object error) {
        if (!_isInitialized) {
          debugPrint('Error in vehicle stream: $error');
          final appError = ValidationError(message: error.toString());
          setState(ProviderState.error, error: appError);
        }
      },
    );
  }

  // ===========================================
  // LOADING OPERATIONS
  // ===========================================

  /// Loads all vehicles
  Future<List<VehicleEntity>> loadVehicles() async {
    return await executeListOperation(
      () async {
        final result = await _getAllVehicles();
        return result.fold(
          (failure) => throw failure,
          (vehicles) => vehicles,
        );
      },
      operationName: 'loadVehicles',
      onSuccess: (vehicles) {
        _vehicles = vehicles;
        logInfo('Loaded ${vehicles.length} vehicles');
      },
    ).then((vehicles) => vehicles ?? []);
  }

  // ===========================================
  // CRUD OPERATIONS
  // ===========================================

  /// Adds a new vehicle
  Future<bool> addVehicle(VehicleEntity vehicle) async {
    // Validate first
    final errors = _validationService.validateForAdd(vehicle, _vehicles);
    if (errors.isNotEmpty) {
      final errorMsg = errors.values.first;
      setState(
        ProviderState.error,
        error: ValidationError(message: errorMsg),
      );
      return false;
    }

    return await executeDataOperation(
      () async {
        final result = await _addVehicle(AddVehicleParams(vehicle: vehicle))
            .timeout(const Duration(seconds: 30));

        return result.fold(
          (failure) => throw failure,
          (addedVehicle) => addedVehicle,
        );
      },
      operationName: 'addVehicle',
      onSuccess: (addedVehicle) {
        _vehicles.add(addedVehicle);
        logInfo('Vehicle added successfully: ${addedVehicle.id}');
      },
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () async {
        setState(
          ProviderState.error,
          error: ValidationError(
            message: 'Operação expirou. Veículo pode ter sido salvo localmente.',
          ),
        );
        // Refresh to check if it was actually saved
        await loadVehicles();
        return null;
      },
    ).then((result) => result != null);
  }

  /// Updates an existing vehicle
  Future<bool> updateVehicle(VehicleEntity vehicle) async {
    // Validate first
    final errors = _validationService.validateForUpdate(vehicle, _vehicles);
    if (errors.isNotEmpty) {
      final errorMsg = errors.values.first;
      setState(
        ProviderState.error,
        error: ValidationError(message: errorMsg),
      );
      return false;
    }

    return await executeDataOperation(
      () async {
        final result = await _updateVehicle(UpdateVehicleParams(vehicle: vehicle));
        return result.fold(
          (failure) => throw failure,
          (updatedVehicle) => updatedVehicle,
        );
      },
      operationName: 'updateVehicle',
      onSuccess: (updatedVehicle) {
        final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
        if (index != -1) {
          _vehicles[index] = updatedVehicle;
        }
        logInfo('Vehicle updated successfully: ${updatedVehicle.id}');
      },
    ).then((result) => result != null);
  }

  /// Deletes a vehicle
  Future<bool> deleteVehicle(String vehicleId) async {
    return await executeDataOperation(
      () async {
        final result = await _deleteVehicle(DeleteVehicleParams(vehicleId: vehicleId));
        return result.fold(
          (failure) => throw failure,
          (_) => true,
        );
      },
      operationName: 'deleteVehicle',
      onSuccess: (_) {
        _vehicles.removeWhere((v) => v.id == vehicleId);
        logInfo('Vehicle deleted successfully: $vehicleId');
      },
    ).then((result) => result == true);
  }

  // ===========================================
  // QUERY OPERATIONS
  // ===========================================

  /// Gets a vehicle by ID
  Future<VehicleEntity?> getVehicleById(String vehicleId) async {
    final result = await _getVehicleById(GetVehicleByIdParams(vehicleId: vehicleId));

    return result.fold(
      (failure) {
        debugPrint('Error getting vehicle by ID: ${failure.message}');
        return null;
      },
      (vehicle) => vehicle,
    );
  }

  /// Searches vehicles by query
  Future<List<VehicleEntity>> searchVehicles(String query) async {
    final result = await _searchVehicles(SearchVehiclesParams(query: query));

    return result.fold(
      (failure) {
        debugPrint('Error searching vehicles: ${failure.message}');
        return <VehicleEntity>[];
      },
      (vehicles) => vehicles,
    );
  }

  // ===========================================
  // FILTER OPERATIONS (Using Service)
  // ===========================================

  /// Gets vehicles by type
  List<VehicleEntity> getVehiclesByType(VehicleType type) {
    return _filtersService.filterByType(_vehicles, type);
  }

  /// Gets vehicles by fuel type
  List<VehicleEntity> getVehiclesByFuelType(FuelType fuelType) {
    return _filtersService.filterByFuelType(_vehicles, fuelType);
  }

  /// Searches vehicles locally (using service)
  List<VehicleEntity> searchVehiclesLocal(String query) {
    return _filtersService.searchVehicles(_vehicles, query);
  }

  /// Sorts vehicles by name
  List<VehicleEntity> sortByName({bool ascending = true}) {
    return _filtersService.sortByName(_vehicles, ascending: ascending);
  }

  /// Sorts vehicles by brand/model
  List<VehicleEntity> sortByBrandModel({bool ascending = true}) {
    return _filtersService.sortByBrandModel(_vehicles, ascending: ascending);
  }

  /// Sorts vehicles by year
  List<VehicleEntity> sortByYear({bool ascending = true}) {
    return _filtersService.sortByYear(_vehicles, ascending: ascending);
  }

  // ===========================================
  // CLEANUP
  // ===========================================

  @override
  void dispose() {
    _vehicleSubscription?.cancel();
    super.dispose();
  }
}

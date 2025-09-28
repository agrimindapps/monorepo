import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/usecases/add_vehicle.dart';
import '../../domain/usecases/delete_vehicle.dart';
import '../../domain/usecases/get_all_vehicles.dart';
import '../../domain/usecases/get_vehicle_by_id.dart';
import '../../domain/usecases/search_vehicles.dart';
import '../../domain/usecases/update_vehicle.dart';

@injectable
class VehiclesProvider extends ChangeNotifier {

  VehiclesProvider({
    required GetAllVehicles getAllVehicles,
    required GetVehicleById getVehicleById,
    required AddVehicle addVehicle,
    required UpdateVehicle updateVehicle,
    required DeleteVehicle deleteVehicle,
    required SearchVehicles searchVehicles,
    required VehicleRepository repository,
  })  : _getAllVehicles = getAllVehicles,
        _getVehicleById = getVehicleById,
        _addVehicle = addVehicle,
        _updateVehicle = updateVehicle,
        _deleteVehicle = deleteVehicle,
        _searchVehicles = searchVehicles,
        _repository = repository;
  final GetAllVehicles _getAllVehicles;
  final GetVehicleById _getVehicleById;
  final AddVehicle _addVehicle;
  final UpdateVehicle _updateVehicle;
  final DeleteVehicle _deleteVehicle;
  final SearchVehicles _searchVehicles;
  final VehicleRepository _repository;

  List<VehicleEntity> _vehicles = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  StreamSubscription<Either<Failure, List<VehicleEntity>>>?
      _vehicleSubscription;

  List<VehicleEntity> get vehicles => _vehicles;
  List<VehicleEntity> get activeVehicles =>
      _vehicles.where((v) => v.isActive).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get hasVehicles => _vehicles.isNotEmpty;
  int get vehicleCount => _vehicles.length;
  int get activeVehicleCount => activeVehicles.length;

  /// Inicializa o provider carregando os veículos.
  /// Deve ser chamado explicitamente após a criação do provider.
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _initialize();
  }

  Future<void> _initialize() async {
    try {
      await loadVehicles();
      _startWatchingVehicles();
    } catch (e) {
      _errorMessage = 'Erro ao inicializar: ${e.toString()}';
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  void _startWatchingVehicles() {
    _vehicleSubscription?.cancel();
    _vehicleSubscription = _repository.watchVehicles().listen(
      (result) {
        result.fold(
          (failure) {
            if (!_isInitialized) {
              _errorMessage = _mapFailureToMessage(failure);
              notifyListeners();
            }
          },
          (vehicles) {
            _vehicles = vehicles;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
        );
      },
      onError: (Object error) {
        if (!_isInitialized) {
          _errorMessage = 'Erro na sincronização: ${error.toString()}';
          _isLoading = false;
          notifyListeners();
        }
      },
    );
  }

  Future<void> loadVehicles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getAllVehicles();
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (vehicles) {
        _vehicles = vehicles;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Erro do servidor. Tente novamente mais tarde.';
    } else if (failure is NetworkFailure) {
      return 'Erro de conexão. Verifique sua internet.';
    } else if (failure is CacheFailure) {
      return 'Erro de cache local.';
    } else if (failure is VehicleNotFoundFailure) {
      return 'Veículo não encontrado.';
    } else {
      return 'Erro inesperado. Tente novamente.';
    }
  }

  Future<bool> addVehicle(VehicleEntity vehicle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Add timeout to prevent UI freeze from hanging operations
      final result = await _addVehicle(AddVehicleParams(vehicle: vehicle))
          .timeout(const Duration(seconds: 30));

      return result.fold(
        (failure) {
          _errorMessage = _mapFailureToMessage(failure);
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (addedVehicle) {
          _vehicles.add(addedVehicle);
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } on TimeoutException {
      _errorMessage =
          'Operação expirou. Veículo pode ter sido salvo localmente.';
      _isLoading = false;
      notifyListeners();
      // Refresh vehicles list to check if it was actually saved
      await loadVehicles();
      return false;
    } catch (e) {
      _errorMessage = 'Erro inesperado: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVehicle(VehicleEntity vehicle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateVehicle(UpdateVehicleParams(vehicle: vehicle));

    return result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (updatedVehicle) {
        final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
        if (index != -1) {
          _vehicles[index] = updatedVehicle;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result =
        await _deleteVehicle(DeleteVehicleParams(vehicleId: vehicleId));

    return result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        _vehicles.removeWhere((v) => v.id == vehicleId);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<VehicleEntity?> getVehicleById(String vehicleId) async {
    final result =
        await _getVehicleById(GetVehicleByIdParams(vehicleId: vehicleId));

    return result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return null;
      },
      (vehicle) => vehicle,
    );
  }

  Future<List<VehicleEntity>> searchVehicles(String query) async {
    final result = await _searchVehicles(SearchVehiclesParams(query: query));

    return result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return <VehicleEntity>[];
      },
      (vehicles) => vehicles,
    );
  }

  List<VehicleEntity> getVehiclesByType(VehicleType type) {
    return _vehicles.where((v) => v.type == type && v.isActive).toList();
  }

  List<VehicleEntity> getVehiclesByFuelType(FuelType fuelType) {
    return _vehicles
        .where((v) => v.supportedFuels.contains(fuelType) && v.isActive)
        .toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _vehicleSubscription?.cancel();
    super.dispose();
  }
}

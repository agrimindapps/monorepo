import 'dart:async';

import 'package:core/core.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/providers/auth_notifier.dart';
import '../../../../core/providers/base_notifier.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/usecases/add_vehicle.dart';
import '../../domain/usecases/delete_vehicle.dart';
import '../../domain/usecases/get_all_vehicles.dart';
import '../../domain/usecases/get_vehicle_by_id.dart';
import '../../domain/usecases/search_vehicles.dart';
import '../../domain/usecases/update_vehicle.dart';

/// Notifier para gerenciar estado de veículos com AsyncNotifier
/// Suporta stream watching, offline sync, CRUD completo e derived providers
class VehiclesNotifier extends BaseAsyncNotifier<List<VehicleEntity>> {
  VehiclesNotifier();

  StreamSubscription<Either<dynamic, List<VehicleEntity>>>? _vehicleSubscription;

  @override
  String get notifierName => 'VehiclesNotifier';

  @override
  Future<List<VehicleEntity>> build() async {
    // Limpar subscription anterior se existir
    _vehicleSubscription?.cancel();

    // Verificar autenticação
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      logInfo('User not authenticated, returning empty list');
      return [];
    }

    // Iniciar watch stream para atualizações em tempo real
    _startWatchingVehicles();

    // Carregar veículos iniciais
    logInfo('Loading initial vehicles for user: ${currentUser.id}');

    return await executeOperation(
      () async {
        final getAllVehicles = GetIt.instance<GetAllVehicles>();
        final result = await getAllVehicles();

        return result.fold(
          (failure) {
            final error = _mapFailureToError(failure);
            throw error;
          },
          (vehicles) {
            logInfo('Loaded ${vehicles.length} vehicles successfully');
            return vehicles;
          },
        );
      },
      operationName: 'build',
    );
  }

  /// Inicia watch stream para sincronização em tempo real
  void _startWatchingVehicles() {
    try {
      final repository = GetIt.instance<VehicleRepository>();

      _vehicleSubscription = repository.watchVehicles().listen(
        (result) {
          result.fold(
            (failure) {
              logWarning('Stream error: $failure');
              // Não atualizar estado em caso de erro de stream para evitar quebrar UI
            },
            (vehicles) {
              logInfo('Stream update: ${vehicles.length} vehicles');
              // Atualizar estado apenas se dados mudaram
              final currentData = state.valueOrNull;
              if (currentData == null || !_areListsEqual(currentData, vehicles)) {
                state = AsyncValue.data(vehicles);
              }
            },
          );
        },
        onError: (Object error) {
          logWarning('Stream subscription error: $error');
        },
      );
    } catch (e) {
      logWarning('Failed to start watching vehicles: $e');
    }
  }

  /// Compara duas listas de veículos
  bool _areListsEqual(List<VehicleEntity> list1, List<VehicleEntity> list2) {
    if (list1.length != list2.length) return false;

    for (var i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id ||
          list1[i].updatedAt != list2[i].updatedAt) {
        return false;
      }
    }

    return true;
  }

  /// Adiciona novo veículo
  Future<VehicleEntity> addVehicle(VehicleEntity vehicle) async {
    logInfo('Adding vehicle: ${vehicle.name}');

    final addedVehicle = await executeOperation(
      () async {
        final addVehicleUseCase = GetIt.instance<AddVehicle>();
        final result = await addVehicleUseCase(AddVehicleParams(vehicle: vehicle))
            .timeout(const Duration(seconds: 30));

        return result.fold(
          (failure) {
            final error = _mapFailureToError(failure);
            throw error;
          },
          (added) {
            logInfo('Vehicle added successfully: ${added.id}');
            return added;
          },
        );
      },
      operationName: 'addVehicle',
      parameters: {'vehicleName': vehicle.name},
    );

    // Atualizar lista local imediatamente
    final currentList = state.valueOrNull ?? [];
    state = AsyncValue.data([...currentList, addedVehicle]);

    return addedVehicle;
  }

  /// Atualiza veículo existente
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle) async {
    logInfo('Updating vehicle: ${vehicle.id}');

    final updatedVehicle = await executeOperation(
      () async {
        final updateVehicleUseCase = GetIt.instance<UpdateVehicle>();
        final result = await updateVehicleUseCase(UpdateVehicleParams(vehicle: vehicle));

        return result.fold(
          (failure) {
            final error = _mapFailureToError(failure);
            throw error;
          },
          (updated) {
            logInfo('Vehicle updated successfully: ${updated.id}');
            return updated;
          },
        );
      },
      operationName: 'updateVehicle',
      parameters: {'vehicleId': vehicle.id},
    );

    // Atualizar lista local imediatamente
    final currentList = state.valueOrNull ?? [];
    final updatedList = currentList.map((v) {
      return v.id == updatedVehicle.id ? updatedVehicle : v;
    }).toList();

    state = AsyncValue.data(updatedList);

    return updatedVehicle;
  }

  /// Remove veículo
  Future<void> deleteVehicle(String vehicleId) async {
    logInfo('Deleting vehicle: $vehicleId');

    await executeOperation(
      () async {
        final deleteVehicleUseCase = GetIt.instance<DeleteVehicle>();
        final result = await deleteVehicleUseCase(DeleteVehicleParams(vehicleId: vehicleId));

        return result.fold(
          (failure) {
            final error = _mapFailureToError(failure);
            throw error;
          },
          (_) {
            logInfo('Vehicle deleted successfully: $vehicleId');
            return null;
          },
        );
      },
      operationName: 'deleteVehicle',
      parameters: {'vehicleId': vehicleId},
    );

    // Atualizar lista local imediatamente
    final currentList = state.valueOrNull ?? [];
    final updatedList = currentList.where((v) => v.id != vehicleId).toList();
    state = AsyncValue.data(updatedList);
  }

  /// Busca veículo por ID
  Future<VehicleEntity?> getVehicleById(String vehicleId) async {
    logInfo('Getting vehicle by ID: $vehicleId');

    try {
      return await executeOperation(
        () async {
          final getVehicleByIdUseCase = GetIt.instance<GetVehicleById>();
          final result = await getVehicleByIdUseCase(GetVehicleByIdParams(vehicleId: vehicleId));

          return result.fold(
            (failure) {
              final error = _mapFailureToError(failure);
              throw error;
            },
            (vehicle) {
              logInfo('Vehicle found: ${vehicle.id}');
              return vehicle;
            },
          );
        },
        operationName: 'getVehicleById',
        parameters: {'vehicleId': vehicleId},
      );
    } catch (e) {
      logWarning('Failed to get vehicle by ID: $e');
      return null;
    }
  }

  /// Busca veículos por query
  Future<List<VehicleEntity>> searchVehicles(String query) async {
    logInfo('Searching vehicles: $query');

    try {
      return await executeOperation(
        () async {
          final searchVehiclesUseCase = GetIt.instance<SearchVehicles>();
          final result = await searchVehiclesUseCase(SearchVehiclesParams(query: query));

          return result.fold(
            (failure) {
              final error = _mapFailureToError(failure);
              throw error;
            },
            (vehicles) {
              logInfo('Found ${vehicles.length} vehicles matching query');
              return vehicles;
            },
          );
        },
        operationName: 'searchVehicles',
        parameters: {'query': query},
      );
    } catch (e) {
      logWarning('Search failed: $e');
      return [];
    }
  }

  /// Força refresh dos dados
  Future<void> refresh() async {
    logInfo('Refreshing vehicles');
    ref.invalidateSelf();
    await future;
  }

  /// Filtra veículos por tipo
  List<VehicleEntity> getVehiclesByType(VehicleType type) {
    final vehicles = state.valueOrNull ?? [];
    return vehicles.where((v) => v.type == type && v.isActive).toList();
  }

  /// Filtra veículos por tipo de combustível
  List<VehicleEntity> getVehiclesByFuelType(FuelType fuelType) {
    final vehicles = state.valueOrNull ?? [];
    return vehicles.where((v) => v.supportedFuels.contains(fuelType) && v.isActive).toList();
  }

  /// Mapeia Failure para AppError
  AppError _mapFailureToError(dynamic failure) {
    if (failure.toString().contains('network') || failure.toString().contains('connection')) {
      return NetworkError(
        message: 'Erro de conexão. Verifique sua internet.',
        technicalDetails: failure.toString(),
      );
    } else if (failure.toString().contains('server')) {
      return ServerError(
        message: 'Erro do servidor. Tente novamente mais tarde.',
        technicalDetails: failure.toString(),
      );
    } else if (failure.toString().contains('cache')) {
      return CacheError(
        message: 'Erro de cache local.',
        technicalDetails: failure.toString(),
      );
    } else if (failure.toString().contains('not found')) {
      return NotFoundError(
        message: 'Veículo não encontrado.',
        technicalDetails: failure.toString(),
      );
    } else {
      return UnexpectedError(
        message: 'Erro inesperado. Tente novamente.',
        technicalDetails: failure.toString(),
      );
    }
  }

  @override
  void dispose() {
    _vehicleSubscription?.cancel();
    super.dispose();
  }
}

// ============================================================================
// PROVIDERS DERIVADOS
// ============================================================================

/// Provider principal de veículos
final vehiclesNotifierProvider = AsyncNotifierProvider<VehiclesNotifier, List<VehicleEntity>>(() {
  return VehiclesNotifier();
});

/// Provider para veículo selecionado (ID)
final selectedVehicleIdProvider = StateProvider<String?>((ref) => null);

/// Provider para veículo selecionado (Entity)
final selectedVehicleProvider = Provider<VehicleEntity?>((ref) {
  final selectedId = ref.watch(selectedVehicleIdProvider);
  if (selectedId == null) return null;

  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  return vehiclesAsync.whenOrNull(
    data: (vehicles) {
      try {
        return vehicles.firstWhere((v) => v.id == selectedId);
      } catch (e) {
        return null;
      }
    },
  );
});

/// Provider para query de busca
final vehicleSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider para veículos filtrados por busca
final filteredVehiclesProvider = Provider<AsyncValue<List<VehicleEntity>>>((ref) {
  final query = ref.watch(vehicleSearchQueryProvider).toLowerCase().trim();
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);

  if (query.isEmpty) {
    return vehiclesAsync;
  }

  return vehiclesAsync.whenData(
    (vehicles) => vehicles.where((v) {
      final searchText = '${v.name} ${v.brand} ${v.model} ${v.licensePlate}'.toLowerCase();
      return searchText.contains(query);
    }).toList(),
  );
});

/// Provider para veículos ativos apenas
final activeVehiclesProvider = Provider<AsyncValue<List<VehicleEntity>>>((ref) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);

  return vehiclesAsync.whenData(
    (vehicles) => vehicles.where((v) => v.isActive).toList(),
  );
});

/// Provider para contagem de veículos
final vehicleCountProvider = Provider<int>((ref) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  return vehiclesAsync.valueOrNull?.length ?? 0;
});

/// Provider para contagem de veículos ativos
final activeVehicleCountProvider = Provider<int>((ref) {
  final activeVehiclesAsync = ref.watch(activeVehiclesProvider);
  return activeVehiclesAsync.valueOrNull?.length ?? 0;
});

/// Provider para verificar se há veículos
final hasVehiclesProvider = Provider<bool>((ref) {
  final count = ref.watch(vehicleCountProvider);
  return count > 0;
});

/// Provider para veículos por tipo
final vehiclesByTypeProvider = Provider.family<List<VehicleEntity>, VehicleType>((ref, type) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  final vehicles = vehiclesAsync.valueOrNull ?? [];
  return vehicles.where((v) => v.type == type && v.isActive).toList();
});

/// Provider para veículos por tipo de combustível
final vehiclesByFuelTypeProvider = Provider.family<List<VehicleEntity>, FuelType>((ref, fuelType) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  final vehicles = vehiclesAsync.valueOrNull ?? [];
  return vehicles.where((v) => v.supportedFuels.contains(fuelType) && v.isActive).toList();
});
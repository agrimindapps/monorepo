import 'dart:async';

import 'package:core/core.dart';

import '../../../../core/error/app_error.dart' as local_error;
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/base_notifier.dart' hide AsyncValueX;
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
    await _vehicleSubscription?.cancel();

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
            throw error as Object;
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
              final currentData = state.when(
                data: (data) => data,
                loading: () => null,
                error: (_, __) => null,
              );
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

    // Executar operação e obter veículo adicionado
    VehicleEntity? addedVehicle;

    await executeOperation(
      () async {
        final addVehicleUseCase = GetIt.instance<AddVehicle>();
        final result = await addVehicleUseCase(AddVehicleParams(vehicle: vehicle))
            .timeout(const Duration(seconds: 30));

        return result.fold(
          (failure) {
            final error = _mapFailureToError(failure);
            throw error as Object;
          },
          (added) {
            logInfo('Vehicle added successfully: ${added.id}');
            addedVehicle = added;

            // Atualizar lista local imediatamente
            final currentList = state.when(
              data: (data) => data,
              loading: () => <VehicleEntity>[],
              error: (_, __) => <VehicleEntity>[],
            );
            state = AsyncValue.data([...currentList, added]);

            return currentList; // Return list to satisfy executeOperation type
          },
        );
      },
      operationName: 'addVehicle',
      parameters: {'vehicleName': vehicle.name},
    );

    return addedVehicle!;
  }

  /// Atualiza veículo existente
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle) async {
    logInfo('Updating vehicle: ${vehicle.id}');

    // Executar operação e obter veículo atualizado
    VehicleEntity? updatedVehicle;

    await executeOperation(
      () async {
        final updateVehicleUseCase = GetIt.instance<UpdateVehicle>();
        final result = await updateVehicleUseCase(UpdateVehicleParams(vehicle: vehicle));

        return result.fold(
          (failure) {
            final error = _mapFailureToError(failure);
            throw error as Object;
          },
          (updated) {
            logInfo('Vehicle updated successfully: ${updated.id}');
            updatedVehicle = updated;

            // Atualizar lista local imediatamente
            final currentList = state.when(
              data: (data) => data,
              loading: () => <VehicleEntity>[],
              error: (_, __) => <VehicleEntity>[],
            );
            final updatedList = currentList.map((VehicleEntity v) {
              return v.id == updated.id ? updated : v;
            }).toList();

            state = AsyncValue.data(updatedList);

            return currentList; // Return list to satisfy executeOperation type
          },
        );
      },
      operationName: 'updateVehicle',
      parameters: {'vehicleId': vehicle.id},
    );

    return updatedVehicle!;
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
            throw error as Object;
          },
          (_) {
            logInfo('Vehicle deleted successfully: $vehicleId');

            // Atualizar lista local imediatamente
            final currentList = state.when(
              data: (data) => data,
              loading: () => <VehicleEntity>[],
              error: (_, __) => <VehicleEntity>[],
            );
            final updatedList = currentList.where((VehicleEntity v) => v.id != vehicleId).toList();
            state = AsyncValue.data(updatedList);

            return currentList; // Return list to satisfy executeOperation type
          },
        );
      },
      operationName: 'deleteVehicle',
      parameters: {'vehicleId': vehicleId},
    );
  }

  /// Busca veículo por ID
  Future<VehicleEntity?> getVehicleById(String vehicleId) async {
    logInfo('Getting vehicle by ID: $vehicleId');

    try {
      VehicleEntity? foundVehicle;

      await executeOperation(
        () async {
          final getVehicleByIdUseCase = GetIt.instance<GetVehicleById>();
          final result = await getVehicleByIdUseCase(GetVehicleByIdParams(vehicleId: vehicleId));

          return result.fold(
            (failure) {
              final error = _mapFailureToError(failure);
              throw error as Object;
            },
            (vehicle) {
              logInfo('Vehicle found: ${vehicle.id}');
              foundVehicle = vehicle;
              return state.when(
                data: (data) => data,
                loading: () => <VehicleEntity>[],
                error: (_, __) => <VehicleEntity>[],
              ); // Return list to satisfy executeOperation type
            },
          );
        },
        operationName: 'getVehicleById',
        parameters: {'vehicleId': vehicleId},
      );

      return foundVehicle;
    } catch (e) {
      logWarning('Failed to get vehicle by ID: $e');
      return null;
    }
  }

  /// Busca veículos por query
  Future<List<VehicleEntity>> searchVehicles(String query) async {
    logInfo('Searching vehicles: $query');

    try {
      List<VehicleEntity> searchResults = [];

      await executeOperation(
        () async {
          final searchVehiclesUseCase = GetIt.instance<SearchVehicles>();
          final result = await searchVehiclesUseCase(SearchVehiclesParams(query: query));

          return result.fold(
            (failure) {
              final error = _mapFailureToError(failure);
              throw error as Object;
            },
            (vehicles) {
              logInfo('Found ${vehicles.length} vehicles matching query');
              searchResults = vehicles;
              return state.when(
                data: (data) => data,
                loading: () => <VehicleEntity>[],
                error: (_, __) => <VehicleEntity>[],
              ); // Return list to satisfy executeOperation type
            },
          );
        },
        operationName: 'searchVehicles',
        parameters: {'query': query},
      );

      return searchResults;
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
    final vehicles = state.when(
      data: (data) => data,
      loading: () => <VehicleEntity>[],
      error: (_, __) => <VehicleEntity>[],
    );
    return vehicles.where((VehicleEntity v) => v.type == type && v.isActive).toList();
  }

  /// Filtra veículos por tipo de combustível
  List<VehicleEntity> getVehiclesByFuelType(FuelType fuelType) {
    final vehicles = state.when(
      data: (data) => data,
      loading: () => <VehicleEntity>[],
      error: (_, __) => <VehicleEntity>[],
    );
    return vehicles.where((VehicleEntity v) => v.supportedFuels.contains(fuelType) && v.isActive).toList();
  }

  /// Mapeia Failure para AppError
  local_error.AppError _mapFailureToError(dynamic failure) {
    if (failure.toString().contains('network') || failure.toString().contains('connection')) {
      return local_error.NetworkError(
        message: 'Erro de conexão. Verifique sua internet.',
        technicalDetails: failure.toString(),
      );
    } else if (failure.toString().contains('server')) {
      return local_error.ServerError(
        message: 'Erro do servidor. Tente novamente mais tarde.',
        technicalDetails: failure.toString(),
      );
    } else if (failure.toString().contains('cache')) {
      return local_error.CacheError(
        message: 'Erro de cache local.',
        technicalDetails: failure.toString(),
      );
    } else if (failure.toString().contains('not found')) {
      return local_error.NotFoundError(
        message: 'Veículo não encontrado.',
        technicalDetails: failure.toString(),
      );
    } else {
      return local_error.UnexpectedError(
        message: 'Erro inesperado. Tente novamente.',
        technicalDetails: failure.toString(),
      );
    }
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
  return vehiclesAsync.when(
    data: (List<VehicleEntity> vehicles) {
      try {
        return vehicles.firstWhere((VehicleEntity v) => v.id == selectedId);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
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

  return vehiclesAsync.when<AsyncValue<List<VehicleEntity>>>(
    data: (List<VehicleEntity> vehicles) => AsyncValue.data(
      vehicles.where((VehicleEntity v) {
        final searchText = '${v.name} ${v.brand} ${v.model} ${v.licensePlate}'.toLowerCase();
        return searchText.contains(query);
      }).toList(),
    ),
    loading: () => const AsyncValue<List<VehicleEntity>>.loading(),
    error: (Object error, StackTrace stack) => AsyncValue<List<VehicleEntity>>.error(error, stack),
  );
});

/// Provider para veículos ativos apenas
final activeVehiclesProvider = Provider<AsyncValue<List<VehicleEntity>>>((ref) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);

  return vehiclesAsync.when<AsyncValue<List<VehicleEntity>>>(
    data: (List<VehicleEntity> vehicles) => AsyncValue.data(
      vehicles.where((VehicleEntity v) => v.isActive).toList(),
    ),
    loading: () => const AsyncValue<List<VehicleEntity>>.loading(),
    error: (Object error, StackTrace stack) => AsyncValue<List<VehicleEntity>>.error(error, stack),
  );
});

/// Provider para contagem de veículos
final vehicleCountProvider = Provider<int>((ref) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  return vehiclesAsync.when<int>(
    data: (List<VehicleEntity> vehicles) => vehicles.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider para contagem de veículos ativos
final activeVehicleCountProvider = Provider<int>((ref) {
  final activeVehiclesAsync = ref.watch(activeVehiclesProvider);
  return activeVehiclesAsync.when<int>(
    data: (List<VehicleEntity> vehicles) => vehicles.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider para verificar se há veículos
final hasVehiclesProvider = Provider<bool>((ref) {
  final count = ref.watch(vehicleCountProvider);
  return count > 0;
});

/// Provider para veículos por tipo
final vehiclesByTypeProvider = Provider.family<List<VehicleEntity>, VehicleType>((ref, type) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  final vehicles = vehiclesAsync.when<List<VehicleEntity>>(
    data: (List<VehicleEntity> vehicles) => vehicles,
    loading: () => <VehicleEntity>[],
    error: (_, __) => <VehicleEntity>[],
  );
  return vehicles.where((VehicleEntity v) => v.type == type && v.isActive).toList();
});

/// Provider para veículos por tipo de combustível
final vehiclesByFuelTypeProvider = Provider.family<List<VehicleEntity>, FuelType>((ref, fuelType) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  final vehicles = vehiclesAsync.when<List<VehicleEntity>>(
    data: (List<VehicleEntity> vehicles) => vehicles,
    loading: () => <VehicleEntity>[],
    error: (_, __) => <VehicleEntity>[],
  );
  return vehicles.where((VehicleEntity v) => v.supportedFuels.contains(fuelType) && v.isActive).toList();
});
import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/app_error.dart' as local_error;
import '../../../../core/providers/auth_provider.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/usecases/add_vehicle.dart';
import '../../domain/usecases/delete_vehicle.dart';
import '../../domain/usecases/get_all_vehicles.dart';
import '../../domain/usecases/get_vehicle_by_id.dart';
import '../../domain/usecases/search_vehicles.dart';
import '../../domain/usecases/update_vehicle.dart';

part 'vehicles_notifier.g.dart';

/// Notifier para gerenciar estado de veículos com AsyncNotifier
/// Suporta stream watching, offline sync, CRUD completo e derived providers
@riverpod
class VehiclesNotifier extends _$VehiclesNotifier {
  StreamSubscription<Either<dynamic, List<VehicleEntity>>>? _vehicleSubscription;

  String get notifierName => 'VehiclesNotifier';

  @override
  Future<List<VehicleEntity>> build() async {
    // Limpar subscription anterior se existir
    await _vehicleSubscription?.cancel();

    // Verificar autenticação
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      _logInfo('User not authenticated, returning empty list');
      return [];
    }

    // Iniciar watch stream para atualizações em tempo real
    _startWatchingVehicles();

    // Carregar veículos iniciais
    _logInfo('Loading initial vehicles for user: ${currentUser.id}');

    return await _executeOperation(
      () async {
        final getAllVehicles = GetIt.instance<GetAllVehicles>();
        final result = await getAllVehicles();

        return result.fold(
          (failure) {
            final error = _mapFailureToError(failure);
            throw error as Object;
          },
          (vehicles) {
            _logInfo('Loaded ${vehicles.length} vehicles successfully');
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
              _logWarning('Stream error: $failure');
              // Não atualizar estado em caso de erro de stream para evitar quebrar UI
            },
            (vehicles) {
              _logInfo('Stream update: ${vehicles.length} vehicles');
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
          _logWarning('Stream subscription error: $error');
        },
      );
    } catch (e) {
      _logWarning('Failed to start watching vehicles: $e');
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
    _logInfo('Adding vehicle: ${vehicle.name}');

    // Executar operação e obter veículo adicionado
    VehicleEntity? addedVehicle;

    await _executeOperation(
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
            _logInfo('Vehicle added successfully: ${added.id}');
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
    );

    return addedVehicle!;
  }

  /// Atualiza veículo existente
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle) async {
    _logInfo('Updating vehicle: ${vehicle.id}');

    // Executar operação e obter veículo atualizado
    VehicleEntity? updatedVehicle;

    await _executeOperation(
      () async {
        final updateVehicleUseCase = GetIt.instance<UpdateVehicle>();
        final result = await updateVehicleUseCase(UpdateVehicleParams(vehicle: vehicle));

        return result.fold(
          (failure) {
            final error = _mapFailureToError(failure);
            throw error as Object;
          },
          (updated) {
            _logInfo('Vehicle updated successfully: ${updated.id}');
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
    );

    return updatedVehicle!;
  }

  /// Remove veículo
  Future<void> deleteVehicle(String vehicleId) async {
    _logInfo('Deleting vehicle: $vehicleId');

    await _executeOperation(
      () async {
        final deleteVehicleUseCase = GetIt.instance<DeleteVehicle>();
        final result = await deleteVehicleUseCase(DeleteVehicleParams(vehicleId: vehicleId));

        return result.fold(
          (failure) {
            final error = _mapFailureToError(failure);
            throw error as Object;
          },
          (_) {
            _logInfo('Vehicle deleted successfully: $vehicleId');

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
    );
  }

  /// Busca veículo por ID
  Future<VehicleEntity?> getVehicleById(String vehicleId) async {
    _logInfo('Getting vehicle by ID: $vehicleId');

    try {
      VehicleEntity? foundVehicle;

      await _executeOperation(
        () async {
          final getVehicleByIdUseCase = GetIt.instance<GetVehicleById>();
          final result = await getVehicleByIdUseCase(GetVehicleByIdParams(vehicleId: vehicleId));

          return result.fold(
            (failure) {
              final error = _mapFailureToError(failure);
              throw error as Object;
            },
            (vehicle) {
              _logInfo('Vehicle found: ${vehicle.id}');
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
      );

      return foundVehicle;
    } catch (e) {
      _logWarning('Failed to get vehicle by ID: $e');
      return null;
    }
  }

  /// Busca veículos por query
  Future<List<VehicleEntity>> searchVehicles(String query) async {
    _logInfo('Searching vehicles: $query');

    try {
      List<VehicleEntity> searchResults = [];

      await _executeOperation(
        () async {
          final searchVehiclesUseCase = GetIt.instance<SearchVehicles>();
          final result = await searchVehiclesUseCase(SearchVehiclesParams(query: query));

          return result.fold(
            (failure) {
              final error = _mapFailureToError(failure);
              throw error as Object;
            },
            (vehicles) {
              _logInfo('Found ${vehicles.length} vehicles matching query');
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
      );

      return searchResults;
    } catch (e) {
      _logWarning('Search failed: $e');
      return [];
    }
  }

  /// Força refresh dos dados
  Future<void> refresh() async {
    _logInfo('Refreshing vehicles');
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

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  void _logInfo(String message) {
    if (kDebugMode) {
      print('ℹ️ [$notifierName] $message');
    }
  }

  void _logWarning(String message) {
    if (kDebugMode) {
      print('⚠️ [$notifierName] $message');
    }
  }

  Future<T> _executeOperation<T>(
    Future<T> Function() operation, {
    required String operationName,
  }) async {
    try {
      _logInfo('Executing $operationName...');
      final result = await operation();
      _logInfo('$operationName completed successfully');
      return result;
    } catch (e) {
      _logWarning('$operationName failed: $e');
      rethrow;
    }
  }
}

// ============================================================================
// PROVIDERS DERIVADOS
// ============================================================================

/// Provider para veículo selecionado (ID)
@riverpod
class SelectedVehicleId extends _$SelectedVehicleId {
  @override
  String? build() => null;

  void select(String? id) => state = id;
  void clear() => state = null;
}

/// Provider para veículo selecionado (Entity)
@riverpod
VehicleEntity? selectedVehicle(Ref ref) {
  final selectedId = ref.watch(selectedVehicleIdProvider);
  if (selectedId == null) return null;

  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  return vehiclesAsync.when(
    data: (vehicles) {
      try {
        return vehicles.firstWhere((v) => v.id == selectedId);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Provider para query de busca
@riverpod
class VehicleSearchQuery extends _$VehicleSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}

/// Provider para veículos filtrados por busca
@riverpod
AsyncValue<List<VehicleEntity>> filteredVehicles(Ref ref) {
  final query = ref.watch(vehicleSearchQueryProvider).toLowerCase().trim();
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);

  if (query.isEmpty) {
    return vehiclesAsync;
  }

  return vehiclesAsync.when(
    data: (vehicles) => AsyncValue.data(
      vehicles.where((v) {
        final searchText = '${v.name} ${v.brand} ${v.model} ${v.licensePlate}'.toLowerCase();
        return searchText.contains(query);
      }).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
}

/// Provider para veículos ativos apenas
@riverpod
AsyncValue<List<VehicleEntity>> activeVehicles(Ref ref) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);

  return vehiclesAsync.when(
    data: (vehicles) => AsyncValue.data(
      vehicles.where((v) => v.isActive).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
}

/// Provider para contagem de veículos
@riverpod
int vehicleCount(Ref ref) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  return vehiclesAsync.when(
    data: (vehicles) => vehicles.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider para contagem de veículos ativos
@riverpod
int activeVehicleCount(Ref ref) {
  final activeVehiclesAsync = ref.watch(activeVehiclesProvider);
  return activeVehiclesAsync.when(
    data: (vehicles) => vehicles.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider para verificar se há veículos
@riverpod
bool hasVehicles(Ref ref) {
  final count = ref.watch(vehicleCountProvider);
  return count > 0;
}

/// Provider para veículos por tipo
@riverpod
List<VehicleEntity> vehiclesByType(Ref ref, VehicleType type) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  final vehicles = vehiclesAsync.when(
    data: (vehicles) => vehicles,
    loading: () => <VehicleEntity>[],
    error: (_, __) => <VehicleEntity>[],
  );
  return vehicles.where((v) => v.type == type && v.isActive).toList();
}

/// Provider para veículos por tipo de combustível
@riverpod
List<VehicleEntity> vehiclesByFuelType(Ref ref, FuelType fuelType) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  final vehicles = vehiclesAsync.when(
    data: (vehicles) => vehicles,
    loading: () => <VehicleEntity>[],
    error: (_, __) => <VehicleEntity>[],
  );
  return vehicles.where((v) => v.supportedFuels.contains(fuelType) && v.isActive).toList();
}
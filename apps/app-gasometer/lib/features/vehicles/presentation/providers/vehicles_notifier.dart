import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/providers/dependency_providers.dart' as deps;
import '../../../auth/presentation/notifiers/notifiers.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/usecases/add_vehicle.dart';
import '../../domain/usecases/delete_vehicle.dart';
import '../../domain/usecases/get_vehicle_by_id.dart';
import '../../domain/usecases/search_vehicles.dart';
import '../../domain/usecases/update_vehicle.dart';
import 'vehicle_services_providers.dart';

part 'vehicles_notifier.g.dart';

/// Notifier para gerenciar estado de veículos com AsyncNotifier
/// Suporta stream watching, offline sync, CRUD completo e derived providers
/// keepAlive: true mantém o provider vivo durante toda a sessão do app
/// pois a lista de veículos é usada em múltiplas páginas (fuel, expenses, maintenance, odometer)
@riverpod
class VehiclesNotifier extends _$VehiclesNotifier {
  StreamSubscription<Either<dynamic, List<VehicleEntity>>>?
  _vehicleSubscription;

  /// Cache de veículos removidos para possível restauração (exclusão otimista)
  final Map<String, _DeletedVehicle> _deletedVehicles = {};

  /// Timers para exclusão permanente
  final Map<String, Timer> _deleteTimers = {};

  /// Duração antes da exclusão permanente
  static const _undoDuration = Duration(seconds: 5);

  String get notifierName => 'VehiclesNotifier';

  ErrorMapper? _errorMapper;

  @override
  Future<List<VehicleEntity>> build() async {
    await _vehicleSubscription?.cancel();
    _errorMapper ??= ref.read(errorMapperProvider);

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      _logInfo('User not authenticated, returning empty list');
      return [];
    }
    _startWatchingVehicles();
    _logInfo('Loading initial vehicles for user: ${currentUser.id}');

    return await _executeOperation(() async {
      final getAllVehicles = ref.read(deps.getAllVehiclesProvider);
      final result = await getAllVehicles();

      return result.fold(
        (failure) {
          final error = _errorMapper!.mapFailureToError(failure);
          throw error;
        },
        (vehicles) {
          _logInfo('Loaded ${vehicles.length} vehicles successfully');
          return vehicles;
        },
      );
    }, operationName: 'build');
  }

  /// Inicia watch stream para sincronização em tempo real
  void _startWatchingVehicles() {
    try {
      final repository = ref.read(deps.vehicleRepositoryProvider);

      _vehicleSubscription = repository.watchVehicles().listen(
        (result) {
          result.fold(
            (failure) {
              _logWarning('Stream error: $failure');
            },
            (vehicles) {
              _logInfo('Stream update: ${vehicles.length} vehicles');
              final currentData = state.when(
                data: (data) => data,
                loading: () => null,
                error: (_, __) => null,
              );
              if (currentData == null ||
                  !_areListsEqual(currentData, vehicles)) {
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
    VehicleEntity? addedVehicle;

    await _executeOperation(() async {
      final addVehicleUseCase = ref.read(deps.addVehicleProvider);
      final result = await addVehicleUseCase(
        AddVehicleParams(vehicle: vehicle),
      ).timeout(const Duration(seconds: 30));

      return result.fold(
        (failure) {
          final error = _errorMapper!.mapFailureToError(failure);
          throw error;
        },
        (added) {
          _logInfo('Vehicle added successfully: ${added.id}');
          addedVehicle = added;
          final currentList = state.when(
            data: (data) => data,
            loading: () => <VehicleEntity>[],
            error: (_, __) => <VehicleEntity>[],
          );
          state = AsyncValue.data([...currentList, added]);

          return currentList; // Return list to satisfy executeOperation type
        },
      );
    }, operationName: 'addVehicle');

    return addedVehicle!;
  }

  /// Atualiza veículo existente
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle) async {
    _logInfo('Updating vehicle: ${vehicle.id}');
    VehicleEntity? updatedVehicle;

    await _executeOperation(() async {
      final updateVehicleUseCase = ref.read(deps.updateVehicleProvider);
      final result = await updateVehicleUseCase(
        UpdateVehicleParams(vehicle: vehicle),
      );

      return result.fold(
        (failure) {
          final error = _errorMapper!.mapFailureToError(failure);
          throw error;
        },
        (updated) {
          _logInfo('Vehicle updated successfully: ${updated.id}');
          updatedVehicle = updated;
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
    }, operationName: 'updateVehicle');

    return updatedVehicle!;
  }

  /// Remove veículo
  Future<void> deleteVehicle(String vehicleId) async {
    _logInfo('Deleting vehicle: $vehicleId');

    await _executeOperation(() async {
      final deleteVehicleUseCase = ref.read(deps.deleteVehicleProvider);
      final result = await deleteVehicleUseCase(
        DeleteVehicleParams(vehicleId: vehicleId),
      );

      return result.fold(
        (failure) {
          final error = _errorMapper!.mapFailureToError(failure);
          throw error;
        },
        (_) {
          _logInfo('Vehicle deleted successfully: $vehicleId');
          final currentList = state.when(
            data: (data) => data,
            loading: () => <VehicleEntity>[],
            error: (_, __) => <VehicleEntity>[],
          );
          final updatedList = currentList
              .where((VehicleEntity v) => v.id != vehicleId)
              .toList();
          state = AsyncValue.data(updatedList);

          return currentList; // Return list to satisfy executeOperation type
        },
      );
    }, operationName: 'deleteVehicle');
  }

  /// Remove veículo otimisticamente (da UI imediatamente)
  /// 
  /// O veículo é removido da lista imediatamente, mas a exclusão permanente
  /// só ocorre após [_undoDuration]. Isso permite que o usuário desfaça a ação.
  Future<void> removeOptimistic(VehicleEntity vehicle) async {
    final id = vehicle.id;
    _logInfo('Removing vehicle optimistically: $id');

    // Cancela timer anterior se existir
    _deleteTimers[id]?.cancel();

    // Armazena o veículo para possível restauração
    _deletedVehicles[id] = _DeletedVehicle(
      vehicle: vehicle,
      deletedAt: DateTime.now(),
    );

    // Remove da lista imediatamente (otimista)
    final currentList = state.when(
      data: (data) => data,
      loading: () => <VehicleEntity>[],
      error: (_, __) => <VehicleEntity>[],
    );
    final updatedList = currentList.where((v) => v.id != id).toList();
    state = AsyncValue.data(updatedList);

    // Agenda exclusão permanente
    _deleteTimers[id] = Timer(_undoDuration, () {
      _confirmDelete(id);
    });
  }

  /// Restaura um veículo que foi removido otimisticamente
  Future<void> restoreVehicle(String vehicleId) async {
    _logInfo('Restoring vehicle: $vehicleId');

    // Cancela o timer de exclusão permanente
    _deleteTimers[vehicleId]?.cancel();
    _deleteTimers.remove(vehicleId);

    // Recupera o veículo do cache
    final deletedVehicle = _deletedVehicles.remove(vehicleId);
    if (deletedVehicle != null) {
      // Adiciona de volta à lista
      final currentList = state.when(
        data: (data) => data,
        loading: () => <VehicleEntity>[],
        error: (_, __) => <VehicleEntity>[],
      );
      state = AsyncValue.data([...currentList, deletedVehicle.vehicle]);
      _logInfo('Vehicle restored: $vehicleId');
    }
  }

  /// Confirma a exclusão permanente
  Future<void> _confirmDelete(String vehicleId) async {
    _deleteTimers.remove(vehicleId);
    _deletedVehicles.remove(vehicleId);

    try {
      _logInfo('Confirming permanent delete: $vehicleId');
      final deleteVehicleUseCase = ref.read(deps.deleteVehicleProvider);
      final result = await deleteVehicleUseCase(
        DeleteVehicleParams(vehicleId: vehicleId),
      );

      result.fold(
        (failure) => _logWarning('Failed to permanently delete vehicle: $failure'),
        (_) => _logInfo('Vehicle permanently deleted: $vehicleId'),
      );
    } catch (e) {
      _logWarning('Error confirming delete: $e');
    }
  }

  /// Verifica se um veículo está pendente de exclusão
  bool isPendingDelete(String vehicleId) => _deletedVehicles.containsKey(vehicleId);

  /// Busca veículo por ID
  Future<VehicleEntity?> getVehicleById(String vehicleId) async {
    _logInfo('Getting vehicle by ID: $vehicleId');

    try {
      VehicleEntity? foundVehicle;

      await _executeOperation(() async {
        final getVehicleByIdUseCase = ref.read(deps.getVehicleByIdProvider);
        final result = await getVehicleByIdUseCase(
          GetVehicleByIdParams(vehicleId: vehicleId),
        );

        return result.fold(
          (failure) {
            final error = _errorMapper!.mapFailureToError(failure);
            throw error;
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
      }, operationName: 'getVehicleById');

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

      await _executeOperation(() async {
        final searchVehiclesUseCase = ref.read(deps.searchVehiclesProvider);
        final result = await searchVehiclesUseCase(
          SearchVehiclesParams(query: query),
        );

        return result.fold(
          (failure) {
            final error = _errorMapper!.mapFailureToError(failure);
            throw error;
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
      }, operationName: 'searchVehicles');

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

  final vehiclesAsync = ref.watch(vehiclesProvider);
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
  final vehiclesAsync = ref.watch(vehiclesProvider);

  if (query.isEmpty) {
    return vehiclesAsync;
  }

  return vehiclesAsync.when(
    data: (vehicles) => AsyncValue.data(
      vehicles.where((v) {
        final searchText = '${v.name} ${v.brand} ${v.model} ${v.licensePlate}'
            .toLowerCase();
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
  final vehiclesAsync = ref.watch(vehiclesProvider);

  return vehiclesAsync.when(
    data: (vehicles) =>
        AsyncValue.data(vehicles.where((v) => v.isActive).toList()),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
}

/// Provider para contagem de veículos
@riverpod
int vehicleCount(Ref ref) {
  final vehiclesAsync = ref.watch(vehiclesProvider);
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

/// Representa um veículo que foi removido mas ainda pode ser restaurado
class _DeletedVehicle {
  _DeletedVehicle({
    required this.vehicle,
    required this.deletedAt,
  });

  final VehicleEntity vehicle;
  final DateTime deletedAt;
}

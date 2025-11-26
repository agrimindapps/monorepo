import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/bovine_entity.dart';
import '../../domain/usecases/create_bovine.dart';
import '../../domain/usecases/delete_bovine.dart';
import '../../domain/usecases/get_bovines.dart';
import '../../domain/usecases/update_bovine.dart';
import 'bovines_management_state.dart';

part 'bovines_management_notifier.g.dart';

/// Riverpod notifier for bovines management
///
/// Single Responsibility: CRUD and state management for bovines
/// Following SRP from specialized providers pattern
@riverpod
class BovinesManagementNotifier extends _$BovinesManagementNotifier {
  late final GetAllBovinesUseCase _getAllBovines;
  late final CreateBovineUseCase _createBovine;
  late final UpdateBovineUseCase _updateBovine;
  late final DeleteBovineUseCase _deleteBovine;

  @override
  BovinesManagementState build() {
    // TODO: Replace getIt calls with Riverpod providers
    // _getAllBovines = getIt<GetAllBovinesUseCase>();
    // _createBovine = getIt<CreateBovineUseCase>();
    // _updateBovine = getIt<UpdateBovineUseCase>();
    // _deleteBovine = getIt<DeleteBovineUseCase>();

    return const BovinesManagementState();
  }

  /// Computed properties
  List<BovineEntity> get activeBovines =>
      state.bovines.where((bovine) => bovine.isActive).toList();

  int get totalBovines => state.bovines.length;
  int get totalActiveBovines => activeBovines.length;
  bool get hasSelectedBovine => state.selectedBovine != null;
  bool get isAnyOperationInProgress =>
      state.isLoadingBovines ||
      state.isCreating ||
      state.isUpdating ||
      state.isDeleting;

  List<String> get uniqueBreeds {
    final breeds = <String>{};
    for (final bovine in state.bovines) {
      breeds.add(bovine.breed);
    }
    return breeds.toList()..sort();
  }

  List<String> get uniqueOriginCountries {
    final countries = <String>{};
    for (final bovine in state.bovines) {
      countries.add(bovine.originCountry);
    }
    return countries.toList()..sort();
  }

  /// Loads all bovines
  Future<void> loadBovines() async {
    state = state.copyWith(
      isLoadingBovines: true,
      errorMessage: null,
    );

    final result = await _getAllBovines();

    result.fold(
      (failure) {
        debugPrint(
          'BovinesManagementNotifier: Erro ao carregar bovinos - ${failure.message}',
        );
        state = state.copyWith(
          isLoadingBovines: false,
          errorMessage: failure.message,
        );
      },
      (bovines) {
        debugPrint(
          'BovinesManagementNotifier: Bovinos carregados - ${bovines.length}',
        );
        state = state.copyWith(
          bovines: bovines,
          isLoadingBovines: false,
        );
      },
    );
  }

  /// Selects a specific bovine
  void selectBovine(BovineEntity? bovine) {
    state = state.copyWith(selectedBovine: bovine);
    debugPrint(
      'BovinesManagementNotifier: Bovino selecionado - ${bovine?.id ?? "nenhum"}',
    );
  }

  /// Creates a new bovine
  Future<bool> createBovine(BovineEntity bovine) async {
    state = state.copyWith(
      isCreating: true,
      errorMessage: null,
    );

    final result = await _createBovine(CreateBovineParams(bovine: bovine));

    bool success = false;
    result.fold(
      (failure) {
        debugPrint(
          'BovinesManagementNotifier: Erro ao criar bovino - ${failure.message}',
        );
        state = state.copyWith(
          isCreating: false,
          errorMessage: failure.message,
        );
      },
      (createdBovine) {
        final updatedBovines = [...state.bovines, createdBovine];
        state = state.copyWith(
          bovines: updatedBovines,
          selectedBovine: createdBovine,
          isCreating: false,
        );
        success = true;
        debugPrint(
          'BovinesManagementNotifier: Bovino criado com sucesso - ${createdBovine.id}',
        );
      },
    );

    return success;
  }

  /// Updates an existing bovine
  Future<bool> updateBovine(BovineEntity bovine) async {
    state = state.copyWith(
      isUpdating: true,
      errorMessage: null,
    );

    final result = await _updateBovine(UpdateBovineParams(bovine: bovine));

    bool success = false;
    result.fold(
      (failure) {
        debugPrint(
          'BovinesManagementNotifier: Erro ao atualizar bovino - ${failure.message}',
        );
        state = state.copyWith(
          isUpdating: false,
          errorMessage: failure.message,
        );
      },
      (updatedBovine) {
        final updatedBovines = state.bovines.map((b) {
          return b.id == updatedBovine.id ? updatedBovine : b;
        }).toList();

        state = state.copyWith(
          bovines: updatedBovines,
          selectedBovine: state.selectedBovine?.id == updatedBovine.id
              ? updatedBovine
              : state.selectedBovine,
          isUpdating: false,
        );
        success = true;
        debugPrint(
          'BovinesManagementNotifier: Bovino atualizado com sucesso - ${updatedBovine.id}',
        );
      },
    );

    return success;
  }

  /// Deletes a bovine (soft delete)
  Future<bool> deleteBovine(String bovineId) async {
    state = state.copyWith(
      isDeleting: true,
      errorMessage: null,
    );

    final result = await _deleteBovine(DeleteBovineParams(bovineId: bovineId));

    bool success = false;
    result.fold(
      (failure) {
        debugPrint(
          'BovinesManagementNotifier: Erro ao deletar bovino - ${failure.message}',
        );
        state = state.copyWith(
          isDeleting: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        final updatedBovines = state.bovines.map((b) {
          return b.id == bovineId ? b.copyWith(isActive: false) : b;
        }).toList();

        state = state.copyWith(
          bovines: updatedBovines,
          selectedBovine: state.selectedBovine?.id == bovineId
              ? null
              : state.selectedBovine,
          isDeleting: false,
        );
        success = true;
        debugPrint(
          'BovinesManagementNotifier: Bovino deletado com sucesso - $bovineId',
        );
      },
    );

    return success;
  }

  /// Removes bovine permanently from local list
  void removeBovineFromList(String bovineId) {
    final updatedBovines =
        state.bovines.where((b) => b.id != bovineId).toList();
    state = state.copyWith(
      bovines: updatedBovines,
      selectedBovine:
          state.selectedBovine?.id == bovineId ? null : state.selectedBovine,
    );
    debugPrint(
      'BovinesManagementNotifier: Bovino removido da lista local - $bovineId',
    );
  }

  /// Finds bovine by ID
  BovineEntity? findBovineById(String id) {
    try {
      return state.bovines.firstWhere((bovine) => bovine.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Checks if bovine exists
  bool bovineExists(String id) {
    return findBovineById(id) != null;
  }

  /// Refreshes all bovines
  Future<void> refreshBovines() async {
    await loadBovines();
  }

  /// Clears error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clears current selection
  void clearSelection() {
    state = state.copyWith(selectedBovine: null);
  }

  /// Resets complete state
  void resetState() {
    state = const BovinesManagementState();
  }
}

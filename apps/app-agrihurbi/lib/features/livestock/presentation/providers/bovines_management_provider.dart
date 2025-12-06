import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/bovine_entity.dart';
import '../../domain/usecases/create_bovine.dart';
import '../../domain/usecases/delete_bovine.dart';
import '../../domain/usecases/get_bovines.dart';
import '../../domain/usecases/update_bovine.dart';
import 'livestock_di_providers.dart';

part 'bovines_management_provider.g.dart';

/// State class for BovinesManagement
class BovinesManagementState {
  final List<BovineEntity> bovines;
  final BovineEntity? selectedBovine;
  final bool isLoadingBovines;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;

  const BovinesManagementState({
    this.bovines = const [],
    this.selectedBovine,
    this.isLoadingBovines = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage,
  });

  BovinesManagementState copyWith({
    List<BovineEntity>? bovines,
    BovineEntity? selectedBovine,
    bool? isLoadingBovines,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
    bool clearSelectedBovine = false,
    bool clearError = false,
  }) {
    return BovinesManagementState(
      bovines: bovines ?? this.bovines,
      selectedBovine: clearSelectedBovine ? null : (selectedBovine ?? this.selectedBovine),
      isLoadingBovines: isLoadingBovines ?? this.isLoadingBovines,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isAnyOperationInProgress =>
      isLoadingBovines || isCreating || isUpdating || isDeleting;

  List<BovineEntity> get activeBovines =>
      bovines.where((bovine) => bovine.isActive).toList();

  int get totalBovines => bovines.length;
  int get totalActiveBovines => activeBovines.length;
  bool get hasSelectedBovine => selectedBovine != null;

  List<String> get uniqueBreeds {
    final breeds = <String>{};
    for (final bovine in bovines) {
      breeds.add(bovine.breed);
    }
    return breeds.toList()..sort();
  }

  List<String> get uniqueOriginCountries {
    final countries = <String>{};
    for (final bovine in bovines) {
      countries.add(bovine.originCountry);
    }
    return countries.toList()..sort();
  }
}

/// Provider especializado para gerenciamento de bovinos
///
/// Responsabilidade única: CRUD e gerenciamento de estado de bovinos
/// Seguindo Single Responsibility Principle
@riverpod
class BovinesManagementNotifier extends _$BovinesManagementNotifier {
  GetAllBovinesUseCase get _getAllBovines => ref.read(getAllBovinesUseCaseProvider);
  CreateBovineUseCase get _createBovine => ref.read(createBovineUseCaseProvider);
  UpdateBovineUseCase get _updateBovine => ref.read(updateBovineUseCaseProvider);
  DeleteBovineUseCase get _deleteBovine => ref.read(deleteBovineUseCaseProvider);

  @override
  BovinesManagementState build() {
    return const BovinesManagementState();
  }

  // Convenience getters for backward compatibility
  List<BovineEntity> get bovines => state.bovines;
  BovineEntity? get selectedBovine => state.selectedBovine;
  bool get isLoadingBovines => state.isLoadingBovines;
  bool get isCreating => state.isCreating;
  bool get isUpdating => state.isUpdating;
  bool get isDeleting => state.isDeleting;
  bool get isAnyOperationInProgress => state.isAnyOperationInProgress;
  String? get errorMessage => state.errorMessage;
  List<BovineEntity> get activeBovines => state.activeBovines;
  int get totalBovines => state.totalBovines;
  int get totalActiveBovines => state.totalActiveBovines;
  bool get hasSelectedBovine => state.hasSelectedBovine;
  List<String> get uniqueBreeds => state.uniqueBreeds;
  List<String> get uniqueOriginCountries => state.uniqueOriginCountries;

  /// Carrega todos os bovinos
  Future<void> loadBovines() async {
    state = state.copyWith(isLoadingBovines: true, clearError: true);

    final result = await _getAllBovines();

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoadingBovines: false,
        );
        debugPrint(
            'BovinesManagementNotifier: Erro ao carregar bovinos - ${failure.message}');
      },
      (loadedBovines) {
        state = state.copyWith(
          bovines: loadedBovines,
          isLoadingBovines: false,
        );
        debugPrint(
            'BovinesManagementNotifier: Bovinos carregados - ${loadedBovines.length}');
      },
    );
  }

  /// Seleciona um bovino específico
  void selectBovine(BovineEntity? bovine) {
    state = state.copyWith(
      selectedBovine: bovine,
      clearSelectedBovine: bovine == null,
    );
    debugPrint(
        'BovinesManagementNotifier: Bovino selecionado - ${bovine?.id ?? "nenhum"}');
  }

  /// Cria um novo bovino
  Future<bool> createBovine(BovineEntity bovine) async {
    state = state.copyWith(isCreating: true, clearError: true);

    final result = await _createBovine(CreateBovineParams(bovine: bovine));

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isCreating: false,
        );
        debugPrint(
            'BovinesManagementNotifier: Erro ao criar bovino - ${failure.message}');
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
            'BovinesManagementNotifier: Bovino criado com sucesso - ${createdBovine.id}');
      },
    );

    return success;
  }

  /// Atualiza um bovino existente
  Future<bool> updateBovine(BovineEntity bovine) async {
    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _updateBovine(UpdateBovineParams(bovine: bovine));

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isUpdating: false,
        );
        debugPrint(
            'BovinesManagementNotifier: Erro ao atualizar bovino - ${failure.message}');
      },
      (updatedBovine) {
        final index = state.bovines.indexWhere((b) => b.id == updatedBovine.id);
        if (index != -1) {
          final updatedBovines = List<BovineEntity>.from(state.bovines);
          updatedBovines[index] = updatedBovine;
          state = state.copyWith(
            bovines: updatedBovines,
            selectedBovine: state.selectedBovine?.id == updatedBovine.id
                ? updatedBovine
                : state.selectedBovine,
            isUpdating: false,
          );
          success = true;
          debugPrint(
              'BovinesManagementNotifier: Bovino atualizado com sucesso - ${updatedBovine.id}');
        }
      },
    );

    return success;
  }

  /// Remove um bovino (soft delete)
  Future<bool> deleteBovine(String bovineId) async {
    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _deleteBovine(DeleteBovineParams(bovineId: bovineId));

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isDeleting: false,
        );
        debugPrint(
            'BovinesManagementNotifier: Erro ao deletar bovino - ${failure.message}');
      },
      (_) {
        final index = state.bovines.indexWhere((b) => b.id == bovineId);
        if (index != -1) {
          final updatedBovines = List<BovineEntity>.from(state.bovines);
          updatedBovines[index] = updatedBovines[index].copyWith(isActive: false);
          state = state.copyWith(
            bovines: updatedBovines,
            clearSelectedBovine: state.selectedBovine?.id == bovineId,
            isDeleting: false,
          );
          success = true;
          debugPrint(
              'BovinesManagementNotifier: Bovino deletado com sucesso - $bovineId');
        }
      },
    );

    return success;
  }

  /// Remove permanentemente um bovino da lista local
  void removeBovineFromList(String bovineId) {
    final updatedBovines = List<BovineEntity>.from(state.bovines);
    updatedBovines.removeWhere((bovine) => bovine.id == bovineId);
    state = state.copyWith(
      bovines: updatedBovines,
      clearSelectedBovine: state.selectedBovine?.id == bovineId,
    );
    debugPrint(
        'BovinesManagementNotifier: Bovino removido da lista local - $bovineId');
  }

  /// Encontra bovino por ID
  BovineEntity? findBovineById(String id) {
    try {
      return state.bovines.firstWhere((bovine) => bovine.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se bovino existe
  bool bovineExists(String id) {
    return findBovineById(id) != null;
  }

  /// Refresh completo dos bovinos
  Future<void> refreshBovines() async {
    await loadBovines();
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Limpa seleção atual
  void clearSelection() {
    state = state.copyWith(clearSelectedBovine: true);
  }

  /// Reset completo do estado
  void resetState() {
    state = const BovinesManagementState();
  }
}

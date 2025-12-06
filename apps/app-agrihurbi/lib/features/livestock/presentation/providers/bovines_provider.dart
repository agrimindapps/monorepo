import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/bovine_entity.dart';
import '../../domain/usecases/create_bovine.dart';
import '../../domain/usecases/delete_bovine.dart';
import '../../domain/usecases/get_bovine_by_id.dart';
import '../../domain/usecases/get_bovines.dart';
import '../../domain/usecases/update_bovine.dart';
import 'livestock_di_providers.dart';

part 'bovines_provider.g.dart';

/// State class for Bovines
class BovinesState {
  final List<BovineEntity> bovines;
  final BovineEntity? selectedBovine;
  final bool isLoading;
  final bool isLoadingBovine;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;
  final String searchQuery;

  const BovinesState({
    this.bovines = const [],
    this.selectedBovine,
    this.isLoading = false,
    this.isLoadingBovine = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  BovinesState copyWith({
    List<BovineEntity>? bovines,
    BovineEntity? selectedBovine,
    bool? isLoading,
    bool? isLoadingBovine,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
    String? searchQuery,
    bool clearSelectedBovine = false,
    bool clearError = false,
  }) {
    return BovinesState(
      bovines: bovines ?? this.bovines,
      selectedBovine: clearSelectedBovine ? null : (selectedBovine ?? this.selectedBovine),
      isLoading: isLoading ?? this.isLoading,
      isLoadingBovine: isLoadingBovine ?? this.isLoadingBovine,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Bovinos ativos (não deletados)
  List<BovineEntity> get activeBovines =>
      bovines.where((bovine) => bovine.isActive).toList();

  /// Bovinos filtrados por busca
  List<BovineEntity> get filteredBovines {
    var filtered = activeBovines;

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (bovine) =>
                bovine.commonName.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                bovine.breed.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                bovine.registrationId.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
          )
          .toList();
    }

    return filtered;
  }

  /// Estatísticas dos bovinos
  int get totalBovines => bovines.length;
  int get activeBovinesCount => activeBovines.length;
  int get filteredBovinesCount => filteredBovines.length;

  /// Raças únicas para filtros
  List<String> get uniqueBreeds {
    final breeds = activeBovines.map((bovine) => bovine.breed).toSet();
    return breeds.toList()..sort();
  }
}

/// Bovines Notifier using Riverpod code generation
///
/// Provider especializado para operações de bovinos
/// Separado do provider principal para otimização e modularização
@riverpod
class BovinesNotifier extends _$BovinesNotifier {
  GetAllBovinesUseCase get _getAllBovines => ref.read(getAllBovinesUseCaseProvider);
  GetBovineByIdUseCase get _getBovineById => ref.read(getBovineByIdUseCaseProvider);
  CreateBovineUseCase get _createBovine => ref.read(createBovineUseCaseProvider);
  UpdateBovineUseCase get _updateBovine => ref.read(updateBovineUseCaseProvider);
  DeleteBovineUseCase get _deleteBovine => ref.read(deleteBovineUseCaseProvider);

  @override
  BovinesState build() {
    return const BovinesState();
  }

  // Convenience getters for backward compatibility
  List<BovineEntity> get bovines => state.bovines;
  BovineEntity? get selectedBovine => state.selectedBovine;
  bool get isLoading => state.isLoading;
  bool get isLoadingBovine => state.isLoadingBovine;
  bool get isCreating => state.isCreating;
  bool get isUpdating => state.isUpdating;
  bool get isDeleting => state.isDeleting;
  String? get errorMessage => state.errorMessage;
  String get searchQuery => state.searchQuery;
  List<BovineEntity> get activeBovines => state.activeBovines;
  List<BovineEntity> get filteredBovines => state.filteredBovines;
  int get totalBovines => state.totalBovines;
  int get activeBovinesCount => state.activeBovinesCount;
  int get filteredBovinesCount => state.filteredBovinesCount;
  List<String> get uniqueBreeds => state.uniqueBreeds;

  /// Carrega todos os bovinos
  Future<void> loadBovines() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAllBovines();

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
        debugPrint(
          'BovinesNotifier: Erro ao carregar bovinos - ${failure.message}',
        );
      },
      (loadedBovines) {
        state = state.copyWith(
          bovines: loadedBovines,
          isLoading: false,
        );
        debugPrint(
          'BovinesNotifier: Bovinos carregados - ${loadedBovines.length} itens',
        );
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
      'BovinesNotifier: Bovino selecionado - ${bovine?.id ?? 'nenhum'}',
    );
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
          'BovinesNotifier: Erro ao criar bovino - ${failure.message}',
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
          'BovinesNotifier: Bovino criado com sucesso - ${createdBovine.id}',
        );
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
          'BovinesNotifier: Erro ao atualizar bovino - ${failure.message}',
        );
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
            'BovinesNotifier: Bovino atualizado com sucesso - ${updatedBovine.id}',
          );
        }
      },
    );

    return success;
  }

  /// Remove um bovino (soft delete)
  Future<bool> deleteBovine(String bovineId, {bool confirmed = false}) async {
    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _deleteBovine(
      DeleteBovineParams(
        bovineId: bovineId,
        confirmed: confirmed,
        requireConfirmation: !confirmed,
      ),
    );

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isDeleting: false,
        );
        debugPrint(
          'BovinesNotifier: Erro ao deletar bovino - ${failure.message}',
        );
      },
      (_) {
        final index = state.bovines.indexWhere((b) => b.id == bovineId);
        if (index != -1) {
          final updatedBovines = List<BovineEntity>.from(state.bovines);
          updatedBovines[index] = updatedBovines[index].copyWith(isActive: false);
          
          state = state.copyWith(
            bovines: updatedBovines,
            selectedBovine: state.selectedBovine?.id == bovineId 
                ? null 
                : state.selectedBovine,
            clearSelectedBovine: state.selectedBovine?.id == bovineId,
            isDeleting: false,
          );
          success = true;
          debugPrint(
            'BovinesNotifier: Bovino deletado com sucesso - $bovineId',
          );
        }
      },
    );

    return success;
  }

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    debugPrint('BovinesNotifier: Query de busca atualizada - "$query"');
  }

  /// Limpa busca
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
    debugPrint('BovinesNotifier: Busca limpa');
  }

  /// Busca bovino por ID
  BovineEntity? getBovineById(String id) {
    try {
      return state.bovines.firstWhere((bovine) => bovine.id == id);
    } catch (e) {
      debugPrint('BovinesNotifier: Bovino não encontrado - $id');
      return null;
    }
  }

  /// Carrega um bovino específico por ID usando use case dedicado
  Future<bool> loadBovineById(String id) async {
    state = state.copyWith(isLoadingBovine: true, clearError: true);

    try {
      final localBovine = getBovineById(id);
      if (localBovine != null) {
        state = state.copyWith(
          selectedBovine: localBovine,
          isLoadingBovine: false,
        );
        debugPrint('BovinesNotifier: Bovino encontrado no cache - $id');
        return true;
      }

      final result = await _getBovineById(GetBovineByIdParams(bovineId: id));

      bool success = false;
      result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: failure.message,
            isLoadingBovine: false,
          );
          debugPrint(
            'BovinesNotifier: Erro ao carregar bovino por ID - ${failure.message}',
          );
        },
        (bovine) {
          final existingIndex = state.bovines.indexWhere((b) => b.id == bovine.id);
          final updatedBovines = List<BovineEntity>.from(state.bovines);
          
          if (existingIndex == -1) {
            updatedBovines.add(bovine);
          } else {
            updatedBovines[existingIndex] = bovine;
          }

          state = state.copyWith(
            bovines: updatedBovines,
            selectedBovine: bovine,
            isLoadingBovine: false,
          );
          success = true;
          debugPrint(
            'BovinesNotifier: Bovino carregado individualmente - ${bovine.id}',
          );
        },
      );

      return success;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado ao carregar bovino: $e',
        isLoadingBovine: false,
      );
      debugPrint('BovinesNotifier: Exceção ao carregar bovino - $e');
      return false;
    }
  }

  /// Busca bovinos por raça
  List<BovineEntity> getBovinesByBreed(String breed) {
    return state.activeBovines
        .where((bovine) => bovine.breed.toLowerCase() == breed.toLowerCase())
        .toList();
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh completo dos dados
  Future<void> refresh() async {
    await loadBovines();
  }

  /// Limpa seleção
  void clearSelection() {
    state = state.copyWith(clearSelectedBovine: true);
  }

  /// Verifica se bovino está selecionado
  bool isBovineSelected(String bovineId) {
    return state.selectedBovine?.id == bovineId;
  }
}

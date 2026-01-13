import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/equine_entity.dart';
import '../../domain/usecases/create_equine.dart';
import '../../domain/usecases/delete_equine.dart';
import '../../domain/usecases/get_equines.dart';
import '../../domain/usecases/update_equine.dart';
import 'livestock_di_providers.dart';

part 'equines_management_provider.g.dart';

/// State class for EquinesManagement
class EquinesManagementState {
  final List<EquineEntity> equines;
  final EquineEntity? selectedEquine;
  final bool isLoadingEquines;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;

  const EquinesManagementState({
    this.equines = const [],
    this.selectedEquine,
    this.isLoadingEquines = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage,
  });

  EquinesManagementState copyWith({
    List<EquineEntity>? equines,
    EquineEntity? selectedEquine,
    bool? isLoadingEquines,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
    bool clearSelectedEquine = false,
    bool clearError = false,
  }) {
    return EquinesManagementState(
      equines: equines ?? this.equines,
      selectedEquine: clearSelectedEquine
          ? null
          : (selectedEquine ?? this.selectedEquine),
      isLoadingEquines: isLoadingEquines ?? this.isLoadingEquines,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isAnyOperationInProgress =>
      isLoadingEquines || isCreating || isUpdating || isDeleting;

  List<EquineEntity> get activeEquines =>
      equines.where((equine) => equine.isActive).toList();

  int get totalEquines => equines.length;
  int get totalActiveEquines => activeEquines.length;
  bool get hasSelectedEquine => selectedEquine != null;

  List<String> get uniqueOriginCountries {
    final countries = <String>{};
    for (final equine in equines) {
      countries.add(equine.originCountry);
    }
    return countries.toList()..sort();
  }
}

/// Provider especializado para gerenciamento de equinos
///
/// Responsabilidade única: CRUD e gerenciamento de estado de equinos
/// Seguindo Single Responsibility Principle
@riverpod
class EquinesManagementNotifier extends _$EquinesManagementNotifier {
  GetEquinesUseCase get _getEquines => ref.read(getEquinesUseCaseProvider);
  CreateEquineUseCase get _createEquine =>
      ref.read(createEquineUseCaseProvider);
  UpdateEquineUseCase get _updateEquine =>
      ref.read(updateEquineUseCaseProvider);
  DeleteEquineUseCase get _deleteEquine =>
      ref.read(deleteEquineUseCaseProvider);

  @override
  EquinesManagementState build() {
    return const EquinesManagementState();
  }

  // Convenience getters for backward compatibility
  List<EquineEntity> get equines => state.equines;
  EquineEntity? get selectedEquine => state.selectedEquine;
  bool get isLoadingEquines => state.isLoadingEquines;
  bool get isCreating => state.isCreating;
  bool get isUpdating => state.isUpdating;
  bool get isDeleting => state.isDeleting;
  bool get isAnyOperationInProgress => state.isAnyOperationInProgress;
  String? get errorMessage => state.errorMessage;
  List<EquineEntity> get activeEquines => state.activeEquines;
  int get totalEquines => state.totalEquines;
  int get totalActiveEquines => state.totalActiveEquines;
  bool get hasSelectedEquine => state.hasSelectedEquine;
  List<String> get uniqueOriginCountries => state.uniqueOriginCountries;

  /// Carrega todos os equinos
  Future<void> loadEquines() async {
    state = state.copyWith(isLoadingEquines: true, clearError: true);

    final result = await _getEquines(const GetEquinesParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoadingEquines: false,
        );
        debugPrint(
          'EquinesManagementNotifier: Erro ao carregar equinos - ${failure.message}',
        );
      },
      (loadedEquines) {
        state = state.copyWith(equines: loadedEquines, isLoadingEquines: false);
        debugPrint(
          'EquinesManagementNotifier: Equinos carregados - ${loadedEquines.length}',
        );
      },
    );
  }

  /// Seleciona um equino específico
  void selectEquine(EquineEntity? equine) {
    state = state.copyWith(
      selectedEquine: equine,
      clearSelectedEquine: equine == null,
    );
    debugPrint(
      'EquinesManagementNotifier: Equino selecionado - ${equine?.id ?? "nenhum"}',
    );
  }

  /// Encontra equino por ID
  EquineEntity? findEquineById(String id) {
    try {
      return state.equines.firstWhere((equine) => equine.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se equino existe
  bool equineExists(String id) {
    return findEquineById(id) != null;
  }

  /// Refresh completo dos equinos
  Future<void> refreshEquines() async {
    await loadEquines();
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Limpa seleção atual
  void clearSelection() {
    state = state.copyWith(clearSelectedEquine: true);
  }

  /// Reset completo do estado
  void resetState() {
    state = const EquinesManagementState();
  }

  Future<bool> createEquine(EquineEntity equine) async {
    state = state.copyWith(isCreating: true, clearError: true);

    final result = await _createEquine(CreateEquineParams(equine: equine));

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isCreating: false,
        );
        return false;
      },
      (createdEquine) {
        final updatedEquines = List<EquineEntity>.from(state.equines);
        updatedEquines.add(createdEquine);

        state = state.copyWith(
          equines: updatedEquines,
          isCreating: false,
          selectedEquine: createdEquine,
        );
        return true;
      },
    );
  }

  Future<bool> updateEquine(EquineEntity equine) async {
    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _updateEquine(UpdateEquineParams(equine: equine));

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isUpdating: false,
        );
        return false;
      },
      (updatedEquine) {
        final updatedEquines = List<EquineEntity>.from(state.equines);
        final index = updatedEquines.indexWhere(
          (e) => e.id == updatedEquine.id,
        );

        if (index != -1) {
          updatedEquines[index] = updatedEquine;
        } else {
          updatedEquines.add(updatedEquine);
        }

        state = state.copyWith(
          equines: updatedEquines,
          isUpdating: false,
          selectedEquine: updatedEquine,
        );
        return true;
      },
    );
  }

  Future<bool> deleteEquine(String equineId) async {
    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _deleteEquine(
      DeleteEquineParams(equineId: equineId, confirmed: true),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isDeleting: false,
        );
        return false;
      },
      (_) {
        final updatedEquines = List<EquineEntity>.from(state.equines);
        updatedEquines.removeWhere((e) => e.id == equineId);

        state = state.copyWith(
          equines: updatedEquines,
          isDeleting: false,
          clearSelectedEquine: state.selectedEquine?.id == equineId,
        );
        return true;
      },
    );
  }
}

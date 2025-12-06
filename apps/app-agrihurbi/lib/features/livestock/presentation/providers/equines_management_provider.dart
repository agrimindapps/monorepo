import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/equine_entity.dart';
import '../../domain/usecases/get_equines.dart';
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
      selectedEquine: clearSelectedEquine ? null : (selectedEquine ?? this.selectedEquine),
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
            'EquinesManagementNotifier: Erro ao carregar equinos - ${failure.message}');
      },
      (loadedEquines) {
        state = state.copyWith(
          equines: loadedEquines,
          isLoadingEquines: false,
        );
        debugPrint(
            'EquinesManagementNotifier: Equinos carregados - ${loadedEquines.length}');
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
        'EquinesManagementNotifier: Equino selecionado - ${equine?.id ?? "nenhum"}');
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
    debugPrint(
        'EquinesManagementNotifier: createEquine não implementado ainda');
    return false;
  }

  Future<bool> updateEquine(EquineEntity equine) async {
    debugPrint(
        'EquinesManagementNotifier: updateEquine não implementado ainda');
    return false;
  }

  Future<bool> deleteEquine(String equineId) async {
    debugPrint(
        'EquinesManagementNotifier: deleteEquine não implementado ainda');
    return false;
  }
}

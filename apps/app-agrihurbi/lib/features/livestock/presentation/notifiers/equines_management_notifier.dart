import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/equine_entity.dart';
import '../../domain/usecases/get_equines.dart';
import 'equines_management_state.dart';

part 'equines_management_notifier.g.dart';

/// Riverpod notifier for equines management
///
/// Single Responsibility: CRUD and state management for equines
@riverpod
class EquinesManagementNotifier extends _$EquinesManagementNotifier {
  late final GetEquinesUseCase _getEquines;

  @override
  EquinesManagementState build() {
    _getEquines = getIt<GetEquinesUseCase>();
    return const EquinesManagementState();
  }

  /// Computed properties
  List<EquineEntity> get activeEquines =>
      state.equines.where((equine) => equine.isActive).toList();

  int get totalEquines => state.equines.length;
  int get totalActiveEquines => activeEquines.length;
  bool get hasSelectedEquine => state.selectedEquine != null;
  bool get isAnyOperationInProgress =>
      state.isLoadingEquines ||
      state.isCreating ||
      state.isUpdating ||
      state.isDeleting;

  List<String> get uniqueOriginCountries {
    final countries = <String>{};
    for (final equine in state.equines) {
      countries.add(equine.originCountry);
    }
    return countries.toList()..sort();
  }

  /// Loads all equines
  Future<void> loadEquines() async {
    state = state.copyWith(
      isLoadingEquines: true,
      errorMessage: null,
    );

    final result = await _getEquines(const GetEquinesParams());

    result.fold(
      (failure) {
        debugPrint(
          'EquinesManagementNotifier: Erro ao carregar equinos - ${failure.message}',
        );
        state = state.copyWith(
          isLoadingEquines: false,
          errorMessage: failure.message,
        );
      },
      (equines) {
        debugPrint(
          'EquinesManagementNotifier: Equinos carregados - ${equines.length}',
        );
        state = state.copyWith(
          equines: equines,
          isLoadingEquines: false,
        );
      },
    );
  }

  /// Selects a specific equine
  void selectEquine(EquineEntity? equine) {
    state = state.copyWith(selectedEquine: equine);
    debugPrint(
      'EquinesManagementNotifier: Equino selecionado - ${equine?.id ?? "nenhum"}',
    );
  }

  /// Finds equine by ID
  EquineEntity? findEquineById(String id) {
    try {
      return state.equines.firstWhere((equine) => equine.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Checks if equine exists
  bool equineExists(String id) {
    return findEquineById(id) != null;
  }

  /// Refreshes all equines
  Future<void> refreshEquines() async {
    await loadEquines();
  }

  /// Clears error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clears current selection
  void clearSelection() {
    state = state.copyWith(selectedEquine: null);
  }

  /// Resets complete state
  void resetState() {
    state = const EquinesManagementState();
  }

  // Placeholder methods for future implementation
  Future<bool> createEquine(EquineEntity equine) async {
    debugPrint('EquinesManagementNotifier: createEquine não implementado ainda');
    return false;
  }

  Future<bool> updateEquine(EquineEntity equine) async {
    debugPrint('EquinesManagementNotifier: updateEquine não implementado ainda');
    return false;
  }

  Future<bool> deleteEquine(String equineId) async {
    debugPrint('EquinesManagementNotifier: deleteEquine não implementado ainda');
    return false;
  }
}

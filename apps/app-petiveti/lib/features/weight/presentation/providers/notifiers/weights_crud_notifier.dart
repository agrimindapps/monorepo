import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/weight.dart';

import '../../../domain/usecases/add_weight.dart';

import '../../../domain/usecases/update_weight.dart';

import '../../states/weights_crud_state.dart';

part 'weights_crud_notifier.g.dart';


/// Notifier specialized for CRUD operations (Add, Update, Delete)
/// Single Responsibility: Handles weight creation, modification, and deletion
/// 
/// Migrated to Riverpod 3.0 Notifier pattern
@riverpod
class WeightsCrudNotifier extends _$WeightsCrudNotifier {
  late final AddWeight _addWeight;
  late final UpdateWeight _updateWeight;

  @override
  WeightsCrudState build() {
    // Initialize use cases from providers (would need to be injected)
    return const WeightsCrudState();
  }

  void setUseCases(AddWeight addWeight, UpdateWeight updateWeight) {
    _addWeight = addWeight;
    _updateWeight = updateWeight;
  }

  /// Adds a new weight record
  Future<void> addWeight(Weight weight) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _addWeight(weight);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = state.copyWith(isLoading: false, error: null),
    );
  }

  /// Updates an existing weight record
  Future<void> updateWeight(Weight weight) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _updateWeight(weight);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = state.copyWith(isLoading: false, error: null),
    );
  }

  /// Handles the clearing of error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

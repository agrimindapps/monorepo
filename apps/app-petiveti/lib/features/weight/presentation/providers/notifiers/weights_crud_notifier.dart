import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/weight.dart';
import '../../../domain/usecases/add_weight.dart';
import '../../../domain/usecases/update_weight.dart';
import '../../states/weights_crud_state.dart';

/// Notifier specialized for CRUD operations (Add, Update, Delete)
/// Single Responsibility: Handles weight creation, modification, and deletion
class WeightsCrudNotifier extends StateNotifier<WeightsCrudState> {
  final AddWeight _addWeight;
  final UpdateWeight _updateWeight;

  WeightsCrudNotifier({
    required AddWeight addWeight,
    required UpdateWeight updateWeight,
  }) : _addWeight = addWeight,
       _updateWeight = updateWeight,
       super(const WeightsCrudState());

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

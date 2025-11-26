import 'package:freezed_annotation/freezed_annotation.dart';

part 'livestock_coordinator_state.freezed.dart';

/// Immutable state for livestock coordinator
///
/// This is a lightweight state as the actual data is in specialized notifiers
@freezed
abstract class LivestockCoordinatorState with _$LivestockCoordinatorState {
  const LivestockCoordinatorState._();
  const factory LivestockCoordinatorState({
    @Default(false) bool isInitializing,
    @Default(null) String? errorMessage,
  }) = _LivestockCoordinatorState;
}

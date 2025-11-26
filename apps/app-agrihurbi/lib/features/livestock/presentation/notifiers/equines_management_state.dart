import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/equine_entity.dart';

part 'equines_management_state.freezed.dart';

/// Immutable state for equines management
@freezed
abstract class EquinesManagementState with _$EquinesManagementState {
  const EquinesManagementState._();
  const factory EquinesManagementState({
    @Default([]) List<EquineEntity> equines,
    @Default(null) EquineEntity? selectedEquine,
    @Default(false) bool isLoadingEquines,
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,
    @Default(false) bool isDeleting,
    @Default(null) String? errorMessage,
  }) = _EquinesManagementState;
}

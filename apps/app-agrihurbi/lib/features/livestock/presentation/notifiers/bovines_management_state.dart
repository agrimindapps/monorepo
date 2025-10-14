import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/bovine_entity.dart';

part 'bovines_management_state.freezed.dart';

/// Immutable state for bovines management
@freezed
class BovinesManagementState with _$BovinesManagementState {
  const factory BovinesManagementState({
    @Default([]) List<BovineEntity> bovines,
    @Default(null) BovineEntity? selectedBovine,
    // Loading states for each operation
    @Default(false) bool isLoadingBovines,
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,
    @Default(false) bool isDeleting,
    @Default(null) String? errorMessage,
  }) = _BovinesManagementState;
}

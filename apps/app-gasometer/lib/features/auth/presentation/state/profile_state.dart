import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'profile_state.freezed.dart';

/// ProfileState - State para gerenciamento de perfil do usuário
///
/// Separado do AuthState para aplicar SRP
@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    UserEntity? currentUser,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _ProfileState;

  const factory ProfileState.initial() = _ProfileStateInitial;
}

/// Extension para facilitar copyWith com clear flags
extension ProfileStateX on ProfileState {
  ProfileState copyWith({
    UserEntity? currentUser,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

import '../../domain/entities/user_entity.dart';

/// ProfileState - State para gerenciamento de perfil do usuário
///
/// Separado do AuthState para aplicar SRP
class ProfileState {
  const ProfileState({
    this.currentUser,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  const ProfileState.initial() : this();

  final UserEntity? currentUser;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileState &&
          runtimeType == other.runtimeType &&
          currentUser == other.currentUser &&
          isLoading == other.isLoading &&
          hasError == other.hasError &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      currentUser.hashCode ^
      isLoading.hashCode ^
      hasError.hashCode ^
      errorMessage.hashCode;

  @override
  String toString() =>
      'ProfileState(user: ${currentUser?.id}, isLoading: $isLoading, hasError: $hasError)';
}

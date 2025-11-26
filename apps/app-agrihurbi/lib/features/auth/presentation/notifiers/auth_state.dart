import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

/// Immutable state for authentication
@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();
  const factory AuthState({
    @Default(null) UserEntity? currentUser,
    @Default(false) bool isLoading,
    @Default(false) bool isLoggedIn,
    @Default(true) bool isInitializing,
    @Default(false) bool isLoggingIn,
    @Default(false) bool isRegistering,
    @Default(false) bool isLoggingOut,
    @Default(false) bool isRefreshing,
    @Default(null) String? errorMessage,
  }) = _AuthState;
}

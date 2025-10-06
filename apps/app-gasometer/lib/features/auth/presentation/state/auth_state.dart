import '../../domain/entities/user_entity.dart';

/// Enum para status de autenticação
enum AuthStatus {
  unauthenticated,
  authenticated,
  authenticating,
  error,
}

/// Estado completo de autenticação - Riverpod v2
///
/// Migrado para Riverpod v2 com @riverpod pattern
class AuthState {
  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.isPremium = false,
    this.isAnonymous = false,
    this.status = AuthStatus.unauthenticated,
    this.isInitialized = false,
    this.isSyncing = false,
    this.syncMessage = 'Sincronizando dados automotivos...',
  });

  const AuthState.initial() : this();

  final UserEntity? currentUser;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool isPremium;
  final bool isAnonymous;
  final AuthStatus status;
  final bool isInitialized;
  final bool isSyncing;
  final String syncMessage;

  AuthState copyWith({
    UserEntity? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    bool? isPremium,
    bool? isAnonymous,
    AuthStatus? status,
    bool? isInitialized,
    bool? isSyncing,
    String? syncMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isPremium: isPremium ?? this.isPremium,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      isInitialized: isInitialized ?? this.isInitialized,
      isSyncing: isSyncing ?? this.isSyncing,
      syncMessage: syncMessage ?? this.syncMessage,
    );
  }
  String? get userDisplayName => currentUser?.displayName;
  String? get userEmail => currentUser?.email;
  String get userId => currentUser?.id ?? '';
  bool get isSyncInProgress => isSyncing; // Alias para compatibilidade

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          currentUser == other.currentUser &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage &&
          isAuthenticated == other.isAuthenticated &&
          isPremium == other.isPremium &&
          isAnonymous == other.isAnonymous &&
          status == other.status &&
          isInitialized == other.isInitialized &&
          isSyncing == other.isSyncing;

  @override
  int get hashCode =>
      currentUser.hashCode ^
      isLoading.hashCode ^
      errorMessage.hashCode ^
      isAuthenticated.hashCode ^
      isPremium.hashCode ^
      isAnonymous.hashCode ^
      status.hashCode ^
      isInitialized.hashCode ^
      isSyncing.hashCode;

  @override
  String toString() =>
      'AuthState(user: ${currentUser?.id}, isLoading: $isLoading, isAuth: $isAuthenticated, status: $status)';
}

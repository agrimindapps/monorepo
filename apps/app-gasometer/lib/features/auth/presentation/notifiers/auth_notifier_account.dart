part of 'auth_notifier.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

extension AuthNotifierAccount on Auth {
  /// SEND PASSWORD RESET - migrado do AuthProvider
  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      clearError: true,
    );

    final result = await _sendPasswordReset(
      SendPasswordResetParams(email: email),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isLoading: false,
          status: AuthStatus.error,
        );
      },
      (_) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  /// DELETE ACCOUNT - Enhanced with EnhancedAccountDeletionService
  Future<void> deleteAccount({String? currentPassword}) async {
    if (state.currentUser == null) {
      state = state.copyWith(
        errorMessage: 'Nenhum usuário autenticado',
        isLoading: false,
        status: AuthStatus.error,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      clearError: true,
    );

    try {
      final result = await _enhancedDeletionService.deleteAccount(
        password: currentPassword ?? '',
        userId: state.currentUser!.id,
        isAnonymous: state.isAnonymous,
      );

      result.fold(
        (error) {
          state = state.copyWith(
            errorMessage: error.message,
            isLoading: false,
            status: AuthStatus.error,
          );
        },
        (deletionResult) {
          if (deletionResult.isSuccess) {
            _performPostDeletionCleanup();
          } else {
            state = state.copyWith(
              errorMessage: deletionResult.userMessage,
              isLoading: false,
              status: AuthStatus.error,
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoading: false,
        status: AuthStatus.error,
      );
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'delete_account_error',
      );
    }
  }

  void _performPostDeletionCleanup() {
    state = state.copyWith(
      currentUser: null,
      isAuthenticated: false,
      isPremium: false,
      isAnonymous: false,
      isLoading: false,
      status: AuthStatus.unauthenticated,
      clearUser: true,
    );

    if (kDebugMode) {
      debugPrint('🔐 Conta deletada com sucesso');
    }
  }
}

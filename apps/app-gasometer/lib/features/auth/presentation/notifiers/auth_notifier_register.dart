part of 'auth_notifier.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

extension AuthNotifierRegister on Auth {
  /// REGISTER - migrado do AuthProvider
  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      status: AuthStatus.authenticating,
      clearError: true,
    );

    final result = await _signUpWithEmail(
      SignUpWithEmailParams(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );

    await result.fold(
      (failure) async {
        state = state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isLoading: false,
          status: AuthStatus.error,
        );
      },
      (user) async {
        final gasometerUser = _convertFromCoreUser(user);

        state = state.copyWith(
          currentUser: gasometerUser,
          isAuthenticated: true,
          isPremium: gasometerUser?.isPremium ?? false,
          isAnonymous: gasometerUser?.isAnonymous ?? false,
          isLoading: false,
          status: AuthStatus.authenticated,
        );
        await _analytics.logUserAction(
          'register_success',
          parameters: {'method': 'email'},
        );

        // 🔄 Trigger sync after successful registration
        _triggerPostLoginSync();
      },
    );
  }
}

part of 'auth_notifier.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

extension AuthNotifierLogin on Auth {
  /// LOGIN - migrado do AuthProvider
  Future<void> login(String email, String password) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      status: AuthStatus.authenticating,
      clearError: true,
    );
    _isInLoginAttempt = true; // SECURITY + UX FIX

    try {
      final canAttempt = await _rateLimiter.canAttemptLogin();
      if (!canAttempt) {
        final rateLimitInfo = await _rateLimiter.getRateLimitInfo();
        state = state.copyWith(
          errorMessage: rateLimitInfo.lockoutMessage,
          isLoading: false,
          status: AuthStatus.error,
        );
        _isInLoginAttempt = false;
        await _analytics.logUserAction(
          'login_blocked_rate_limit',
          parameters: {
            'lockout_minutes_remaining':
                rateLimitInfo.lockoutTimeRemainingMinutes,
          },
        );
        return;
      }

      final result = await _signInWithEmail(
        SignInWithEmailParams(email: email, password: password),
      );

      await result.fold(
        (failure) async {
          if (kDebugMode) {
            debugPrint(
              '🔐 AuthNotifier: Login falhou - Tipo: ${failure.runtimeType}, Mensagem: ${failure.message}',
            );
          }
          await _rateLimiter.recordFailedAttempt();
          final rateLimitInfo = await _rateLimiter.getRateLimitInfo();

          String errorMsg = _mapFailureToMessage(failure);
          if (!rateLimitInfo.canAttemptLogin) {
            errorMsg = rateLimitInfo.lockoutMessage;
          } else if (rateLimitInfo.warningMessage.isNotEmpty) {
            errorMsg += '\n\n${rateLimitInfo.warningMessage}';
          }

          state = state.copyWith(
            errorMessage: errorMsg,
            isLoading: false,
            status: AuthStatus.error,
          );
          _isInLoginAttempt = false; // SECURITY + UX FIX
          await _analytics.logUserAction(
            'login_failed',
            parameters: {
              'method': 'email',
              'failure_type': failure.runtimeType.toString(),
              'attempts_remaining': rateLimitInfo.attemptsRemaining,
              'is_locked': rateLimitInfo.isLocked,
            },
          );
        },
        (user) async {
          await _rateLimiter.recordSuccessfulAttempt();

          final gasometerUser = _convertFromCoreUser(user);

          state = state.copyWith(
            currentUser: gasometerUser,
            isAuthenticated: true,
            isPremium: gasometerUser?.isPremium ?? false,
            isAnonymous: gasometerUser?.isAnonymous ?? false,
            isLoading: false,
            status: AuthStatus.authenticated,
          );
          _isInLoginAttempt = false; // SECURITY + UX FIX
          await _analytics.logLogin('email');
          await _analytics.logUserAction(
            'login_success',
            parameters: {'method': 'email'},
          );

          // 🔄 Trigger sync after successful login
          _triggerPostLoginSync();
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro interno no sistema de login. Tente novamente.',
        isLoading: false,
        status: AuthStatus.error,
      );
      _isInLoginAttempt = false; // SECURITY + UX FIX
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'login_method_error',
      );
    }
  }

  /// SIGN IN ANONYMOUSLY - migrado do AuthProvider
  Future<void> loginAnonymously() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      status: AuthStatus.authenticating,
      clearError: true,
    );

    if (kDebugMode) {
      debugPrint('🔐 Iniciando login anônimo...');
    }

    final result = await _signInAnonymously();

    await result.fold(
      (failure) async {
        if (kDebugMode) {
          debugPrint('🔐 Erro no login anônimo: ${failure.message}');
        }
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
          isPremium: false,
          isAnonymous: true,
          isLoading: false,
          status: AuthStatus.authenticated,
        );
        await _saveAnonymousPreference();
        await _analytics.logAnonymousSignIn();
        await _analytics.setUserProperties({
          'user_type': 'anonymous',
          'is_premium': 'false',
        });

        if (kDebugMode) {
          debugPrint('🔐 Usuário logado anonimamente');
        }

        // 🔄 Trigger sync after anonymous login (if needed in future)
        // Anonymous users typically don't have cloud data to sync
        // but we trigger anyway for consistency
        _triggerPostLoginSync();
      },
    );
  }
}

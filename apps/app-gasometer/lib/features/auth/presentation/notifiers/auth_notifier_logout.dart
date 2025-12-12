part of 'auth_notifier.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

extension AuthNotifierLogout on Auth {
  /// LOGOUT - migrado do AuthProvider
  Future<void> logout() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      clearError: true,
    );

    try {
      await _analytics.logLogout();

      final result = await _signOut();

      await result.fold(
        (failure) async {
          state = state.copyWith(
            errorMessage: _mapFailureToMessage(failure),
            isLoading: false,
            status: AuthStatus.error,
          );
        },
        (_) async {
          try {
            await _monorepoAuthCache.clearModuleData('app-gasometer');
            if (kDebugMode) {
              debugPrint('🔐 MonorepoAuthCache limpo para app-gasometer');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ Erro ao limpar MonorepoAuthCache: $e');
            }
          }

          // Limpar TODOS os dados locais do app no logout
          try {
            if (kDebugMode) {
              debugPrint('🗑️ Limpando dados locais no logout...');
            }

            final clearResult = await UnifiedSyncManager.instance.clearAppData(
              'gasometer',
            );

            clearResult.fold(
              (failure) {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ Falha ao limpar dados locais: ${failure.message}',
                  );
                }
              },
              (_) {
                if (kDebugMode) {
                  debugPrint(
                    '✅ Dados locais limpos com sucesso (veículos, abastecimentos, manutenções)',
                  );
                }
              },
            );
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ Erro ao limpar dados locais: $e');
            }
          }

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
            debugPrint('🔐 Logout realizado com sucesso');
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao fazer logout: ${e.toString()}',
        isLoading: false,
        status: AuthStatus.error,
      );
    }
  }

  /// LOGOUT WITH LOADING DIALOG - migrado do AuthProvider
  Future<void> logoutWithLoadingDialog(BuildContext context) async {
    // Store context reference before any async operations
    final navigator = Navigator.of(context);

    try {
      await showLogoutLoading(
        context,
        message: 'Saindo...',
        duration: const Duration(seconds: 2),
      );

      await logout();

      if (kDebugMode) {
        debugPrint('🔐 Logout com loading dialog concluído');
      }
    } catch (e) {
      if (navigator.canPop()) {
        navigator.pop();
      }

      state = state.copyWith(
        errorMessage: 'Erro ao fazer logout: ${e.toString()}',
        status: AuthStatus.error,
      );

      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'logout_with_dialog_error',
      );
    }
  }
}

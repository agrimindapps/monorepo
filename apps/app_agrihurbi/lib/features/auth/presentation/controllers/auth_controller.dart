import 'package:get/get.dart';
import 'package:core/core.dart' as core_lib;
import 'package:app_agrihurbi/core/router/app_router.dart';
import 'package:app_agrihurbi/core/utils/user_adapter.dart';

// Temporary imports for use cases not yet in core
import 'package:app_agrihurbi/features/auth/domain/usecases/register_usecase.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/get_current_user_usecase.dart';

/// Controller for authentication operations
class AuthController extends GetxController {
  final core_lib.LoginUseCase loginUsecase;
  final RegisterUsecase registerUsecase;
  final core_lib.LogoutUseCase logoutUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;

  AuthController({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.logoutUsecase,
    required this.getCurrentUserUsecase,
  });

  // Reactive state
  final Rxn<core_lib.UserEntity> _currentUser = Rxn<core_lib.UserEntity>();
  final RxBool _isLoading = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();

  // Getters
  core_lib.UserEntity? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  String? get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  /// Check current authentication status
  Future<void> _checkAuthStatus() async {
    try {
      _isLoading.value = true;
      final result = await getCurrentUserUsecase.call();
      
      result.fold(
        (failure) {
          _currentUser.value = null;
          _isLoggedIn.value = false;
        },
        (user) {
          _currentUser.value = user != null ? UserAdapter.localToCore(user) : null;
          _isLoggedIn.value = user != null;
        },
      );
    } catch (e) {
      _currentUser.value = null;
      _isLoggedIn.value = false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Login user
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final result = await loginUsecase.call(
        core_lib.LoginParams(email: email, password: password),
      );

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          AppNavigation.showSnackbar(
            'Erro',
            failure.message,
            isError: true,
          );
        },
        (user) {
          _currentUser.value = user;
          _isLoggedIn.value = true;
          AppNavigation.showSnackbar(
            'Sucesso',
            'Login realizado com sucesso!',
          );
          AppNavigation.toHome();
        },
      );
    } catch (e) {
      _errorMessage.value = e.toString();
      AppNavigation.showSnackbar(
        'Erro',
        'Erro inesperado: ${e.toString()}',
        isError: true,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Register user
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final result = await registerUsecase.call(
        RegisterParams(
          name: name,
          email: email,
          password: password,
          phone: phone,
        ),
      );

      result.fold(
        (failure) {
          _errorMessage.value = failure.message;
          AppNavigation.showSnackbar(
            'Erro',
            failure.message,
            isError: true,
          );
        },
        (user) {
          _currentUser.value = UserAdapter.localToCore(user);
          _isLoggedIn.value = true;
          AppNavigation.showSnackbar(
            'Sucesso',
            'Cadastro realizado com sucesso!',
          );
          AppNavigation.toHome();
        },
      );
    } catch (e) {
      _errorMessage.value = e.toString();
      AppNavigation.showSnackbar(
        'Erro',
        'Erro inesperado: ${e.toString()}',
        isError: true,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _isLoading.value = true;

      final result = await logoutUsecase.call();

      result.fold(
        (failure) {
          // Even if logout fails, clear local state
          _clearUserState();
          AppNavigation.showSnackbar(
            'Aviso',
            'Logout local realizado',
          );
        },
        (_) {
          _clearUserState();
          AppNavigation.showSnackbar(
            'Sucesso',
            'Logout realizado com sucesso!',
          );
        },
      );

      AppNavigation.toLogin();
    } catch (e) {
      _clearUserState();
      AppNavigation.toLogin();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Clear user state
  void _clearUserState() {
    _currentUser.value = null;
    _isLoggedIn.value = false;
    _errorMessage.value = null;
  }

  /// Clear error message
  void clearError() {
    _errorMessage.value = null;
  }

  @override
  void onClose() {
    _currentUser.close();
    _isLoading.close();
    _isLoggedIn.close();
    _errorMessage.close();
    super.onClose();
  }
}
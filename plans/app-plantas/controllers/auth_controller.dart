// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/models/auth_models.dart';
import '../../core/services/auth_navigation_service.dart';
import '../../core/services/auth_validation_service.dart';
import '../../core/services/firebase_auth_service.dart';

/// Controller padronizado para autenticação do módulo Plantas
///
/// Migrado para GetX reactive system para consistência com resto da aplicação
class PlantasAuthController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final AuthValidationService _validationService = AuthValidationService();
  final AuthNavigationService _navigationService = AuthNavigationService();

  static const ModuleAuthConfig _moduleConfig = ModuleAuthConfig.plantas;

  // Controllers de texto
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Estado reativo do controller
  final RxBool isLoading = false.obs;
  final RxBool isSignUp = false.obs;
  final RxBool showRecoveryForm = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool rememberMe = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.onClose();
  }

  // Métodos de UI reativos
  void toggleAuthMode() {
    isSignUp.value = !isSignUp.value;
    _clearError();
  }

  void showRecoveryFormAction() {
    showRecoveryForm.value = true;
    _clearError();
  }

  void hideRecoveryFormAction() {
    showRecoveryForm.value = false;
    _clearError();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  void _setLoading(bool loading) {
    isLoading.value = loading;
  }

  void _setError(String? error) {
    errorMessage.value = error;
  }

  void _clearError() {
    errorMessage.value = null;
  }

  // Validações usando o service centralizado
  String? validateEmail(String? value) {
    return _validationService.validateEmailForModule(
        value, _moduleConfig.moduleName);
  }

  String? validatePassword(String? value) {
    if (isSignUp.value) {
      return _validationService.validateSignUpPassword(value);
    }
    return _validationService.validatePassword(value);
  }

  String? validateConfirmPassword(String? value) {
    return _validationService.validateConfirmPassword(
        value, passwordController.text);
  }

  String? validateName(String? value) {
    return _validationService.validateName(value);
  }

  // Método de login
  Future<void> signInWithEmail() async {
    if (!_isFormValid()) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );

      if (result.success && result.user != null) {
        _showSuccessMessage('Login realizado com sucesso!',
            'Bem-vindo ao PlantApp, ${result.user!.displayName ?? 'Usuário'}');

        _navigationService.navigateToModuleHome(_moduleConfig);
      } else {
        _setError(result.errorMessage ?? 'Erro no login');
      }
    } catch (e) {
      _setError('Erro inesperado: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Método de cadastro
  Future<void> signUpWithEmail() async {
    if (!_isFormValid()) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        displayName: nameController.text.trim(),
      );

      if (result.success && result.user != null) {
        _showSuccessMessage('Conta criada com sucesso!',
            'Bem-vindo ao PlantApp, ${nameController.text}');

        _navigationService.navigateToModuleHome(_moduleConfig);
      } else {
        _setError(result.errorMessage ?? 'Erro no cadastro');
      }
    } catch (e) {
      _setError('Erro inesperado: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Reset de senha
  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _setError('Por favor, digite seu email para recuperar a senha.');
      return;
    }

    if (!_validationService.isValidEmail(email)) {
      _setError('Por favor, digite um email válido.');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.sendPasswordResetEmail(email);

      if (result.success) {
        _showSuccessMessage('Email enviado!',
            'Verifique sua caixa de entrada para recuperar sua senha.');
        hideRecoveryFormAction();
      } else {
        _setError(result.errorMessage ?? 'Erro ao enviar email');
      }
    } catch (e) {
      _setError('Erro inesperado: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Validação do formulário
  bool _isFormValid() {
    if (isSignUp.value) {
      final validations = _validationService.validateSignUpData(
        email: emailController.text,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        name: nameController.text,
      );
      return _validationService.areAllFieldsValid(validations);
    } else {
      final validations = _validationService.validateLoginData(
        emailController.text,
        passwordController.text,
      );
      return _validationService.areAllFieldsValid(validations);
    }
  }

  // Mostrar mensagem de sucesso
  void _showSuccessMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      borderRadius: 10,
    );
  }

  // Verificar força da senha
  PasswordStrength getPasswordStrength() {
    return _validationService.getPasswordStrength(passwordController.text);
  }

  // Obter mensagem de força da senha
  String getPasswordStrengthMessage() {
    final strength = getPasswordStrength();
    return _validationService.getPasswordStrengthMessage(strength);
  }

  // Logout (para usar em outras telas)
  Future<void> signOut() async {
    _setLoading(true);

    try {
      final result = await _authService.signOut();

      if (result.success) {
        _navigationService.navigateAfterLogout(_moduleConfig);
      } else {
        _setError(result.errorMessage ?? 'Erro no logout');
      }
    } catch (e) {
      _setError('Erro inesperado: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Obter usuário atual
  AuthUser? getCurrentUser() {
    return _authService.currentUser;
  }

  // Verificar se usuário está logado
  bool isUserLoggedIn() {
    return _authService.isUserLoggedIn;
  }

  // Verificar se email já existe no Firebase
  Future<bool> checkEmailExists(String email) async {
    try {
      return await _authService.checkEmailExists(email);
    } catch (e) {
      _setError('Erro ao verificar email: ${e.toString()}');
      return false;
    }
  }

  // Login anônimo para usuários mobile
  Future<void> signInAnonymously() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.signInAnonymously();

      if (result.success && result.user != null) {
        debugPrint('✅ Login anônimo realizado com sucesso: ${result.user!.id}');
        // Não navega automaticamente, deixa o app-page.dart controlar
      } else {
        _setError(result.errorMessage ?? 'Erro no login anônimo');
      }
    } catch (e) {
      _setError('Erro inesperado no login anônimo: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Métodos auxiliares para facilitar uso com widgets GetX

  /// Limpar todos os campos do formulário
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    _clearError();
  }

  /// Reset completo do controller para estado inicial
  void resetToInitialState() {
    clearForm();
    isSignUp.value = false;
    showRecoveryForm.value = false;
    obscurePassword.value = true;
    obscureConfirmPassword.value = true;
    rememberMe.value = false;
    isLoading.value = false;
    errorMessage.value = null;
  }

  /// Obter informações de debug do controller
  Map<String, dynamic> getDebugInfo() {
    return {
      'module': 'plantas',
      'state': {
        'isLoading': isLoading.value,
        'isSignUp': isSignUp.value,
        'showRecoveryForm': showRecoveryForm.value,
        'hasError': errorMessage.value != null,
      },
      'user': {
        'isLoggedIn': isUserLoggedIn(),
        'currentUser': getCurrentUser()?.id,
      },
      'form': {
        'hasEmail': emailController.text.isNotEmpty,
        'hasPassword': passwordController.text.isNotEmpty,
        'hasName': nameController.text.isNotEmpty,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/models/auth_models.dart';
import '../../core/services/auth_navigation_service.dart';
import '../../core/services/auth_validation_service.dart';
import '../../core/services/firebase_auth_service.dart';

/// Controller padronizado para autenticação do módulo GasOMeter
class GasometerAuthController extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final AuthValidationService _validationService = AuthValidationService();
  final AuthNavigationService _navigationService = AuthNavigationService();

  static const ModuleAuthConfig _moduleConfig = ModuleAuthConfig.gasometer;

  // Controllers de texto
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Estado do controller
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _showRecoveryForm = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSignUp => _isSignUp;
  bool get showRecoveryForm => _showRecoveryForm;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get rememberMe => _rememberMe;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // Métodos de UI
  void toggleAuthMode() {
    _isSignUp = !_isSignUp;
    _clearError();
    notifyListeners();
  }

  void showRecoveryFormAction() {
    _showRecoveryForm = true;
    _clearError();
    notifyListeners();
  }

  void hideRecoveryFormAction() {
    _showRecoveryForm = false;
    _clearError();
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Validações usando o service centralizado
  String? validateEmail(String? value) {
    return _validationService.validateEmailForModule(
        value, _moduleConfig.moduleName);
  }

  String? validatePassword(String? value) {
    if (_isSignUp) {
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
        _showSuccessMessage(
            'Login realizado com sucesso!', 'Bem-vindo ao GasOMeter');

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
            'Bem-vindo ao GasOMeter, ${nameController.text}');

        // Aguardar um pouco para permitir que os widgets sejam dispostos corretamente
        await Future.delayed(const Duration(milliseconds: 300));
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
      _setError('Por favor, informe seu email para recuperar a senha.');
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
    if (_isSignUp) {
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

  // Validação específica para signup password
  String? validateSignUpPassword(String? value) {
    return _validationService.validateSignUpPassword(value);
  }
}

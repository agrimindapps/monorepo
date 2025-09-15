import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_provider.dart';

/// Controller para gerenciamento do estado da tela de login do ReceitaAgro
/// Adaptado do app-gasometer para integrar com ReceitaAgroAuthProvider
class LoginController extends ChangeNotifier {
  final ReceitaAgroAuthProvider _authProvider;

  // Controllers dos campos de texto
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Estados da interface
  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  bool _isShowingRecoveryForm = false;

  LoginController({
    required ReceitaAgroAuthProvider authProvider,
  }) : _authProvider = authProvider;

  // ===== GETTERS =====
  bool get isSignUpMode => _isSignUpMode;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get rememberMe => _rememberMe;
  bool get isShowingRecoveryForm => _isShowingRecoveryForm;
  bool get isLoading => _authProvider.isLoading;
  bool get isAuthenticated => _authProvider.isAuthenticated;
  String? get errorMessage => _authProvider.errorMessage;

  // ===== TOGGLE METHODS =====

  void toggleAuthMode() {
    _isSignUpMode = !_isSignUpMode;
    clearError();
    _clearForms();
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

  void showRecoveryForm() {
    _isShowingRecoveryForm = true;
    notifyListeners();
  }

  void hideRecoveryForm() {
    _isShowingRecoveryForm = false;
    notifyListeners();
  }

  // ===== VALIDATION METHODS =====

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != passwordController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  // ===== AUTHENTICATION METHODS =====

  /// Método de login simplificado integrado com ReceitaAgroAuthProvider
  Future<void> signInWithEmailAndSync() async {
    if (kDebugMode) {
      print('🎯 LoginController: Iniciando login - ReceitaAgro');
    }

    final email = emailController.text.trim();
    final password = passwordController.text;

    // Validação local
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (emailError != null || passwordError != null) {
      if (kDebugMode) {
        print('❌ LoginController: Erro de validação - $emailError, $passwordError');
      }
      return;
    }

    try {
      final result = await _authProvider.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ LoginController: Login resultado - ${result.isSuccess}');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ LoginController: Erro no login - $e');
      }
    }
  }

  /// Método de cadastro integrado com ReceitaAgroAuthProvider
  Future<void> signUpWithEmailAndSync() async {
    if (kDebugMode) {
      print('🎯 LoginController: Iniciando cadastro - ReceitaAgro');
    }

    final email = emailController.text.trim();
    final password = passwordController.text;
    final name = nameController.text.trim();
    final confirmPassword = confirmPasswordController.text;

    // Validação local
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);
    final nameError = validateName(name);
    final confirmPasswordError = validateConfirmPassword(confirmPassword);

    if (emailError != null || passwordError != null || nameError != null || confirmPasswordError != null) {
      if (kDebugMode) {
        print('❌ LoginController: Erro de validação no cadastro');
      }
      return;
    }

    try {
      final result = await _authProvider.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );

      if (kDebugMode) {
        print('✅ LoginController: Cadastro resultado - ${result.isSuccess}');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ LoginController: Erro no cadastro - $e');
      }
    }
  }

  /// Método de recuperação de senha
  Future<void> sendPasswordReset() async {
    if (kDebugMode) {
      print('🎯 LoginController: Enviando email de recuperação');
    }

    final email = emailController.text.trim();

    final emailError = validateEmail(email);
    if (emailError != null) {
      if (kDebugMode) {
        print('❌ LoginController: Erro de validação no email de recuperação');
      }
      return;
    }

    try {
      await _authProvider.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        print('✅ LoginController: Email de recuperação enviado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ LoginController: Erro ao enviar email de recuperação - $e');
      }
    }
  }

  // ===== UTILITY METHODS =====

  void clearError() {
    _authProvider.clearError();
  }

  void _clearForms() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
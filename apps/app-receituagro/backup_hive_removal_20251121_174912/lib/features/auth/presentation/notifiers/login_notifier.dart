import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/receituagro_auth_notifier.dart';
import '../../services/auth_validation_service.dart';
import '../state/login_state.dart';

part 'login_notifier.g.dart';

/// Riverpod Notifier for login feature
/// Manages authentication flows: login, signup, and password recovery
@riverpod
class LoginNotifier extends _$LoginNotifier {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  late final TextEditingController _confirmPasswordController;
  late final AuthValidationService _validationService;

  @override
  LoginState build() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _validationService = AuthValidationService();
    ref.onDispose(() {
      _emailController.dispose();
      _passwordController.dispose();
      _nameController.dispose();
      _confirmPasswordController.dispose();
    });
    return LoginState.initial(
      emailController: _emailController,
      passwordController: _passwordController,
      nameController: _nameController,
      confirmPasswordController: _confirmPasswordController,
    );
  }

  /// Helper para acessar o auth notifier via Riverpod
  ReceitaAgroAuthNotifier get _authNotifier =>
      ref.read(receitaAgroAuthNotifierProvider.notifier);

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get nameController => _nameController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;

  void toggleAuthMode() {
    state = state.copyWith(isSignUpMode: !state.isSignUpMode, clearError: true);
    _clearForms();
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  void showRecoveryForm() {
    state = state.copyWith(isShowingRecoveryForm: true);
  }

  void hideRecoveryForm() {
    state = state.copyWith(isShowingRecoveryForm: false);
  }

  String? validateEmail(String? value) {
    return _validationService
        .validateEmail(value)
        .fold((error) => error, (_) => null);
  }

  String? validatePassword(String? value) {
    return _validationService
        .validatePassword(value)
        .fold((error) => error, (_) => null);
  }

  String? validateName(String? value) {
    return _validationService
        .validateName(value)
        .fold((error) => error, (_) => null);
  }

  String? validateConfirmPassword(String? value) {
    return _validationService
        .validateConfirmPassword(value, _passwordController.text)
        .fold((error) => error, (_) => null);
  }

  /// Login with email and password
  Future<void> signInWithEmailAndSync() async {
    if (kDebugMode) {
      print('🎯 LoginNotifier: Iniciando login - ReceitaAgro');
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final validation = _validationService.validateLoginForm(
      email: email,
      password: password,
    );

    if (validation.isLeft()) {
      final errorMessage = validation.fold((error) => error, (_) => '');
      if (kDebugMode) {
        print('❌ LoginNotifier: Erro de validação - $errorMessage');
      }
      state = state.copyWith(errorMessage: errorMessage);
      return;
    }

    // Atualiza state para loading
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authNotifier.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ LoginNotifier: Login resultado - ${result.isSuccess}');
      }

      // Atualiza state baseado no resultado
      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: result.errorMessage ?? 'Erro ao fazer login',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ LoginNotifier: Erro no login - $e');
      }
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Erro inesperado ao fazer login',
      );
    }
  }

  /// Signup with email, password and name
  Future<void> signUpWithEmailAndSync() async {
    if (kDebugMode) {
      print('🎯 LoginNotifier: Iniciando cadastro - ReceitaAgro');
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    final confirmPassword = _confirmPasswordController.text;

    final validation = _validationService.validateSignupForm(
      email: email,
      password: password,
      name: name,
      confirmPassword: confirmPassword,
    );

    if (validation.isLeft()) {
      final errorMessage = validation.fold((error) => error, (_) => '');
      if (kDebugMode) {
        print('❌ LoginNotifier: Erro de validação no cadastro - $errorMessage');
      }
      state = state.copyWith(errorMessage: errorMessage);
      return;
    }

    // Atualiza state para loading
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authNotifier.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );

      if (kDebugMode) {
        print('✅ LoginNotifier: Cadastro resultado - ${result.isSuccess}');
      }

      // Atualiza state baseado no resultado
      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: result.errorMessage ?? 'Erro ao criar conta',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ LoginNotifier: Erro no cadastro - $e');
      }
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Erro inesperado ao criar conta',
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordReset() async {
    if (kDebugMode) {
      print('🎯 LoginNotifier: Enviando email de recuperação');
    }

    final email = _emailController.text.trim();

    final validation = _validationService.validateEmail(email);
    if (validation.isLeft()) {
      final errorMessage = validation.fold((error) => error, (_) => '');
      if (kDebugMode) {
        print(
          '❌ LoginNotifier: Erro de validação no email de recuperação - $errorMessage',
        );
      }
      state = state.copyWith(errorMessage: errorMessage);
      return;
    }

    // Atualiza state para loading
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authNotifier.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        print('✅ LoginNotifier: Email de recuperação enviado');
      }
      state = state.copyWith(isLoading: false, clearError: true);
    } catch (e) {
      if (kDebugMode) {
        print('❌ LoginNotifier: Erro ao enviar email de recuperação - $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao enviar email de recuperação',
      );
    }
  }

  void clearError() {
    _authNotifier.clearError();
    state = state.copyWith(clearError: true);
  }

  void _clearForms() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _confirmPasswordController.clear();
  }
}

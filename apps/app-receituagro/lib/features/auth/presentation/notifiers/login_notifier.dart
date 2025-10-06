import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/providers/receituagro_auth_notifier.dart';
import '../state/login_state.dart';

part 'login_notifier.g.dart';

/// Riverpod Notifier for login feature
/// Manages authentication flows: login, signup, and password recovery
@riverpod
class LoginNotifier extends _$LoginNotifier {
  late final ReceitaAgroAuthNotifier _authNotifier;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  late final TextEditingController _confirmPasswordController;

  @override
  LoginState build() {
    _authNotifier = di.sl<ReceitaAgroAuthNotifier>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _confirmPasswordController = TextEditingController();
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

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get nameController => _nameController;
  TextEditingController get confirmPasswordController => _confirmPasswordController;

  void toggleAuthMode() {
    state = state.copyWith(
      isSignUpMode: !state.isSignUpMode,
      clearError: true,
    );
    _clearForms();
  }

  void togglePasswordVisibility() {
    state = state.copyWith(
      obscurePassword: !state.obscurePassword,
    );
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  void toggleRememberMe() {
    state = state.copyWith(
      rememberMe: !state.rememberMe,
    );
  }

  void showRecoveryForm() {
    state = state.copyWith(
      isShowingRecoveryForm: true,
    );
  }

  void hideRecoveryForm() {
    state = state.copyWith(
      isShowingRecoveryForm: false,
    );
  }

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
    if (value != _passwordController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  /// Login with email and password
  Future<void> signInWithEmailAndSync() async {
    if (kDebugMode) {
      print('🎯 LoginNotifier: Iniciando login - ReceitaAgro');
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (emailError != null || passwordError != null) {
      if (kDebugMode) {
        print('❌ LoginNotifier: Erro de validação - $emailError, $passwordError');
      }
      return;
    }

    try {
      final result = await _authNotifier.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ LoginNotifier: Login resultado - ${result.isSuccess}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ LoginNotifier: Erro no login - $e');
      }
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
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);
    final nameError = validateName(name);
    final confirmPasswordError = validateConfirmPassword(confirmPassword);

    if (emailError != null || passwordError != null || nameError != null || confirmPasswordError != null) {
      if (kDebugMode) {
        print('❌ LoginNotifier: Erro de validação no cadastro');
      }
      return;
    }

    try {
      final result = await _authNotifier.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );

      if (kDebugMode) {
        print('✅ LoginNotifier: Cadastro resultado - ${result.isSuccess}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ LoginNotifier: Erro no cadastro - $e');
      }
    }
  }

  /// Send password reset email
  Future<void> sendPasswordReset() async {
    if (kDebugMode) {
      print('🎯 LoginNotifier: Enviando email de recuperação');
    }

    final email = _emailController.text.trim();

    final emailError = validateEmail(email);
    if (emailError != null) {
      if (kDebugMode) {
        print('❌ LoginNotifier: Erro de validação no email de recuperação');
      }
      return;
    }

    try {
      await _authNotifier.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        print('✅ LoginNotifier: Email de recuperação enviado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ LoginNotifier: Erro ao enviar email de recuperação - $e');
      }
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

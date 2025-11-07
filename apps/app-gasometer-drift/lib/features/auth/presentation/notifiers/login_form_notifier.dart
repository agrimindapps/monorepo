import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import 'login_form_state.dart';

part 'login_form_notifier.g.dart';

/// Notifier Riverpod para gerenciar o estado do formulário de login
@riverpod
class LoginFormNotifier extends _$LoginFormNotifier {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController nameController;
  late final TextEditingController confirmPasswordController;
  late final SignInWithEmail _signInWithEmail;
  late final SignUpWithEmail _signUpWithEmail;
  late final SignInAnonymously _signInAnonymously;

  @override
  LoginFormState build() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    confirmPasswordController = TextEditingController();
    _signInWithEmail = getIt<SignInWithEmail>();
    _signUpWithEmail = getIt<SignUpWithEmail>();
    _signInAnonymously = getIt<SignInAnonymously>();
    ref.onDispose(() {
      emailController.dispose();
      passwordController.dispose();
      nameController.dispose();
      confirmPasswordController.dispose();
    });
    _loadSavedData();

    return const LoginFormState();
  }

  /// Alterna visibilidade da senha
  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  /// Alterna visibilidade da confirmação de senha
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  /// Alterna estado do "lembrar-me"
  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  /// Limpa mensagem de erro
  void clearError() {
    state = state.clearError();
  }

  /// Exibe formulário de recuperação de senha
  void showRecoveryForm() {
    state = state.copyWith(showRecoveryForm: true);
  }

  /// Oculta formulário de recuperação de senha
  void hideRecoveryForm() {
    state = state.copyWith(showRecoveryForm: false);
  }

  /// Atualiza modo de formulário (login/signup)
  void setSignUpMode(bool isSignUp) {
    state = state.copyWith(isSignUpMode: isSignUp);
  }

  /// Faz login com email e senha
  Future<bool> signInWithEmail() async {
    if (!_validateLoginForm()) return false;

    state = state.copyWith(isLoading: true, errorMessage: () => null);

    try {
      final params = SignInWithEmailParams(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final result = await _signInWithEmail(params);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
          return false;
        },
        (user) {
          state = state.copyWith(isLoading: false);
          if (state.rememberMe) {
            _saveFormData();
          }
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro inesperado durante o login',
      );
      return false;
    }
  }

  /// Cadastra novo usuário com email e senha
  Future<bool> signUpWithEmail() async {
    if (!_validateSignUpForm()) return false;

    state = state.copyWith(isLoading: true, errorMessage: () => null);

    try {
      final params = SignUpWithEmailParams(
        email: emailController.text.trim(),
        password: passwordController.text,
        displayName: nameController.text.trim(),
      );

      final result = await _signUpWithEmail(params);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
          return false;
        },
        (user) {
          state = state.copyWith(isLoading: false);
          if (state.rememberMe) {
            _saveFormData();
          }
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro inesperado durante o cadastro',
      );
      return false;
    }
  }

  /// Faz login anônimo
  Future<bool> signInAnonymously() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);

    try {
      final result = await _signInAnonymously();

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
          return false;
        },
        (user) {
          state = state.copyWith(isLoading: false);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro durante login anônimo',
      );
      return false;
    }
  }

  /// Valida formulário de login
  bool _validateLoginForm() {
    if (emailController.text.trim().isEmpty) {
      state = state.copyWith(errorMessage: () => 'Email é obrigatório');
      return false;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      state = state.copyWith(errorMessage: () => 'Email inválido');
      return false;
    }

    if (passwordController.text.isEmpty) {
      state = state.copyWith(errorMessage: () => 'Senha é obrigatória');
      return false;
    }

    return true;
  }

  /// Valida formulário de cadastro
  bool _validateSignUpForm() {
    if (nameController.text.trim().isEmpty) {
      state = state.copyWith(errorMessage: () => 'Nome é obrigatório');
      return false;
    }

    if (nameController.text.trim().length < 2) {
      state = state.copyWith(
        errorMessage: () => 'Nome deve ter pelo menos 2 caracteres',
      );
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      state = state.copyWith(errorMessage: () => 'Email é obrigatório');
      return false;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      state = state.copyWith(errorMessage: () => 'Email inválido');
      return false;
    }

    if (passwordController.text.length < 6) {
      state = state.copyWith(
        errorMessage: () => 'Senha deve ter pelo menos 6 caracteres',
      );
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      state = state.copyWith(errorMessage: () => 'Senhas não coincidem');
      return false;
    }

    return true;
  }

  /// Valida formato de email
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  /// Valida campo de nome
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  /// Valida campo de email
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    if (!_isValidEmail(value.trim())) {
      return 'Email inválido';
    }
    return null;
  }

  /// Valida campo de senha
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  /// Valida campo de confirmação de senha
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != passwordController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  /// Carrega dados salvos do SharedPreferences
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedName = prefs.getString('gasometer_saved_name');
      final savedEmail = prefs.getString('gasometer_saved_email');
      final savedRememberMe = prefs.getBool('gasometer_remember_me') ?? false;

      if (savedName != null && savedName.isNotEmpty) {
        nameController.text = savedName;
      }

      if (savedEmail != null && savedEmail.isNotEmpty) {
        emailController.text = savedEmail;
      }

      state = state.copyWith(rememberMe: savedRememberMe);
    } catch (e) {
    }
  }

  /// Salva dados do formulário no SharedPreferences
  Future<void> _saveFormData() async {
    if (!state.rememberMe) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      if (nameController.text.trim().isNotEmpty) {
        await prefs.setString(
          'gasometer_saved_name',
          nameController.text.trim(),
        );
      }

      if (emailController.text.trim().isNotEmpty) {
        await prefs.setString(
          'gasometer_saved_email',
          emailController.text.trim(),
        );
      }

      await prefs.setBool('gasometer_remember_me', state.rememberMe);
    } catch (e) {
    }
  }
}

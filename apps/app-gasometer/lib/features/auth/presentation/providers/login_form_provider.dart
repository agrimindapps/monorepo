import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Estado do formulário de login
class LoginFormState {
  const LoginFormState({
    this.emailController,
    this.passwordController,
    this.nameController,
    this.confirmPasswordController,
    this.isLoading = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.rememberMe = false,
    this.errorMessage,
    this.isSignUpMode = false,
    this.showRecoveryForm = false,
  });

  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final TextEditingController? nameController;
  final TextEditingController? confirmPasswordController;
  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool rememberMe;
  final String? errorMessage;
  final bool isSignUpMode;
  final bool showRecoveryForm;

  LoginFormState copyWith({
    TextEditingController? emailController,
    TextEditingController? passwordController,
    TextEditingController? nameController,
    TextEditingController? confirmPasswordController,
    bool? isLoading,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? rememberMe,
    String? errorMessage,
    bool? isSignUpMode,
    bool? showRecoveryForm,
  }) {
    return LoginFormState(
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      nameController: nameController ?? this.nameController,
      confirmPasswordController: confirmPasswordController ?? this.confirmPasswordController,
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: errorMessage,
      isSignUpMode: isSignUpMode ?? this.isSignUpMode,
      showRecoveryForm: showRecoveryForm ?? this.showRecoveryForm,
    );
  }
}

/// Notifier para gerenciar o estado do formulário de login
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier(this._authService) : super(const LoginFormState()) {
    _initializeControllers();
    _loadSavedData();
  }

  final FirebaseAuthService _authService;

  void _initializeControllers() {
    state = state.copyWith(
      emailController: TextEditingController(),
      passwordController: TextEditingController(),
      nameController: TextEditingController(),
      confirmPasswordController: TextEditingController(),
    );
  }

  @override
  void dispose() {
    state.emailController?.dispose();
    state.passwordController?.dispose();
    state.nameController?.dispose();
    state.confirmPasswordController?.dispose();
    super.dispose();
  }

  // Actions
  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void showRecoveryForm() {
    state = state.copyWith(showRecoveryForm: true);
  }

  void hideRecoveryForm() {
    state = state.copyWith(showRecoveryForm: false);
  }

  // Authentication methods
  Future<bool> signInWithEmail() async {
    if (!_validateLoginForm()) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: state.emailController!.text.trim(),
        password: state.passwordController!.text,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
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
        errorMessage: 'Erro inesperado durante o login',
      );
      return false;
    }
  }

  Future<bool> signUpWithEmail() async {
    if (!_validateSignUpForm()) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authService.signUpWithEmailAndPassword(
        email: state.emailController!.text.trim(),
        password: state.passwordController!.text,
        displayName: state.nameController!.text.trim(),
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
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
        errorMessage: 'Erro inesperado durante o cadastro',
      );
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authService.signInAnonymously();

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
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
        errorMessage: 'Erro durante login anônimo',
      );
      return false;
    }
  }

  // Validation methods
  bool _validateLoginForm() {
    if (state.emailController!.text.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Email é obrigatório');
      return false;
    }

    if (!_isValidEmail(state.emailController!.text.trim())) {
      state = state.copyWith(errorMessage: 'Email inválido');
      return false;
    }

    if (state.passwordController!.text.isEmpty) {
      state = state.copyWith(errorMessage: 'Senha é obrigatória');
      return false;
    }

    return true;
  }

  bool _validateSignUpForm() {
    if (state.nameController!.text.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Nome é obrigatório');
      return false;
    }

    if (state.nameController!.text.trim().length < 2) {
      state = state.copyWith(errorMessage: 'Nome deve ter pelo menos 2 caracteres');
      return false;
    }

    if (state.emailController!.text.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Email é obrigatório');
      return false;
    }

    if (!_isValidEmail(state.emailController!.text.trim())) {
      state = state.copyWith(errorMessage: 'Email inválido');
      return false;
    }

    if (state.passwordController!.text.length < 6) {
      state = state.copyWith(errorMessage: 'Senha deve ter pelo menos 6 caracteres');
      return false;
    }

    if (state.passwordController!.text != state.confirmPasswordController!.text) {
      state = state.copyWith(errorMessage: 'Senhas não coincidem');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Field validators for TextFields
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    if (!_isValidEmail(value.trim())) {
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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != state.passwordController!.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  // Private methods for data persistence
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedName = prefs.getString('gasometer_saved_name');
      final savedEmail = prefs.getString('gasometer_saved_email');
      final savedRememberMe = prefs.getBool('gasometer_remember_me') ?? false;

      if (savedName != null && savedName.isNotEmpty) {
        state.nameController?.text = savedName;
      }

      if (savedEmail != null && savedEmail.isNotEmpty) {
        state.emailController?.text = savedEmail;
      }

      state = state.copyWith(rememberMe: savedRememberMe);
    } catch (e) {
      // Ignore errors loading saved data
    }
  }

  Future<void> _saveFormData() async {
    if (!state.rememberMe) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      if (state.nameController!.text.trim().isNotEmpty) {
        await prefs.setString('gasometer_saved_name', state.nameController!.text.trim());
      }

      if (state.emailController!.text.trim().isNotEmpty) {
        await prefs.setString('gasometer_saved_email', state.emailController!.text.trim());
      }

      await prefs.setBool('gasometer_remember_me', state.rememberMe);
    } catch (e) {
      // Ignore errors saving data
    }
  }
}

/// Provider para o formulário de login
final loginFormProvider = StateNotifierProvider<LoginFormNotifier, LoginFormState>((ref) {
  final authService = FirebaseAuthService();
  return LoginFormNotifier(authService);
});
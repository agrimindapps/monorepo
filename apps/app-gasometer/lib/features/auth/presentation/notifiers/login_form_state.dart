import 'package:equatable/equatable.dart';

/// Estado do formulário de login usando valores primitivos
/// (TextEditingControllers gerenciados internamente pelo notifier)
class LoginFormState extends Equatable {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.name = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.rememberMe = false,
    this.errorMessage,
    this.isSignUpMode = false,
    this.showRecoveryForm = false,
  });

  final String email;
  final String password;
  final String name;
  final String confirmPassword;
  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool rememberMe;
  final String? errorMessage;
  final bool isSignUpMode;
  final bool showRecoveryForm;

  /// Cria uma cópia do estado com valores atualizados
  LoginFormState copyWith({
    String? email,
    String? password,
    String? name,
    String? confirmPassword,
    bool? isLoading,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? rememberMe,
    String? Function()? errorMessage,
    bool? isSignUpMode,
    bool? showRecoveryForm,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isSignUpMode: isSignUpMode ?? this.isSignUpMode,
      showRecoveryForm: showRecoveryForm ?? this.showRecoveryForm,
    );
  }

  /// Limpa mensagem de erro
  LoginFormState clearError() {
    return copyWith(errorMessage: () => null);
  }

  @override
  List<Object?> get props => [
        email,
        password,
        name,
        confirmPassword,
        isLoading,
        obscurePassword,
        obscureConfirmPassword,
        rememberMe,
        errorMessage,
        isSignUpMode,
        showRecoveryForm,
      ];
}

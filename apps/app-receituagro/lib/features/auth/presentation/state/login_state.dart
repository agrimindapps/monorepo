import 'package:flutter/material.dart';

/// Immutable state for the login feature
/// Manages auth mode, UI states, and form visibility
class LoginState {
  // Auth modes
  final bool isSignUpMode;
  final bool isShowingRecoveryForm;

  // Password visibility
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  // Form state
  final bool rememberMe;

  // Loading and error states (from auth provider)
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  // Text editing controllers (managed by page, not state)
  // Stored here for convenience
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final TextEditingController confirmPasswordController;

  const LoginState({
    required this.isSignUpMode,
    required this.isShowingRecoveryForm,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.rememberMe,
    required this.isLoading,
    required this.isAuthenticated,
    this.errorMessage,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.confirmPasswordController,
  });

  /// Initial state factory
  factory LoginState.initial({
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController nameController,
    required TextEditingController confirmPasswordController,
  }) {
    return LoginState(
      isSignUpMode: false,
      isShowingRecoveryForm: false,
      obscurePassword: true,
      obscureConfirmPassword: true,
      rememberMe: false,
      isLoading: false,
      isAuthenticated: false,
      errorMessage: null,
      emailController: emailController,
      passwordController: passwordController,
      nameController: nameController,
      confirmPasswordController: confirmPasswordController,
    );
  }

  /// Copy with method for immutability
  LoginState copyWith({
    bool? isSignUpMode,
    bool? isShowingRecoveryForm,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? rememberMe,
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      isSignUpMode: isSignUpMode ?? this.isSignUpMode,
      isShowingRecoveryForm: isShowingRecoveryForm ?? this.isShowingRecoveryForm,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      rememberMe: rememberMe ?? this.rememberMe,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      emailController: emailController,
      passwordController: passwordController,
      nameController: nameController,
      confirmPasswordController: confirmPasswordController,
    );
  }
}

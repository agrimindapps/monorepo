import 'package:core/core.dart' hide AuthState, FormState;
import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';

/// **Registration Page Coordinator**
/// 
/// Handles business logic, navigation, and error management for the
/// registration page. This coordinator separates concerns by managing
/// authentication flows while delegating UI presentation to widgets.
/// 
/// ## Responsibilities:
/// - **Authentication Flow**: Manages registration and social auth
/// - **Navigation Logic**: Handles success/failure navigation
/// - **Error Handling**: Provides user-friendly error messages
/// - **State Management**: Coordinates with auth provider
/// 
/// @author PetiVeti Development Team
/// @since 1.0.0
/// @version 1.3.0 - Enhanced error handling and navigation flow
abstract class RegisterPageCoordinator {
  
  /// **Handle Registration Form Submission**
  /// 
  /// Processes user registration with email and password after validating
  /// form data and terms acceptance. Shows appropriate success or error
  /// messages based on the registration result.
  /// 
  /// @param ref Widget reference for provider access
  /// @param context Build context for navigation and messages
  /// @param name User's full name
  /// @param email User's email address
  /// @param password User's password
  /// @param termsAccepted Whether terms were accepted
  static Future<void> handleRegistration({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required bool termsAccepted,
  }) async {
    if (!termsAccepted) {
      _showError(
        context,
        'Você deve aceitar os termos e condições',
        color: Colors.orange,
      );
      return;
    }

    try {
      final success = await ref.read(authProvider.notifier).signUpWithEmail(
        email.trim().toLowerCase(),
        password,
        name.trim(),
      );

      if (success && context.mounted) {
        _showSuccess(
          context,
          'Conta criada com sucesso! Verifique seu email.',
          duration: const Duration(seconds: 4),
        );
      }
    } catch (error) {
      if (context.mounted) {
        _showError(context, 'Erro ao criar conta: $error');
      }
    }
  }

  /// **Handle Google Sign-In**
  /// 
  /// Initiates Google authentication flow and handles the result.
  /// 
  /// @param ref Widget reference for provider access
  /// @param context Build context for error messages
  static Future<void> handleGoogleSignIn({
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } catch (error) {
      if (context.mounted) {
        _showError(context, 'Erro no login com Google: $error');
      }
    }
  }

  /// **Handle Apple Sign-In**
  /// 
  /// Initiates Apple authentication flow and handles the result.
  /// Only available on supported platforms.
  /// 
  /// @param ref Widget reference for provider access
  /// @param context Build context for error messages
  static Future<void> handleAppleSignIn({
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    try {
      await ref.read(authProvider.notifier).signInWithApple();
    } catch (error) {
      if (context.mounted) {
        _showError(context, 'Erro no login com Apple: $error');
      }
    }
  }

  /// **Setup Authentication State Listener**
  /// 
  /// Configures listener for authentication state changes to handle
  /// navigation and error display automatically.
  /// 
  /// @param ref Widget reference for provider access
  /// @param context Build context for navigation and messages
  static void setupAuthListener({
    required WidgetRef ref,
    required BuildContext context,
  }) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated == true && context.mounted) {
        context.go('/');
      }
      
      if (next.hasError == true && context.mounted) {
        _showError(context, next.error ?? 'Erro desconhecido');
        ref.read(authProvider.notifier).clearError();
      }
    });
  }

  /// **Navigate to Login Page**
  /// 
  /// Handles navigation back to login page for existing users.
  /// 
  /// @param context Build context for navigation
  static void navigateToLogin(BuildContext context) {
    context.go('/login');
  }

  /// **Show Error Message**
  /// 
  /// Displays user-friendly error message using SnackBar.
  /// 
  /// @param context Build context for SnackBar
  /// @param message Error message to display
  /// @param color Optional custom color (defaults to red)
  static void _showError(
    BuildContext context,
    String message, {
    Color color = Colors.red,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// **Show Success Message**
  /// 
  /// Displays success message using SnackBar with positive styling.
  /// 
  /// @param context Build context for SnackBar
  /// @param message Success message to display
  /// @param duration Optional custom duration
  static void _showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// **Validate Registration Form**
  /// 
  /// Validates complete form data before submission.
  /// 
  /// @param formKey Global form key for validation
  /// @param termsAccepted Whether terms are accepted
  /// @return Whether form is valid and ready for submission
  static bool validateRegistrationForm({
    required GlobalKey<FormState> formKey,
    required bool termsAccepted,
  }) {
    if (!(formKey.currentState?.validate() == true)) {
      return false;
    }

    return termsAccepted;
  }
}

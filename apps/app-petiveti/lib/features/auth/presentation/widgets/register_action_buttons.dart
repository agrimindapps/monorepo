import 'package:core/core.dart' hide AuthState, FormState;
import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import 'register_page_coordinator.dart';

/// **Register Action Buttons Widget**
/// 
/// A specialized widget for handling registration form actions including
/// the main registration button and navigation link to login page.
/// 
/// ## Key Features:
/// - **Registration Button**: Main CTA with loading states and validation
/// - **Login Navigation**: Link for existing users to access login
/// - **State Management**: Integrates with auth provider for loading states
/// - **Accessibility**: Full semantic support and screen reader compatibility
/// 
/// ## Button States:
/// - **Enabled**: When form is valid and terms are accepted
/// - **Disabled**: When form is invalid or terms not accepted
/// - **Loading**: During registration process with loading indicator
/// 
/// ## Design Principles:
/// - Single Responsibility: Focuses only on action buttons
/// - Reusability: Can be used in different registration contexts
/// - Consistency: Follows app-wide button styling patterns
/// - Accessibility: Includes proper semantic labels and hints
/// 
/// @author PetiVeti Development Team
/// @since 1.1.0
class RegisterActionButtons extends ConsumerWidget {
  /// Creates register action buttons widget.
  /// 
  /// **Parameters:**
  /// - [formKey]: Global form key for validation
  /// - [nameController]: Text controller for name input
  /// - [emailController]: Text controller for email input
  /// - [passwordController]: Text controller for password input
  /// - [acceptedTerms]: Whether user has accepted terms and conditions
  const RegisterActionButtons({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.acceptedTerms,
  });

  /// Global form key for validation state
  final GlobalKey<FormState> formKey;
  
  /// Text controller for name input field
  final TextEditingController nameController;
  
  /// Text controller for email input field
  final TextEditingController emailController;
  
  /// Text controller for password input field
  final TextEditingController passwordController;
  
  /// Whether user has accepted terms and conditions
  final bool acceptedTerms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRegisterButton(context, ref, authState),
        const SizedBox(height: 16),
        _buildLoginLink(context),
      ],
    );
  }

  /// **Register Button Widget**
  /// 
  /// Main registration button with loading state and validation.
  /// Disabled when form is invalid or terms are not accepted.
  Widget _buildRegisterButton(BuildContext context, WidgetRef ref, AuthState authState) {
    final isLoading = authState.isLoading == true;
    final canProceed = acceptedTerms && !isLoading;

    return Semantics(
      label: 'Criar nova conta de usuário',
      hint: canProceed 
          ? 'Toque para criar sua conta com as informações fornecidas'
          : 'Preencha todos os campos e aceite os termos para prosseguir',
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: canProceed ? () => _handleRegister(context, ref) : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: canProceed ? 2 : 0,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Criando Conta...',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Criar Conta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// **Login Link Widget**
  /// 
  /// Link for existing users to navigate back to login page.
  /// Provides alternative navigation path for users who already have accounts.
  Widget _buildLoginLink(BuildContext context) {
    return Semantics(
      label: 'Navegar para página de login',
      hint: 'Para usuários que já possuem conta cadastrada',
      button: true,
      child: TextButton(
        onPressed: () => RegisterPageCoordinator.navigateToLogin(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: 'Já tem uma conta? ',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              TextSpan(
                text: 'Faça login',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Handle Registration Form Submission**
  /// 
  /// Processes registration form using the coordinator.
  /// Validates form and submits registration request.
  Future<void> _handleRegister(BuildContext context, WidgetRef ref) async {
    if (!RegisterPageCoordinator.validateRegistrationForm(
      formKey: formKey,
      termsAccepted: acceptedTerms,
    )) {
      return;
    }
    await RegisterPageCoordinator.handleRegistration(
      ref: ref,
      context: context,
      name: nameController.text.trim(),
      email: emailController.text.trim().toLowerCase(),
      password: passwordController.text,
      termsAccepted: acceptedTerms,
    );
  }
}
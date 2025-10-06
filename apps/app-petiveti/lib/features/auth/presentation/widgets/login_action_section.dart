import 'package:core/core.dart' hide AuthState, FormState;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';

/// **Login Action Section Widget**
/// 
/// A comprehensive action section for authentication that handles primary
/// authentication actions, mode switching, and additional user options.
/// 
/// ## Key Features:
/// - **Primary Action Button**: Main login/signup button with loading states
/// - **Mode Switching**: Toggle between login and registration modes
/// - **Forgot Password**: Password recovery option for existing users
/// - **Enhanced Loading**: Multi-stage loading feedback with messages
/// - **Social Authentication**: Integration points for social login
/// 
/// ## Button States:
/// - **Normal State**: Ready for user interaction
/// - **Loading State**: Processing authentication with progress feedback
/// - **Disabled State**: Form validation prevents interaction
/// - **Enhanced Loading**: Multi-step loading with informative messages
/// 
/// ## Accessibility Features:
/// - Semantic labels for all action buttons
/// - Loading state announcements
/// - High contrast support
/// - Keyboard navigation compatibility
/// 
/// @author PetiVeti Development Team
/// @since 1.1.0
class LoginActionSection extends ConsumerWidget {
  /// Creates a login action section widget.
  /// 
  /// **Parameters:**
  /// - [formKey]: Global form key for validation
  /// - [emailController]: Controller for email input
  /// - [passwordController]: Controller for password input
  /// - [isSignUp]: Whether form is in sign-up mode
  /// - [rememberMe]: Whether remember me option is selected
  /// - [isAuthenticating]: Whether enhanced authentication is active
  /// - [loadingMessage]: Current loading message for enhanced feedback
  /// - [onModeToggle]: Callback for switching between login/signup modes
  /// - [onAuthenticationSubmit]: Callback for form submission
  /// - [onForgotPassword]: Callback for forgot password action
  /// - [onSocialAuth]: Callback for social authentication
  const LoginActionSection({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isSignUp,
    required this.rememberMe,
    required this.isAuthenticating,
    required this.loadingMessage,
    required this.onModeToggle,
    required this.onAuthenticationSubmit,
    required this.onForgotPassword,
    required this.onSocialAuth,
  });

  /// Global form key for validation
  final GlobalKey<FormState> formKey;
  
  /// Controller for email input field
  final TextEditingController emailController;
  
  /// Controller for password input field
  final TextEditingController passwordController;
  
  /// Whether form is in sign-up mode
  final bool isSignUp;
  
  /// Whether remember me option is selected
  final bool rememberMe;
  
  /// Whether enhanced authentication is active
  final bool isAuthenticating;
  
  /// Current loading message for enhanced feedback
  final String loadingMessage;
  
  /// Callback for switching between login/signup modes
  final VoidCallback onModeToggle;
  
  /// Callback for form submission
  final VoidCallback onAuthenticationSubmit;
  
  /// Callback for forgot password action
  final VoidCallback onForgotPassword;
  
  /// Callback for social authentication
  final ValueChanged<String> onSocialAuth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPrimaryActionButton(context, authState),
        const SizedBox(height: 16),
        _buildModeToggleButton(context),
        if (!isSignUp) ...[
          _buildForgotPasswordButton(context),
        ],
        const SizedBox(height: 32),
        _buildDivider(context),
        const SizedBox(height: 24),
        _buildSocialAuthSection(context),
        if (kDebugMode) ...[
          const SizedBox(height: 32),
          _buildDemoLoginInfo(context),
        ],
      ],
    );
  }

  /// **Primary Action Button**
  /// 
  /// Main authentication button with enhanced loading states and validation.
  Widget _buildPrimaryActionButton(BuildContext context, AuthState authState) {
    final isLoading = (authState.isLoading == true) || isAuthenticating;
    final canSubmit = !isLoading;

    return Semantics(
      label: isSignUp 
          ? 'Criar nova conta de usuário'
          : 'Fazer login com credenciais fornecidas',
      hint: canSubmit
          ? (isSignUp 
              ? 'Toque para criar conta com email e senha fornecidos'
              : 'Toque para fazer login com email e senha fornecidos')
          : 'Aguarde o processamento da solicitação anterior',
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: isAuthenticating ? 80 : 56,
        child: ElevatedButton(
          onPressed: canSubmit ? onAuthenticationSubmit : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isAuthenticating ? 12 : 8),
            ),
            elevation: canSubmit ? 2 : 0,
          ),
          child: _buildButtonContent(context, authState),
        ),
      ),
    );
  }

  /// **Button Content Builder**
  /// 
  /// Creates appropriate button content based on loading state.
  Widget _buildButtonContent(BuildContext context, AuthState authState) {
    if (isAuthenticating) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 8),
          Text(
            loadingMessage,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (authState.isLoading == true) {
      return CircularProgressIndicator(
        color: Theme.of(context).colorScheme.onPrimary,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(isSignUp ? Icons.person_add : Icons.login),
        const SizedBox(width: 8),
        Text(
          isSignUp ? 'Criar Conta' : 'Entrar',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// **Mode Toggle Button**
  /// 
  /// Button to switch between login and registration modes.
  Widget _buildModeToggleButton(BuildContext context) {
    return Semantics(
      label: isSignUp 
          ? 'Alternar para modo de login'
          : 'Alternar para modo de cadastro',
      hint: isSignUp 
          ? 'Para usuários que já possuem conta'
          : 'Para novos usuários que precisam criar conta',
      button: true,
      child: TextButton(
        onPressed: onModeToggle,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isSignUp 
                ? 'Já tem uma conta? Faça login'
                : 'Não tem conta? Cadastre-se',
            key: ValueKey(isSignUp),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  /// **Forgot Password Button**
  /// 
  /// Button for password recovery option (login mode only).
  Widget _buildForgotPasswordButton(BuildContext context) {
    return Semantics(
      label: 'Recuperar senha esquecida',
      hint: 'Inicia processo de recuperação de senha por email',
      button: true,
      child: TextButton(
        onPressed: onForgotPassword,
        child: Text(
          'Esqueceu a senha?',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// **Section Divider**
  /// 
  /// Visual separator between main actions and social authentication.
  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  /// **Social Authentication Section**
  /// 
  /// Buttons for social login options (Google, Apple).
  Widget _buildSocialAuthSection(BuildContext context) {
    return Column(
      children: [
        _buildSocialButton(
          context,
          'Continuar com Google',
          Icons.g_mobiledata,
          Colors.red,
          () => onSocialAuth('google'),
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          context,
          'Continuar com Apple',
          Icons.apple,
          Colors.black,
          () => onSocialAuth('apple'),
        ),
      ],
    );
  }

  /// **Social Authentication Button**
  /// 
  /// Individual social login button with consistent styling.
  Widget _buildSocialButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Semantics(
      label: 'Autenticação social: $text',
      hint: 'Fazer login usando conta externa',
      button: true,
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: color),
          label: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  /// **Demo Login Information**
  /// 
  /// Development-only information panel with demo credentials.
  Widget _buildDemoLoginInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.developer_mode,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Demo Login (Development Only)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Email: test@example.com\nSenha: 123456',
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 12,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

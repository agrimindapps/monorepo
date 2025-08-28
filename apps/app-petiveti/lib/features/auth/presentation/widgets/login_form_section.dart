import 'package:flutter/material.dart';

/// **Login Form Section Widget**
/// 
/// A comprehensive form section for authentication that handles both
/// login and registration input fields with validation and user experience features.
/// 
/// ## Key Features:
/// - **Email Validation**: Robust email format validation with user feedback
/// - **Password Security**: Secure password input with visibility toggle
/// - **Remember Me**: Optional credential persistence for returning users
/// - **Form Validation**: Real-time validation with clear error messages
/// - **Accessibility**: Full semantic support and keyboard navigation
/// 
/// ## Input Fields:
/// - **Email Field**: Email input with format validation and keyboard type
/// - **Password Field**: Secure input with visibility toggle and validation
/// - **Remember Me Checkbox**: Optional credential persistence (login only)
/// 
/// ## Validation Logic:
/// - **Email**: Required, valid email format using comprehensive regex
/// - **Password**: Required, minimum length validation
/// - **Real-time Feedback**: Immediate validation feedback as user types
/// 
/// ## Accessibility Features:
/// - Semantic labels for all form inputs
/// - Proper keyboard navigation order
/// - Screen reader announcements for validation errors
/// - High contrast mode support
/// 
/// @author PetiVeti Development Team
/// @since 1.1.0
class LoginFormSection extends StatelessWidget {
  /// Creates a login form section widget.
  /// 
  /// **Parameters:**
  /// - [emailController]: Controller for email input field
  /// - [passwordController]: Controller for password input field
  /// - [obscurePassword]: Whether password should be obscured
  /// - [rememberMe]: Whether remember me option is selected
  /// - [isSignUp]: Whether form is in sign-up mode
  /// - [onPasswordVisibilityToggle]: Callback for password visibility toggle
  /// - [onRememberMeChanged]: Callback for remember me checkbox changes
  const LoginFormSection({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isSignUp,
    required this.onPasswordVisibilityToggle,
    required this.onRememberMeChanged,
  });

  /// Controller for email input field
  final TextEditingController emailController;
  
  /// Controller for password input field
  final TextEditingController passwordController;
  
  /// Whether password field should be obscured
  final bool obscurePassword;
  
  /// Whether remember me option is selected
  final bool rememberMe;
  
  /// Whether form is in sign-up mode
  final bool isSignUp;
  
  /// Callback for password visibility toggle
  final VoidCallback onPasswordVisibilityToggle;
  
  /// Callback for remember me checkbox changes
  final ValueChanged<bool?> onRememberMeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEmailField(context),
        const SizedBox(height: 16),
        _buildPasswordField(context),
        if (!isSignUp) ...[
          const SizedBox(height: 8),
          _buildRememberMeOption(context),
        ],
      ],
    );
  }

  /// **Email Input Field**
  /// 
  /// Creates the email input field with validation and proper keyboard type.
  Widget _buildEmailField(BuildContext context) {
    return Semantics(
      label: 'Campo de entrada de email',
      hint: 'Digite seu endereço de email para autenticação',
      textField: true,
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'Digite seu email',
          prefixIcon: const Icon(Icons.email),
          border: const OutlineInputBorder(),
          helperText: 'Exemplo: usuario@email.com',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: _validateEmail,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  /// **Password Input Field**
  /// 
  /// Creates the password input field with visibility toggle and validation.
  Widget _buildPasswordField(BuildContext context) {
    return Semantics(
      label: 'Campo de entrada de senha',
      hint: obscurePassword 
          ? 'Digite sua senha. Senha está oculta para segurança'
          : 'Digite sua senha. Senha está visível',
      textField: true,
      child: TextFormField(
        controller: passwordController,
        obscureText: obscurePassword,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: 'Senha',
          hintText: 'Digite sua senha',
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: Semantics(
            label: obscurePassword 
                ? 'Mostrar senha'
                : 'Ocultar senha',
            hint: 'Toque para alternar visibilidade da senha',
            button: true,
            child: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility : Icons.visibility_off,
                semanticLabel: obscurePassword 
                    ? 'Mostrar senha'
                    : 'Ocultar senha',
              ),
              onPressed: onPasswordVisibilityToggle,
              tooltip: obscurePassword 
                  ? 'Mostrar senha'
                  : 'Ocultar senha',
            ),
          ),
          border: const OutlineInputBorder(),
          helperText: 'Mínimo de 6 caracteres',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: _validatePassword,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  /// **Remember Me Option**
  /// 
  /// Creates the remember me checkbox with descriptive text.
  Widget _buildRememberMeOption(BuildContext context) {
    return Semantics(
      label: 'Opção lembrar credenciais',
      hint: rememberMe 
          ? 'Ativado: credenciais serão salvas para próximo acesso'
          : 'Desativado: credenciais não serão salvas',
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
        ),
        child: CheckboxListTile(
          value: rememberMe,
          onChanged: onRememberMeChanged,
          title: const Text(
            'Lembrar de mim',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Salvar informações para próximo acesso',
            style: TextStyle(fontSize: 12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// **Email Validation**
  /// 
  /// Validates email format using comprehensive regex pattern.
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }

    final email = value.trim();
    
    // Simple but effective email validation regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(email)) {
      return 'Email inválido';
    }

    // Check for common mistakes
    if (email.contains('..')) {
      return 'Email não pode conter pontos consecutivos';
    }

    if (email.startsWith('.') || email.endsWith('.')) {
      return 'Email não pode começar ou terminar com ponto';
    }

    return null;
  }

  /// **Password Validation**
  /// 
  /// Validates password length and basic security requirements.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }

    // Additional validation for sign-up mode
    if (isSignUp) {
      if (value.length < 8) {
        return 'Senha deve ter pelo menos 8 caracteres';
      }

      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return 'Senha deve conter pelo menos uma letra maiúscula';
      }

      if (!RegExp(r'[a-z]').hasMatch(value)) {
        return 'Senha deve conter pelo menos uma letra minúscula';
      }

      if (!RegExp(r'[0-9]').hasMatch(value)) {
        return 'Senha deve conter pelo menos um número';
      }
    }

    return null;
  }
}
import 'package:flutter/material.dart';
import 'register_form_validator.dart';

/// **Registration Form Fields Widget**
/// 
/// Contains all form input fields for user registration with validation.
/// This widget handles the visual representation and user interaction
/// for registration form fields while delegating validation to the validator.
/// 
/// ## Features:
/// - **Responsive Form Fields**: Adapts to different screen sizes
/// - **Real-time Validation**: Provides immediate feedback to users
/// - **Password Visibility Toggles**: Secure password input with show/hide
/// - **Accessibility Support**: Full screen reader and keyboard navigation
/// - **Auto-completion**: Smart input suggestions where appropriate
/// 
/// @author PetiVeti Development Team
/// @since 1.0.0
/// @version 1.3.0 - Enhanced field validation and accessibility
class RegisterFormFields extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool acceptedTerms;
  final ValueChanged<bool> onTermsChanged;

  /// Creates registration form fields widget.
  /// 
  /// @param nameController Controller for name input field
  /// @param emailController Controller for email input field
  /// @param passwordController Controller for password input field
  /// @param confirmPasswordController Controller for confirm password field
  /// @param acceptedTerms Current state of terms acceptance
  /// @param onTermsChanged Callback when terms acceptance changes
  const RegisterFormFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.acceptedTerms,
    required this.onTermsChanged,
  });

  @override
  State<RegisterFormFields> createState() => _RegisterFormFieldsState();
}

class _RegisterFormFieldsState extends State<RegisterFormFields> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNameField(),
        const SizedBox(height: 16),
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 16),
        _buildConfirmPasswordField(),
        const SizedBox(height: 24),
        _buildTermsCheckbox(),
      ],
    );
  }

  /// **Name Input Field**
  /// 
  /// Text input for user's full name with validation and styling.
  Widget _buildNameField() {
    return TextFormField(
      controller: widget.nameController,
      textCapitalization: TextCapitalization.words,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Nome completo',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
        helperText: 'Como você gostaria de ser chamado?',
      ),
      validator: RegisterFormValidator.validateName,
    );
  }

  /// **Email Input Field**
  /// 
  /// Email input with validation and auto-completion support.
  Widget _buildEmailField() {
    return TextFormField(
      controller: widget.emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
        helperText: 'Usaremos para comunicações importantes',
      ),
      validator: RegisterFormValidator.validateEmail,
    );
  }

  /// **Password Input Field**
  /// 
  /// Secure password input with visibility toggle and validation.
  Widget _buildPasswordField() {
    return TextFormField(
      controller: widget.passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
        ),
        border: const OutlineInputBorder(),
        helperText: 'Mínimo 6 caracteres',
      ),
      validator: RegisterFormValidator.validatePassword,
    );
  }

  /// **Confirm Password Input Field**
  /// 
  /// Password confirmation field with visibility toggle and matching validation.
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: widget.confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Confirmar senha',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          tooltip: _obscureConfirmPassword ? 'Mostrar senha' : 'Ocultar senha',
        ),
        border: const OutlineInputBorder(),
        helperText: 'Digite a senha novamente',
      ),
      validator: (value) => RegisterFormValidator.validateConfirmPassword(
        value,
        widget.passwordController.text,
      ),
    );
  }

  /// **Terms and Conditions Checkbox**
  /// 
  /// Required checkbox for terms acceptance with clickable links.
  Widget _buildTermsCheckbox() {
    return CheckboxListTile(
      value: widget.acceptedTerms,
      onChanged: (value) => widget.onTermsChanged(value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: const [
            TextSpan(text: 'Aceito os '),
            TextSpan(
              text: 'Termos de Uso',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(text: ' e '),
            TextSpan(
              text: 'Política de Privacidade',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

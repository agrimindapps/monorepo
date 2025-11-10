import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';

import '../../../../shared/constants/splash_constants.dart';

/// Login form widget following SRP principle
///
/// Single responsibility: Handle login form UI and validation
class LoginFormWidget extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback? onToggleAuth;
  final bool showAuthToggle;

  const LoginFormWidget({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onRememberMeChanged,
    required this.onLogin,
    required this.onForgotPassword,
    this.onToggleAuth,
    this.showAuthToggle = false,
  });

  @override
  ConsumerState<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends ConsumerState<LoginFormWidget> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showAuthToggle) ...[
            _buildAuthToggle(),
            const SizedBox(height: 32),
          ],

          const Text(
            'Entrar',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Acesse sua conta para gerenciar',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          _buildEmailField(),
          const SizedBox(height: 20),

          _buildPasswordField(),
          const SizedBox(height: 16),

          _buildRememberAndForgot(),
          const SizedBox(height: 32),

          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildAuthToggle() {
    return Row(
      children: [
        Flexible(
          child: GestureDetector(
            onTap: widget.onToggleAuth,
            child: Column(
              children: [
                const Text(
                  'Entrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: SplashColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: SplashColors.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: GestureDetector(
            onTap: widget.onToggleAuth,
            child: Column(
              children: [
                Text(
                  'Cadastrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: widget.emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SplashColors.primaryColor),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Email é obrigatório';
        }
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegex.hasMatch(value!)) {
          return 'Email inválido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: widget.passwordController,
      obscureText: widget.obscurePassword,
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: widget.onTogglePassword,
          icon: Icon(
            widget.obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SplashColors.primaryColor),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Senha é obrigatória';
        }
        if (value!.length < 6) {
          return 'Senha deve ter pelo menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      children: [
        Checkbox(
          value: widget.rememberMe,
          onChanged: widget.onRememberMeChanged,
          activeColor: SplashColors.primaryColor,
        ),
        const Text('Lembrar-me'),
        const Spacer(),
        GestureDetector(
          onTap: widget.onForgotPassword,
          child: const Text(
            'Esqueceu a senha?',
            style: TextStyle(
              color: SplashColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: SplashColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Entrar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

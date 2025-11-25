import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../notifiers/login_form_notifier.dart';
import 'auth_button_widget.dart';
import 'auth_text_field_widget.dart';

/// Widget para formulário de cadastro
class SignupFormWidget extends ConsumerWidget {

  const SignupFormWidget({
    super.key,
    this.onSignupSuccess,
  });
  final VoidCallback? onSignupSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);

    return Form(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Crie sua conta para começar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          AuthTextFieldWidget(
            controller: notifier.nameController,
            label: 'Nome completo',
            hint: 'Insira seu nome completo',
            prefixIcon: Icons.person_outline,
            validator: notifier.validateName,
          ),
          const SizedBox(height: 20),
          AuthTextFieldWidget(
            controller: notifier.emailController,
            label: 'Email',
            hint: 'Insira seu email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: notifier.validateEmail,
          ),
          const SizedBox(height: 20),
          AuthTextFieldWidget(
            controller: notifier.passwordController,
            label: 'Senha',
            hint: 'Mínimo 6 caracteres',
            prefixIcon: Icons.lock_outline,
            obscureText: state.obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                state.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: notifier.togglePasswordVisibility,
            ),
            validator: notifier.validatePassword,
          ),
          const SizedBox(height: 20),
          AuthTextFieldWidget(
            controller: notifier.confirmPasswordController,
            label: 'Confirmar senha',
            hint: 'Digite novamente sua senha',
            prefixIcon: Icons.lock_outline,
            obscureText: state.obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                state.obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: notifier.toggleConfirmPasswordVisibility,
            ),
            validator: notifier.validateConfirmPassword,
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(context, ref, state.errorMessage!),
          ],
          const SizedBox(height: 30),
          AuthButtonWidget(
            text: 'Criar Conta',
            isLoading: state.isLoading,
            onPressed: () => _handleSignup(ref),
          ),

          const SizedBox(height: 20),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                children: [
                  const TextSpan(
                    text: 'Ao criar uma conta, você concorda com nossos\n',
                  ),
                  TextSpan(
                    text: 'Termos de Serviço',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.go('/terms'),
                  ),
                  const TextSpan(text: ' e '),
                  TextSpan(
                    text: 'Política de Privacidade',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.go('/privacy'),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, WidgetRef ref, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              ref.read(loginFormProvider.notifier).clearError();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                color: Colors.red.shade700,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignup(WidgetRef ref) async {
    final notifier = ref.read(loginFormProvider.notifier);
    final success = await notifier.signUpWithEmail();

    if (success && onSignupSuccess != null) {
      onSignupSuccess!();
    }
  }
}

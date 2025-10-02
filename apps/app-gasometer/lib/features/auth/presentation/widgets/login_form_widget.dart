import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_provider.dart';
import '../providers/login_form_provider.dart';
import 'auth_button_widget.dart';
import 'auth_text_field_widget.dart';
import 'social_login_buttons_widget.dart';

/// Widget responsável apenas pelo formulário de login
/// Segue o princípio da Responsabilidade Única
class LoginFormWidget extends ConsumerWidget {

  const LoginFormWidget({
    super.key,
    this.onLoginSuccess,
  });
  final VoidCallback? onLoginSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(loginFormProvider);
    final formNotifier = ref.watch(loginFormProvider.notifier);

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acesse sua conta para gerenciar seu consumo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Campo de email
          AuthTextFieldWidget(
            controller: formState.emailController!,
            label: 'Email',
            hint: 'Insira seu email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: formNotifier.validateEmail,
            onFieldSubmitted: (_) {
              // Focar no próximo campo
            },
          ),
          const SizedBox(height: 16),

          // Campo de senha
          AuthTextFieldWidget(
            controller: formState.passwordController!,
            label: 'Senha',
            hint: 'Insira sua senha',
            prefixIcon: Icons.lock_outline,
            obscureText: formState.obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                formState.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: formNotifier.togglePasswordVisibility,
              tooltip: formState.obscurePassword
                  ? 'Mostrar senha'
                  : 'Ocultar senha',
            ),
            validator: formNotifier.validatePassword,
            onFieldSubmitted: (_) => _handleLogin(context, ref),
          ),
          const SizedBox(height: 12),

          // Lembrar-me e Esqueceu senha
          _buildRememberMeAndForgotPassword(context, ref),

          // Mensagem de erro
          if (formState.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(context, ref, formState.errorMessage!),
          ],
          const SizedBox(height: 20),

          // Botão de login
          AuthButtonWidget(
            text: 'Entrar',
            isLoading: formState.isLoading,
            onPressed: () => _handleLogin(context, ref),
          ),

          const SizedBox(height: 20),

          // Divider
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'ou continue com',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          // Botões de login social
          const SocialLoginButtonsWidget(),

          const SizedBox(height: 16),

          // Botão de modo anônimo
          _buildAnonymousLoginButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildRememberMeAndForgotPassword(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(loginFormProvider);
    final formNotifier = ref.watch(loginFormProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: formState.rememberMe,
                activeColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (_) => formNotifier.toggleRememberMe(),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Lembrar-me',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: formNotifier.showRecoveryForm,
          child: Text(
            'Esqueceu sua senha?',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context, WidgetRef ref, String message) {
    final formNotifier = ref.watch(loginFormProvider.notifier);

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
            onTap: formNotifier.clearError,
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

  Widget _buildAnonymousLoginButton(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final formNotifier = ref.watch(loginFormProvider.notifier);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: authState.isLoading
            ? null
            : () async {
                final success = await formNotifier.signInAnonymously();
                if (context.mounted && success && onLoginSuccess != null) {
                  onLoginSuccess!();
                }
              },
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColor,
          side: BorderSide(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: authState.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Continuar sem conta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _handleLogin(BuildContext context, WidgetRef ref) async {
    if (kDebugMode) {
      print('🎯 LoginFormWidget: Chamando login com Riverpod');
    }

    final formNotifier = ref.watch(loginFormProvider.notifier);
    final success = await formNotifier.signInWithEmail();

    if (kDebugMode) {
      print('🎯 LoginFormWidget: Após login - sucesso: $success');
    }

    if (success && onLoginSuccess != null) {
      onLoginSuccess!();
    }
  }
}
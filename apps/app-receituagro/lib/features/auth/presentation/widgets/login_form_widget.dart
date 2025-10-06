import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/login_notifier.dart';
import 'auth_button_widget.dart';
import 'auth_text_field_widget.dart';

/// Widget responsável pelo formulário de login do ReceitaAgro
/// Adaptado do app-gasometer com integração ao ReceitaAgroAuthProvider
/// Migrado para Riverpod
class LoginFormWidget extends ConsumerWidget {
  final VoidCallback? onLoginSuccess;

  const LoginFormWidget({
    super.key,
    this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginNotifierProvider);
    final loginNotifier = ref.read(loginNotifierProvider.notifier);

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acesse sua conta para gerenciar suas receitas agropecuárias',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          AuthTextFieldWidget(
            controller: loginNotifier.emailController,
            label: 'Email',
            hint: 'Insira seu email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: loginNotifier.validateEmail,
            onFieldSubmitted: (_) {
            },
          ),
          const SizedBox(height: 20),
          AuthTextFieldWidget(
            controller: loginNotifier.passwordController,
            label: 'Senha',
            hint: 'Insira sua senha',
            prefixIcon: Icons.lock_outline,
            obscureText: loginState.obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                loginState.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: loginNotifier.togglePasswordVisibility,
              tooltip: loginState.obscurePassword
                  ? 'Mostrar senha'
                  : 'Ocultar senha',
            ),
            validator: loginNotifier.validatePassword,
            onFieldSubmitted: (_) => _handleLogin(context, ref),
          ),
          const SizedBox(height: 15),
          _buildForgotPassword(context, ref),

          const SizedBox(height: 30),
          AuthButtonWidget(
            text: 'Entrar',
            isLoading: loginState.isLoading,
            onPressed: () => _handleLogin(context, ref),
          ),

          const SizedBox(height: 30),
          Center(
            child: TextButton.icon(
              onPressed: () => _navigateBackToProfile(context),
              icon: Icon(
                Icons.arrow_back,
                size: 18,
                color: _getReceitaAgroPrimaryColor(
                  Theme.of(context).brightness == Brightness.dark
                ),
              ),
              label: Text(
                'Voltar ao perfil',
                style: TextStyle(
                  color: _getReceitaAgroPrimaryColor(
                    Theme.of(context).brightness == Brightness.dark
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context, WidgetRef ref) {
    final loginNotifier = ref.read(loginNotifierProvider.notifier);
    final primaryColor = _getReceitaAgroPrimaryColor(
      Theme.of(context).brightness == Brightness.dark
    );

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: loginNotifier.showRecoveryForm,
        child: Text(
          'Esqueceu sua senha?',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }


  void _navigateBackToProfile(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _handleLogin(BuildContext context, WidgetRef ref) async {
    if (kDebugMode) {
      print('🎯 LoginFormWidget: Iniciando login no ReceitaAgro');
    }

    final loginNotifier = ref.read(loginNotifierProvider.notifier);
    await loginNotifier.signInWithEmailAndSync();

    if (!context.mounted) return;

    final loginState = ref.read(loginNotifierProvider);

    if (loginState.isAuthenticated && onLoginSuccess != null) {
      onLoginSuccess!();
    } else if (loginState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loginState.errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).size.height - 150,
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Fechar',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              loginNotifier.clearError();
            },
          ),
        ),
      );
      loginNotifier.clearError();
    }
  }

  /// Cores primárias do ReceitaAgro
  Color _getReceitaAgroPrimaryColor(bool isDark) {
    if (isDark) {
      return const Color(0xFF81C784); // Verde claro para modo escuro
    } else {
      return const Color(0xFF4CAF50); // Verde padrão para modo claro
    }
  }
}
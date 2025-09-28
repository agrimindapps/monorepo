import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../controllers/login_controller.dart';
import 'auth_button_widget.dart';
import 'auth_text_field_widget.dart';

/// Widget responsável pelo formulário de login do ReceitaAgro
/// Adaptado do app-gasometer com integração ao ReceitaAgroAuthProvider
class LoginFormWidget extends StatelessWidget {
  final VoidCallback? onLoginSuccess;

  const LoginFormWidget({
    super.key,
    this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      builder: (context, controller, child) {
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

              // Campo de email
              AuthTextFieldWidget(
                controller: controller.emailController,
                label: 'Email',
                hint: 'Insira seu email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
                onFieldSubmitted: (_) {
                  // Focar no próximo campo
                },
              ),
              const SizedBox(height: 20),

              // Campo de senha
              AuthTextFieldWidget(
                controller: controller.passwordController,
                label: 'Senha',
                hint: 'Insira sua senha',
                prefixIcon: Icons.lock_outline,
                obscureText: controller.obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                  tooltip: controller.obscurePassword
                      ? 'Mostrar senha'
                      : 'Ocultar senha',
                ),
                validator: controller.validatePassword,
                onFieldSubmitted: (_) => _handleLogin(context),
              ),
              const SizedBox(height: 15),

              // Esqueceu senha
              _buildForgotPassword(context),

              const SizedBox(height: 30),

              // Botão de login
              AuthButtonWidget(
                text: 'Entrar',
                isLoading: controller.isLoading,
                onPressed: () => _handleLogin(context),
              ),

              const SizedBox(height: 30),

              // Botão de voltar ao perfil
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
      },
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Consumer<LoginController>(
      builder: (context, controller, child) {
        final primaryColor = _getReceitaAgroPrimaryColor(
          Theme.of(context).brightness == Brightness.dark
        );
        
        return Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: controller.showRecoveryForm,
            child: Text(
              'Esqueceu sua senha?',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage(BuildContext context, String message) {
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
              final controller = context.read<LoginController>();
              controller.clearError();
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

  void _navigateBackToProfile(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _handleLogin(BuildContext context) async {
    if (kDebugMode) {
      print('🎯 LoginFormWidget: Iniciando login no ReceitaAgro');
    }
    
    final controller = context.read<LoginController>();
    await controller.signInWithEmailAndSync();
    
    if (!context.mounted) return;
    
    if (controller.isAuthenticated && onLoginSuccess != null) {
      onLoginSuccess!();
    } else if (controller.errorMessage != null) {
      // Mostrar erro via SnackBar superior
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
                  controller.errorMessage!,
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
              controller.clearError();
            },
          ),
        ),
      );
      
      // Limpar erro após mostrar
      controller.clearError();
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
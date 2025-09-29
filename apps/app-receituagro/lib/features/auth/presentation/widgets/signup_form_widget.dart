import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart' as provider;

import '../controllers/login_controller.dart';
import 'auth_button_widget.dart';
import 'auth_text_field_widget.dart';

/// Widget responsável pelo formulário de cadastro do ReceitaAgro
/// Adaptado do app-gasometer com integração ao ReceitaAgroAuthProvider
class SignupFormWidget extends StatelessWidget {
  final VoidCallback? onSignupSuccess;

  const SignupFormWidget({
    super.key,
    this.onSignupSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<LoginController>(
      builder: (context, controller, child) {
        return Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crie sua conta e tenha acesso completo às receitas agropecuárias',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              // Campo de nome
              AuthTextFieldWidget(
                controller: controller.nameController,
                label: 'Nome completo',
                hint: 'Insira seu nome completo',
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
                validator: controller.validateName,
              ),
              const SizedBox(height: 20),

              // Campo de email
              AuthTextFieldWidget(
                controller: controller.emailController,
                label: 'Email',
                hint: 'Insira seu email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 20),

              // Campo de senha
              AuthTextFieldWidget(
                controller: controller.passwordController,
                label: 'Senha',
                hint: 'Mínimo 6 caracteres',
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
              ),
              const SizedBox(height: 20),

              // Campo de confirmar senha
              AuthTextFieldWidget(
                controller: controller.confirmPasswordController,
                label: 'Confirmar senha',
                hint: 'Digite a senha novamente',
                prefixIcon: Icons.lock_outline,
                obscureText: controller.obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                  tooltip: controller.obscureConfirmPassword
                      ? 'Mostrar senha'
                      : 'Ocultar senha',
                ),
                validator: controller.validateConfirmPassword,
                onFieldSubmitted: (_) => _handleSignup(context),
              ),
              const SizedBox(height: 20),

              // Termos e condições
              _buildTermsAndConditions(context),

              const SizedBox(height: 30),

              // Botão de cadastro
              AuthButtonWidget(
                text: 'Criar Conta',
                isLoading: controller.isLoading,
                onPressed: () => _handleSignup(context),
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

  Widget _buildTermsAndConditions(BuildContext context) {
    final primaryColor = _getReceitaAgroPrimaryColor(
      Theme.of(context).brightness == Brightness.dark
    );
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.3,
              ),
              children: [
                const TextSpan(
                  text: 'Ao criar uma conta, você concorda com nossos ',
                ),
                TextSpan(
                  text: 'Termos de Uso',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' e '),
                TextSpan(
                  text: 'Política de Privacidade',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }


  void _navigateBackToProfile(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _handleSignup(BuildContext context) async {
    if (kDebugMode) {
      print('🎯 SignupFormWidget: Iniciando cadastro no ReceitaAgro');
    }
    
    final controller = provider.Provider.of<LoginController>(context, listen: false);
    await controller.signUpWithEmailAndSync();
    
    if (!context.mounted) return;
    
    if (controller.isAuthenticated && onSignupSuccess != null) {
      onSignupSuccess!();
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
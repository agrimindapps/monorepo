import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/login_controller.dart';
import 'auth_text_field_widget.dart';
import 'auth_button_widget.dart';

/// Widget para formulário de cadastro
class SignupFormWidget extends StatelessWidget {
  final VoidCallback? onSignupSuccess;

  const SignupFormWidget({
    super.key,
    this.onSignupSuccess,
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
                'Crie sua conta para começar',
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
                ),
                validator: controller.validatePassword,
              ),
              const SizedBox(height: 20),

              // Campo de confirmação de senha
              AuthTextFieldWidget(
                controller: controller.confirmPasswordController,
                label: 'Confirmar senha',
                hint: 'Digite novamente sua senha',
                prefixIcon: Icons.lock_outline,
                obscureText: controller.obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
                validator: controller.validateConfirmPassword,
              ),

              // Mensagem de erro
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(context, controller.errorMessage!),
              ],
              const SizedBox(height: 30),

              // Botão de cadastro
              AuthButtonWidget(
                text: 'Criar Conta',
                isLoading: controller.isLoading,
                onPressed: () => _handleSignup(context),
              ),

              const SizedBox(height: 20),

              // Termos e condições
              Center(
                child: Text(
                  'Ao criar uma conta, você concorda com nossos\nTermos de Serviço e Política de Privacidade',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
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
        ],
      ),
    );
  }

  void _handleSignup(BuildContext context) async {
    final controller = context.read<LoginController>();
    await controller.signUpWithEmail();
    
    if (controller.isAuthenticated && onSignupSuccess != null) {
      onSignupSuccess!();
    }
  }
}
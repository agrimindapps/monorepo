import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/login_controller.dart';
import 'auth_text_field_widget.dart';
import 'auth_button_widget.dart';

/// Widget para formulário de recuperação de senha
class RecoveryFormWidget extends StatelessWidget {
  const RecoveryFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      builder: (context, controller, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Recuperar Senha',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enviaremos um link para redefinir sua senha',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),

            // Campo de email
            AuthTextFieldWidget(
              controller: controller.emailController,
              label: 'Email',
              hint: 'Insira seu email de cadastro',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
            ),

            // Mensagem de erro
            if (controller.errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(context, controller.errorMessage!),
            ],
            const SizedBox(height: 30),

            // Botão de enviar
            AuthButtonWidget(
              text: 'Enviar Link',
              isLoading: controller.isLoading,
              onPressed: () => _handleResetPassword(context),
            ),

            const SizedBox(height: 20),

            // Voltar para login
            Center(
              child: TextButton.icon(
                onPressed: controller.hideRecoveryForm,
                icon: const Icon(Icons.arrow_back_ios, size: 14),
                label: const Text('Voltar para o login'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
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

  void _handleResetPassword(BuildContext context) async {
    final controller = context.read<LoginController>();
    await controller.resetPassword();
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/login_controller.dart';
import 'auth_button_widget.dart';
import 'auth_text_field_widget.dart';

/// Widget responsável pelo formulário de recuperação de senha do ReceitaAgro
/// Adaptado do app-gasometer com tema verde
class RecoveryFormWidget extends StatelessWidget {
  const RecoveryFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      builder: (context, controller, child) {
        final primaryColor = _getReceitaAgroPrimaryColor(
          Theme.of(context).brightness == Brightness.dark
        );
        
        return Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Descrição
              Center(
                child: Column(
                  children: [
                    Text(
                      'Esqueceu sua senha?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Digite seu email e enviaremos instruções\npara redefinir sua senha.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              // Campo de email
              AuthTextFieldWidget(
                controller: controller.emailController,
                label: 'Email',
                hint: 'Insira seu email cadastrado',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
                onFieldSubmitted: (_) => _handlePasswordReset(context),
              ),

              // Mensagem de erro
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(context, controller.errorMessage!),
              ],
              
              const SizedBox(height: 30),

              // Botão de enviar
              AuthButtonWidget(
                text: 'Recuperar Senha',
                isLoading: controller.isLoading,
                onPressed: () => _handlePasswordReset(context),
              ),


              const SizedBox(height: 30),

              // Botão de voltar ao login
              Center(
                child: TextButton.icon(
                  onPressed: controller.hideRecoveryForm,
                  icon: Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: primaryColor,
                  ),
                  label: Text(
                    'Voltar ao login',
                    style: TextStyle(
                      color: primaryColor,
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

  void _handlePasswordReset(BuildContext context) async {
    if (kDebugMode) {
      print('🎯 RecoveryFormWidget: Enviando email de recuperação');
    }
    
    final controller = context.read<LoginController>();
    await controller.sendPasswordReset();
    
    if (!context.mounted) return;
    
    // Mostrar mensagem de sucesso se não houve erro
    if (controller.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Instruções de alteração de senha foram enviadas para ${controller.emailController.text}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: _getReceitaAgroPrimaryColor(
            Theme.of(context).brightness == Brightness.dark
          ),
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
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      
      // Voltar ao login após envio bem-sucedido
      controller.hideRecoveryForm();
    } else {
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
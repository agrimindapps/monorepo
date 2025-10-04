import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/state/auth_state.dart';
import '../../../auth/presentation/notifiers/notifiers.dart';
import '../notifiers/auth_notifier.dart';
import '../notifiers/login_form_notifier.dart';
import 'auth_button_widget.dart';
import 'auth_text_field_widget.dart';

/// Widget para formulário de recuperação de senha
class RecoveryFormWidget extends ConsumerStatefulWidget {
  const RecoveryFormWidget({super.key});

  @override
  ConsumerState<RecoveryFormWidget> createState() => _RecoveryFormWidgetState();
}

class _RecoveryFormWidgetState extends ConsumerState<RecoveryFormWidget> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _successMessageShown = false;

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginFormNotifierProvider);
    final formNotifier = ref.read(loginFormNotifierProvider.notifier);

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
          controller: formNotifier.emailController,
          label: 'Email',
          hint: 'Insira seu email de cadastro',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: formNotifier.validateEmail,
        ),

        // Mensagem de erro
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorMessage(context, _errorMessage!),
        ],

        // Mensagem de sucesso
        if (_successMessageShown) ...[
          const SizedBox(height: 16),
          _buildSuccessMessage(context),
        ],

        const SizedBox(height: 30),

        // Botão de enviar
        AuthButtonWidget(
          text: 'Enviar Link',
          isLoading: _isLoading,
          onPressed: () => _handleResetPassword(),
        ),

        const SizedBox(height: 20),

        // Voltar para login
        Center(
          child: TextButton.icon(
            onPressed: () => formNotifier.hideRecoveryForm(),
            icon: const Icon(Icons.arrow_back_ios, size: 14),
            label: const Text('Voltar para o login'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
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

  Widget _buildSuccessMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade700,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Email de recuperação enviado! Verifique sua caixa de entrada.',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    final formNotifier = ref.read(loginFormNotifierProvider.notifier);
    final email = formNotifier.emailController.text.trim();

    // Validar email
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Email é obrigatório';
        _successMessageShown = false;
      });
      return;
    }

    if (formNotifier.validateEmail(email) != null) {
      setState(() {
        _errorMessage = 'Email inválido';
        _successMessageShown = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessageShown = false;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.sendPasswordReset(email);

      final authState = ref.read(authProvider);
      if (authState.errorMessage != null) {
        setState(() {
          _errorMessage = authState.errorMessage;
          _isLoading = false;
        });
      } else {
        setState(() {
          _successMessageShown = true;
          _isLoading = false;
        });

        // Aguardar 3 segundos e voltar para login
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          formNotifier.hideRecoveryForm();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao enviar email de recuperação';
        _isLoading = false;
      });
    }
  }
}
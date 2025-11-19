import 'package:flutter/material.dart';

import '../../utils/auth_validators.dart';

/// Manager for forgot password dialog flow
/// Handles email validation, submission, and state management
class ForgotPasswordDialogManager {
  final void Function(String) onError;
  final void Function(String) onSuccess;

  ForgotPasswordDialogManager({required this.onError, required this.onSuccess});

  /// Shows forgot password dialog and handles the flow
  /// Returns true if email was submitted, false if cancelled
  Future<bool?> show(
    BuildContext context, {
    required Future<bool> Function(String email) onSubmit,
  }) async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildContent(formKey, emailController, isLoading),
                const SizedBox(height: 24),
                _buildActions(
                  context,
                  formKey,
                  emailController,
                  onSubmit,
                  (newLoading) => setState(() => isLoading = newLoading),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_reset_outlined, size: 24),
            SizedBox(width: 12),
            Text(
              'Redefinir Senha',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Insira seu email para receber um link de redefinição de senha',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildContent(
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    bool isLoading,
  ) {
    return Form(
      key: formKey,
      child: TextFormField(
        controller: emailController,
        enabled: !isLoading,
        decoration: const InputDecoration(
          labelText: 'Email',
          hintText: 'seu.email@example.com',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, insira seu email';
          }
          if (!AuthValidators.isValidEmail(value)) {
            return 'Por favor, insira um email válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    Future<bool> Function(String email) onSubmit,
    void Function(bool) setLoading,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              setLoading(true);
              try {
                final success = await onSubmit(emailController.text);
                if (success) {
                  onSuccess('Email de redefinição enviado com sucesso!');
                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                } else {
                  onError('Erro ao enviar email. Tente novamente.');
                }
              } catch (e) {
                onError('Erro: ${e.toString()}');
              } finally {
                setLoading(false);
              }
            }
          },
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}

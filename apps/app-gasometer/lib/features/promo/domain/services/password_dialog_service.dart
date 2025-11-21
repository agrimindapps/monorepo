import 'package:flutter/material.dart';

/// Service responsible for password confirmation dialogs
/// Follows SRP by handling only password input dialogs

class PasswordDialogService {
  /// Show password confirmation dialog
  Future<String?> showPasswordConfirmation(
    BuildContext context, {
    String title = 'Confirmar Identidade',
    String message = 'Por segurança, digite sua senha atual para continuar:',
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool obscureText = true,
  }) async {
    final controller = TextEditingController();
    bool isObscured = obscureText;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: isObscured,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Navigator.of(context).pop(value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () {
                final password = controller.text;
                if (password.isNotEmpty) {
                  Navigator.of(context).pop(password);
                }
              },
              child: Text(confirmText),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
    return result;
  }

  /// Show password error dialog
  Future<void> showPasswordError(
    BuildContext context, {
    String title = 'Senha Incorreta',
    String message =
        'A senha fornecida está incorreta. Por favor, tente novamente.',
    String buttonText = 'OK',
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Validate password format
  PasswordValidation validatePassword(String password) {
    if (password.isEmpty) {
      return PasswordValidation(
        isValid: false,
        errorMessage: 'A senha não pode estar vazia',
      );
    }

    if (password.length < 6) {
      return PasswordValidation(
        isValid: false,
        errorMessage: 'A senha deve ter pelo menos 6 caracteres',
      );
    }

    return PasswordValidation(isValid: true);
  }

  /// Show password requirements dialog
  Future<void> showPasswordRequirements(
    BuildContext context, {
    String title = 'Requisitos de Senha',
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sua senha deve atender aos seguintes requisitos:'),
            const SizedBox(height: 12),
            _buildRequirement('Mínimo de 6 caracteres'),
            _buildRequirement('Pelo menos uma letra maiúscula (recomendado)'),
            _buildRequirement('Pelo menos um número (recomendado)'),
            _buildRequirement('Pelo menos um caractere especial (recomendado)'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

// Models

class PasswordValidation {
  final bool isValid;
  final String? errorMessage;

  PasswordValidation({required this.isValid, this.errorMessage});
}

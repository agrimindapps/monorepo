import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens.dart';

/// Dialog para confirmação de exclusão de conta
class AccountDeletionDialog extends StatefulWidget {
  const AccountDeletionDialog({super.key});

  @override
  State<AccountDeletionDialog> createState() => _AccountDeletionDialogState();

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AccountDeletionDialog(),
    );
  }
}

class _AccountDeletionDialogState extends State<AccountDeletionDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_validateConfirmation);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateConfirmation() {
    setState(() {
      _isConfirmationValid =
          _confirmationController.text.trim().toUpperCase() == 'CONCORDO';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusDialog,
        ),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning,
            color: Theme.of(context).colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Excluir Conta',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Esta ação é irreversível e resultará em:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDeletionItem(
            context,
            Icons.delete_forever,
            'Exclusão permanente de todos os seus dados',
          ),
          _buildDeletionItem(
            context,
            Icons.history,
            'Perda do histórico de atividades',
          ),
          _buildDeletionItem(
            context,
            Icons.cloud_off,
            'Impossibilidade de recuperar informações',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusButton,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recomendamos fazer backup dos seus dados importantes antes de prosseguir',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Para confirmar, digite CONCORDO abaixo:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            decoration: InputDecoration(
              hintText: 'Digite CONCORDO para confirmar',
              border: OutlineInputBorder(
                borderRadius: GasometerDesignTokens.borderRadius(
                  GasometerDesignTokens.radiusButton,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: GasometerDesignTokens.borderRadius(
                  GasometerDesignTokens.radiusButton,
                ),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [_UpperCaseTextFormatter()],
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed:
              _isConfirmationValid ? () => _confirmDeletion(context) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isConfirmationValid
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.12),
            foregroundColor:
                _isConfirmationValid
                    ? Colors.white
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.38),
            shape: RoundedRectangleBorder(
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusButton,
              ),
            ),
          ),
          child: const Text('Excluir Conta'),
        ),
      ],
    );
  }

  Widget _buildDeletionItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeletion(BuildContext context) {
    Navigator.of(context).pop(true);
    // TODO: Navigate to account deletion page
    context.go('/account-deletion');
  }
}

/// Formatter que converte automaticamente o texto para uppercase
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

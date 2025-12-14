import 'package:core/core.dart' hide Column, AuthState, AuthStatus;
import 'package:flutter/material.dart';

import 'dialog_helpers.dart';
import 'upper_case_text_formatter.dart';

/// Dialog stateful para confirmação de exclusão de conta
class AccountDeletionDialog extends StatefulWidget {
  const AccountDeletionDialog({super.key});

  @override
  State<AccountDeletionDialog> createState() => _AccountDeletionDialogState();
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
    setState(
      () => _isConfirmationValid =
          _confirmationController.text.trim().toUpperCase() == 'CONCORDO',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning, color: errorColor, size: 28),
          const SizedBox(width: 12),
          Text(
            'Excluir Conta',
            style: TextStyle(color: errorColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: _buildContent(context, theme),
      actions: _buildActions(context, theme),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Esta ação é irreversível e resultará em:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        buildDialogInfoItem(
          context,
          Icons.delete_forever,
          'Exclusão permanente de todos os seus dados',
        ),
        buildDialogInfoItem(
          context,
          Icons.pets,
          'Perda de todos os registros de pets',
        ),
        buildDialogInfoItem(
          context,
          Icons.cloud_off,
          'Impossibilidade de recuperar informações',
        ),
        buildDialogInfoItem(
          context,
          Icons.card_membership,
          'Cancelamento de assinaturas ativas',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Esta ação não pode ser desfeita',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onPrimaryContainer,
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
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmationController,
          decoration: InputDecoration(
            hintText: 'Digite CONCORDO para confirmar',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [UpperCaseTextFormatter()],
          style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context, ThemeData theme) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          'Cancelar',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
      ElevatedButton(
        onPressed: _isConfirmationValid
            ? () {
                Navigator.of(context).pop();
                context.go('/account-deletion');
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isConfirmationValid
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface.withValues(alpha: 0.12),
          foregroundColor: _isConfirmationValid
              ? Colors.white
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Excluir Conta'),
      ),
    ];
  }
}

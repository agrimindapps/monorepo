import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Helper class to manage premium dialog behavior for anonymous users
class PremiumDialogHelper {
  /// Check if premium dialogs should be shown
  /// Returns false for anonymous users, true for authenticated users
  static bool shouldShowPremiumDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.isAnonymous) {
      return false;
    }
    return true;
  }

  /// Show premium dialog with anonymous user check
  static void showPremiumDialog(BuildContext context, {
    String? title,
    String? content,
    VoidCallback? onSubscribe,
  }) {
    if (!shouldShowPremiumDialog()) {
      return;
    }

    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Funcionalidade Premium'),
        content: Text(
          content ?? 'Este recurso está disponível apenas para usuários premium. '
              'Assine agora para ter acesso completo ao app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onSubscribe?.call();
            },
            child: const Text('Assinar'),
          ),
        ],
      ),
    );
  }

  /// Show snackbar with anonymous user check
  static void showPremiumSnackBar(BuildContext context, {
    String? message,
  }) {
    if (!shouldShowPremiumDialog()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ?? 'Esta funcionalidade requer assinatura premium',
        ),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Assinar',
          textColor: Colors.white,
          onPressed: () {
          },
        ),
      ),
    );
  }
}

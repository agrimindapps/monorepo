// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../services/message_service.dart';

/// Implementação concreta do MessageHandler usando SnackBar
///
/// Esta classe permite que o controller exiba mensagens na UI
/// sem depender diretamente do BuildContext
class SnackBarMessageHandler implements MessageHandler {
  final BuildContext _context;

  SnackBarMessageHandler(this._context);

  @override
  void showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(_context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade900 : Colors.green.shade700,
        duration: Duration(seconds: isError ? 3 : 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }

  @override
  void showSuccess(String message) {
    showMessage(message, isError: false);
  }

  @override
  void showError(String message) {
    showMessage(message, isError: true);
  }
}

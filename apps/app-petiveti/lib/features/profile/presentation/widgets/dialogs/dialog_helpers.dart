import 'package:flutter/material.dart';

/// Constrói item de informação para dialogs de confirmação
Widget buildDialogInfoItem(
  BuildContext context,
  IconData icon,
  String text, {
  Color? iconColor,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.error,
          size: 20,
        ),
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

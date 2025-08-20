// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../styles/consulta_form_styles.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final bool dismissible;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onDismiss,
    this.dismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ConsultaFormStyles.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ConsultaFormStyles.borderRadius),
        border: Border.all(
          color: ConsultaFormStyles.errorColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: ConsultaFormStyles.errorColor,
            size: ConsultaFormStyles.mediumIconSize,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: ConsultaFormStyles.errorColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (dismissible && onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(
                Icons.close,
                color: ConsultaFormStyles.errorColor,
                size: ConsultaFormStyles.smallIconSize,
              ),
              tooltip: 'Fechar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../styles/despesa_form_styles.dart';

class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool dismissible;

  const LoadingOverlay({
    super.key,
    this.message,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DespesaFormStyles.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DespesaFormStyles.primaryColor,
                  ),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  message ?? 'Carregando...',
                  style: DespesaFormStyles.labelStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

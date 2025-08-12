// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../styles/consulta_page_styles.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ConsultaPageStyles.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: ConsultaPageStyles.largeIconSize * 2,
              color: ConsultaPageStyles.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Ops! Algo deu errado',
              style: ConsultaPageStyles.titleStyle.copyWith(
                color: ConsultaPageStyles.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: ConsultaPageStyles.bodyStyle,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ConsultaPageStyles.primaryButtonStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

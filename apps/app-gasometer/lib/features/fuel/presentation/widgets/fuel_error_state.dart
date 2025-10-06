import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/semantic_widgets.dart';

/// Reusable fuel error state widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of displaying error state for fuel
/// Follows OCP: Open for extension via callback functions
class FuelErrorState extends StatelessWidget {
  const FuelErrorState({
    super.key,
    required this.error,
    this.onRetry,
  });

  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SemanticCard(
      semanticLabel: 'Erro ao carregar abastecimentos',
      semanticHint: 'Mensagem de erro: $error${onRetry != null ? '. Toque no botão tentar novamente para recarregar' : ''}',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 24),
          SemanticText.heading(
            'Erro ao carregar abastecimentos',
            style: TextStyle(
              fontSize: GasometerDesignTokens.fontSizeLg,
              fontWeight: GasometerDesignTokens.fontWeightBold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          SemanticText(
            error,
            style: TextStyle(
              fontSize: GasometerDesignTokens.fontSizeMd,
              color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: GasometerDesignTokens.opacitySecondary,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

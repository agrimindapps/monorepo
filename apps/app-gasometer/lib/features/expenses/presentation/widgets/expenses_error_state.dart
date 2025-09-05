import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/theme/design_tokens.dart';

/// Widget para estado de erro da listagem de despesas
class ExpensesErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ExpensesErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de erro
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
            ),
            
            SizedBox(height: GasometerDesignTokens.spacingXl),
            
            // Título
            SemanticText.heading(
              'Erro ao carregar despesas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: GasometerDesignTokens.spacingMd),
            
            // Descrição do erro
            SemanticText.subtitle(
              error,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: GasometerDesignTokens.spacingXxl),
            
            // Botão de tentar novamente
            SemanticButton(
              semanticLabel: 'Tentar carregar despesas novamente',
              semanticHint: 'Recarrega a lista de despesas após erro',
              type: ButtonType.elevated,
              onPressed: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh),
                    SizedBox(width: GasometerDesignTokens.spacingMd),
                    const Text(
                      'Tentar Novamente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: GasometerDesignTokens.spacingXl),
            
            // Sugestões
            _buildSuggestionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: GasometerDesignTokens.spacingSm),
              SemanticText.heading(
                'Possíveis soluções:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          SizedBox(height: GasometerDesignTokens.spacingMd),
          
          ...const [
            '• Verifique sua conexão com a internet',
            '• Tente fechar e abrir o aplicativo novamente',
            '• Verifique se você está logado',
            '• Aguarde alguns minutos e tente novamente',
            '• Se o problema persistir, entre em contato conosco',
          ].map((suggestion) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: SemanticText(
              suggestion,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.3,
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }
}
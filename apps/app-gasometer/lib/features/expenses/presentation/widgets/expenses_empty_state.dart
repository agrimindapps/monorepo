import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/theme/design_tokens.dart';

/// Widget para estado vazio da listagem de despesas
class ExpensesEmptyState extends StatelessWidget {
  final VoidCallback onAddRecord;

  const ExpensesEmptyState({
    super.key,
    required this.onAddRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustração
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.attach_money,
                size: 60,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              ),
            ),
            
            SizedBox(height: GasometerDesignTokens.spacingXl),
            
            // Título principal
            SemanticText.heading(
              'Nenhuma despesa registrada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: GasometerDesignTokens.spacingMd),
            
            // Descrição
            SemanticText.subtitle(
              'Comece registrando suas primeiras despesas do veículo como seguro, IPVA, manutenções, multas e outros gastos.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: GasometerDesignTokens.spacingXxl),
            
            // Botão de ação
            SemanticButton(
              semanticLabel: 'Registrar primeira despesa',
              semanticHint: 'Abre formulário para cadastrar sua primeira despesa do veículo',
              type: ButtonType.elevated,
              onPressed: onAddRecord,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add),
                    SizedBox(width: GasometerDesignTokens.spacingMd),
                    const Text(
                      'Registrar Primeira Despesa',
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
            
            // Dicas
            _buildTipsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
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
                Icons.tips_and_updates,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: GasometerDesignTokens.spacingSm),
              SemanticText.heading(
                'Dicas de uso:',
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
            '• Registre despesas como seguro, IPVA, manutenções',
            '• Adicione comprovantes/fotos quando possível',
            '• Use a busca para encontrar despesas específicas',
            '• Filtre por tipo de despesa ou período',
            '• Acompanhe estatísticas e padrões de gastos',
          ].map((tip) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: SemanticText(
              tip,
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
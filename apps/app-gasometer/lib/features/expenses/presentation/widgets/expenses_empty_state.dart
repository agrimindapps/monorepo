import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/theme/design_tokens.dart';

/// Widget para estado vazio da listagem de despesas
class ExpensesEmptyState extends StatelessWidget {
  const ExpensesEmptyState({
    super.key,
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
              'Use o botão + para registrar suas despesas do veículo como seguro, IPVA, manutenções, multas e outros gastos.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
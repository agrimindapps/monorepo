import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Widget para exibir estado de erro na home de pragas
/// 
/// Responsabilidades:
/// - Exibir ícone e mensagem de erro
/// - Botão para tentar novamente
/// - Layout responsivo e acessível
class HomePragasErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const HomePragasErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ReceitaAgroSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: ReceitaAgroSpacing.md),
            Text(
              'Erro ao carregar dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: ReceitaAgroSpacing.xs),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ReceitaAgroSpacing.lg),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: ReceitaAgroSpacing.lg,
                  vertical: ReceitaAgroSpacing.sm,
                ),
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
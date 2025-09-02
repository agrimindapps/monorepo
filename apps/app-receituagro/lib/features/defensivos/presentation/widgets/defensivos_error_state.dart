import 'package:flutter/material.dart';

import '../../../../core/design/design_tokens.dart';
import '../providers/home_defensivos_provider.dart';

/// Error state component for Defensivos home page.
/// 
/// Displays error message with retry functionality in a clean,
/// centered layout following app design patterns.
/// 
/// Performance: Lightweight component for error handling.
class DefensivosErrorState extends StatelessWidget {
  const DefensivosErrorState({
    super.key,
    required this.provider,
    required this.onRetry,
  });

  final HomeDefensivosProvider provider;
  final VoidCallback onRetry;

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
              provider.errorMessage ?? 'Erro desconhecido',
              style: ReceitaAgroTypography.sectionTitle.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ReceitaAgroSpacing.lg),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
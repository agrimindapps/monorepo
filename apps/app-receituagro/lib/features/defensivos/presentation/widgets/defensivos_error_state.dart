import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';

/// Error state component for Defensivos home page.
///
/// Displays error message with retry functionality in a clean,
/// centered layout following app design patterns.
///
/// Performance: Lightweight component for error handling.
/// Migrated to Riverpod - receives error message directly.
class DefensivosErrorState extends StatelessWidget {
  const DefensivosErrorState({
    super.key,
    this.errorMessage,
    required this.onRetry,
  });

  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String cleanErrorMessage = _getCleanErrorMessage(errorMessage);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ReceitaAgroSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: ReceitaAgroSpacing.md),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    cleanErrorMessage,
                    style: ReceitaAgroTypography.sectionTitle.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: ReceitaAgroSpacing.lg),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Limpa e encurta mensagens de erro muito longas
  String _getCleanErrorMessage(String? errorMessage) {
    if (errorMessage == null) return 'Erro desconhecido';
    if (errorMessage.length > 200) {
      final lines = errorMessage.split('\n');
      if (lines.isNotEmpty) {
        String firstLine = lines.first.trim();
        if (firstLine.length > 150) {
          firstLine = '${firstLine.substring(0, 150)}...';
        }
        return firstLine.isEmpty ? 'Erro ao carregar dados' : firstLine;
      }
    }

    return errorMessage;
  }
}
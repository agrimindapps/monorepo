import 'package:flutter/material.dart';

/// Empty state widget shown when user has no lists
class ListEmptyState extends StatelessWidget {
  const ListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 120,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma lista ainda',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Crie sua primeira lista tocando no botão abaixo',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            Icon(
              Icons.arrow_downward,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

/// Widget para exibir quando a busca não retorna resultados de pragas
/// Adaptado do widget dos favoritos para o contexto de pragas por cultura
class NoSearchResultsWidget extends StatelessWidget {
  final String searchText;
  final Color? accentColor;

  const NoSearchResultsWidget({
    super.key,
    required this.searchText,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveAccentColor = accentColor ?? Theme.of(context).primaryColor;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: effectiveAccentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_outlined,
                size: 60,
                color: effectiveAccentColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum resultado encontrado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Não encontramos pragas com "$searchText"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tente usar palavras-chave diferentes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

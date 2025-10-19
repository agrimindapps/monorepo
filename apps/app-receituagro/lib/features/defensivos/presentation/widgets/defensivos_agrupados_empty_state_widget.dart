import 'package:flutter/material.dart';

import '../../data/defensivos_agrupados_category.dart';

class DefensivosAgrupadosEmptyStateWidget extends StatelessWidget {
  final DefensivosAgrupadosCategory category;
  final bool isDark;
  final bool isSearching;
  final String searchText;
  final int navigationLevel;
  final VoidCallback? onClearFilters;

  const DefensivosAgrupadosEmptyStateWidget({
    super.key,
    required this.category,
    required this.isDark,
    this.isSearching = false,
    this.searchText = '',
    this.navigationLevel = 0,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            _getTitle(),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _getDetailedMessage(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (isSearching && onClearFilters != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpar Busca'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          if (isSearching && onClearFilters != null) const SizedBox(height: 16),
          _buildSuggestions(theme),
        ],
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dicas de busca:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSuggestionItem('• Use termos mais gerais na busca'),
            _buildSuggestionItem('• Verifique a ortografia dos nomes'),
            _buildSuggestionItem('• Experimente buscar por fabricante'),
            _buildSuggestionItem('• Tente filtrar por classe agronômica'),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _getTitle() {
    if (isSearching && searchText.isNotEmpty) {
      return 'Nenhum defensivo encontrado';
    }

    if (navigationLevel > 0) {
      return 'Nenhum item encontrado';
    }

    return 'Nenhum defensivo encontrado';
  }

  String _getDetailedMessage() {
    if (isSearching && searchText.isNotEmpty) {
      return 'Não encontramos defensivos que correspondam à busca "$searchText". '
          'Tente ajustar os termos ou limpar a busca para ver todos os resultados.';
    }

    if (navigationLevel > 0) {
      return 'Não há defensivos disponíveis neste grupo no momento. '
          'Volte para a categoria anterior ou tente uma busca diferente.';
    }

    switch (category) {
      case DefensivosAgrupadosCategory.fabricantes:
        return 'Não encontramos fabricantes registrados no banco de dados. '
            'Tente ajustar os filtros ou limpar todas as configurações.';
      case DefensivosAgrupadosCategory.classeAgronomica:
        return 'Não encontramos classes agronômicas registradas no momento. '
            'Tente ajustar os filtros ou limpar todas as configurações.';
      case DefensivosAgrupadosCategory.ingredienteAtivo:
        return 'Não encontramos ingredientes ativos registrados no momento. '
            'Tente ajustar os filtros ou limpar todas as configurações.';
      case DefensivosAgrupadosCategory.modoAcao:
        return 'Não encontramos modos de ação registrados no momento. '
            'Tente ajustar os filtros ou limpar todas as configurações.';
      default:
        return 'Não encontramos defensivos que correspondam aos seus critérios de busca. '
            'Tente ajustar os filtros ou limpar todas as configurações.';
    }
  }
}

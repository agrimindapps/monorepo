import 'package:flutter/material.dart';

/// Widget para exibir estado vazio quando não há defensivos
/// Migrado e adaptado de defensivos_agrupados para nova arquitetura SOLID
class DefensivosEmptyStateWidget extends StatelessWidget {
  final VoidCallback onClearFilters;
  final String? customMessage;
  final String? customTitle;
  final bool showClearButton;
  final bool showSuggestions;

  const DefensivosEmptyStateWidget({
    super.key,
    required this.onClearFilters,
    this.customMessage,
    this.customTitle,
    this.showClearButton = true,
    this.showSuggestions = true,
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
            customTitle ?? 'Nenhum defensivo encontrado',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            customMessage ?? 
            'Não encontramos defensivos que correspondam aos seus critérios de busca. '
            'Tente ajustar os filtros ou limpar todas as configurações.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (showClearButton)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpar Filtros'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          if (showClearButton) const SizedBox(height: 16),
          if (showSuggestions) _buildSuggestions(theme),
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
}

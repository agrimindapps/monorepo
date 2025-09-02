import 'package:flutter/material.dart';

/// **COMENTARIOS EMPTY STATE WIDGET**
/// 
/// Displays when no comentarios are available to show.
/// Provides contextual messaging based on whether filters are applied.
/// 
/// ## Features:
/// 
/// - **Context Awareness**: Different messages for filtered vs unfiltered views
/// - **Visual Consistency**: Matches app-receituagro empty state design
/// - **Action Guidance**: Suggests next steps for the user
/// - **Accessibility**: Proper semantic labels for screen readers

class ComentariosEmptyStateWidget extends StatelessWidget {
  final bool hasFilters;
  final String? filterContext;
  final String? filterTool;

  const ComentariosEmptyStateWidget({
    super.key,
    this.hasFilters = false,
    this.filterContext,
    this.filterTool,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 12),
            _buildDescription(),
            const SizedBox(height: 32),
            if (hasFilters) _buildClearFiltersHint(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        hasFilters ? Icons.search_off : Icons.comment_outlined,
        size: 48,
        color: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _getTitle(),
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      _getDescription(),
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[600],
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildClearFiltersHint() {
    return Text(
      'Toque no botão de filtros para ver todos os comentários',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[500],
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
  }

  String _getTitle() {
    if (hasFilters) {
      return 'Nenhum comentário encontrado';
    }
    return 'Nenhum comentário ainda';
  }

  String _getDescription() {
    if (hasFilters) {
      return _getFilteredDescription();
    }
    return 'Adicione suas anotações pessoais sobre pragas, doenças, defensivos e diagnósticos.';
  }

  String _getFilteredDescription() {
    final parts = <String>['Não há comentários'];

    if (filterTool?.isNotEmpty == true && filterContext?.isNotEmpty == true) {
      parts.add('na seção "$filterTool" para o item "$filterContext"');
    } else if (filterTool?.isNotEmpty == true) {
      parts.add('na seção "$filterTool"');
    } else if (filterContext?.isNotEmpty == true) {
      parts.add('para o item "$filterContext"');
    } else {
      parts.add('com os filtros aplicados');
    }

    parts.add('Tente remover os filtros ou adicione um novo comentário.');

    return parts.join(' ');
  }

  /// Factory constructor for general empty state
  static ComentariosEmptyStateWidget general() {
    return const ComentariosEmptyStateWidget();
  }

  /// Factory constructor for filtered empty state
  static ComentariosEmptyStateWidget filtered({
    String? filterContext,
    String? filterTool,
  }) {
    return ComentariosEmptyStateWidget(
      hasFilters: true,
      filterContext: filterContext,
      filterTool: filterTool,
    );
  }

  /// Factory constructor for search empty state
  static ComentariosEmptyStateWidget search(String searchQuery) {
    return ComentariosEmptyStateWidget(
      hasFilters: true,
      filterTool: 'busca por "$searchQuery"',
    );
  }
}
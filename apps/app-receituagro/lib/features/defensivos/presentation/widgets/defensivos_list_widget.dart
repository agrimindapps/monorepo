import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/content_section_widget.dart';
import '../../data/defensivo_view_mode.dart';
import '../../domain/entities/defensivo_entity.dart';
import 'defensivos_empty_state_widget.dart';

/// Widget simplificado para exibir lista de defensivos
/// Usa o ContentListItemWidget padrão para consistência visual
///
/// Características:
/// - Design consistente com home defensivos
/// - Renderização otimizada com SliverList ou GridView
/// - Suporte a múltiplos modos de visualização (list/grid)
/// - Items limpos e minimalistas
/// - Estado vazio integrado
class DefensivosListWidget extends StatelessWidget {
  final List<DefensivoEntity> defensivos;
  final bool modoComparacao;
  final List<DefensivoEntity> defensivosSelecionados;
  final void Function(DefensivoEntity) onTap;
  final void Function(DefensivoEntity)? onSelecaoChanged;
  final VoidCallback onClearFilters;
  final bool hasActiveSearch;
  final DefensivoViewMode viewMode;

  const DefensivosListWidget({
    super.key,
    required this.defensivos,
    required this.modoComparacao,
    required this.defensivosSelecionados,
    required this.onTap,
    this.onSelecaoChanged,
    required this.onClearFilters,
    this.hasActiveSearch = false,
    this.viewMode = DefensivoViewMode.list,
  });

  @override
  Widget build(BuildContext context) {
    if (defensivos.isEmpty) {
      return DefensivosEmptyStateWidget(
        onClearFilters: onClearFilters,
        showClearButton: false,
        showSuggestions: false,
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: viewMode.isList ? _buildListView(context) : _buildGridView(context),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: defensivos.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        indent: 64,
        endIndent: 8,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
      ),
      itemBuilder: (context, index) {
        final defensivo = defensivos[index];

        return RepaintBoundary(
          child: ContentListItemWidget(
            title: defensivo.nome,
            subtitle: defensivo.displayIngredient,
            category: _getCategory(defensivo),
            icon: FontAwesomeIcons.sprayCan,
            iconColor: const Color(0xFF4CAF50),
            onTap: () => onTap(defensivo),
          ),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: defensivos.length,
      itemBuilder: (context, index) {
        final defensivo = defensivos[index];

        return RepaintBoundary(
          child: _buildGridCard(context, defensivo),
        );
      },
    );
  }

  Widget _buildGridCard(BuildContext context, DefensivoEntity defensivo) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onTap(defensivo),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  FontAwesomeIcons.sprayCan,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              // Title
              Expanded(
                child: Text(
                  defensivo.nome,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              // Subtitle
              Text(
                defensivo.displayIngredient,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Category chip
              if (_getCategory(defensivo) != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getCategory(defensivo)!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF4CAF50),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _getCategory(DefensivoEntity defensivo) {
    if (defensivo.classeAgronomica?.isNotEmpty == true) {
      return defensivo.classeAgronomica;
    }
    if (defensivo.modoAcao?.isNotEmpty == true) {
      return defensivo.modoAcao;
    }
    return null;
  }
}

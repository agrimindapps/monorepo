import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/content_section_widget.dart';
import '../../domain/entities/defensivo_group_entity.dart';
import 'defensivos_empty_state_widget.dart';

/// Widget para exibir lista de grupos de defensivos
/// Mantém consistência visual com DefensivosListWidget
/// Otimizado para drill-down navigation
class DefensivosGroupListWidget extends StatelessWidget {
  final List<DefensivoGroupEntity> grupos;
  final void Function(DefensivoGroupEntity) onGroupTap;
  final VoidCallback onClearFilters;
  final String? searchText;

  const DefensivosGroupListWidget({
    super.key,
    required this.grupos,
    required this.onGroupTap,
    required this.onClearFilters,
    this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    if (grupos.isEmpty) {
      return DefensivosEmptyStateWidget(
        onClearFilters: onClearFilters,
        customMessage: searchText != null && searchText!.isNotEmpty
            ? 'Nenhum grupo encontrado para "$searchText"'
            : 'Nenhum grupo de defensivos encontrado',
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: grupos.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            indent: 64,
            endIndent: 8,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          itemBuilder: (context, index) {
            final grupo = grupos[index];
            
            return RepaintBoundary(
              child: ContentListItemWidget(
                title: grupo.displayName,
                subtitle: _buildSubtitle(grupo),
                category: _buildCategory(grupo),
                icon: _getGroupIcon(grupo.tipoAgrupamento),
                iconColor: _getGroupIconColor(grupo.tipoAgrupamento),
                trailing: _buildTrailing(context, grupo),
                onTap: () => onGroupTap(grupo),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Constrói o subtitle do grupo
  String _buildSubtitle(DefensivoGroupEntity grupo) {
    if (grupo.displayDescricao.isNotEmpty) {
      return grupo.displayDescricao;
    }
    return grupo.displayCount;
  }

  /// Constrói a categoria do grupo
  String? _buildCategory(DefensivoGroupEntity grupo) {
    switch (grupo.tipoAgrupamento.toLowerCase()) {
      case 'fabricante':
      case 'fabricantes':
        return 'Por Fabricante';
      case 'modo_acao':
      case 'modoacao':
        return 'Por Modo de Ação';
      case 'classe':
      case 'classe_agronomica':
        return 'Por Classe Agronômica';
      case 'categoria':
        return 'Por Categoria';
      case 'toxico':
      case 'toxicidade':
        return 'Por Toxicidade';
      default:
        return 'Agrupamento';
    }
  }

  /// Obtém ícone para o tipo de agrupamento
  IconData _getGroupIcon(String tipoAgrupamento) {
    switch (tipoAgrupamento.toLowerCase()) {
      case 'fabricante':
      case 'fabricantes':
        return FontAwesomeIcons.industry;
      case 'modo_acao':
      case 'modoacao':
        return FontAwesomeIcons.crosshairs;
      case 'classe':
      case 'classe_agronomica':
        return FontAwesomeIcons.tags;
      case 'categoria':
        return FontAwesomeIcons.layerGroup;
      case 'toxico':
      case 'toxicidade':
        return FontAwesomeIcons.triangleExclamation;
      default:
        return FontAwesomeIcons.folderOpen;
    }
  }

  /// Obtém cor do ícone para o tipo de agrupamento
  Color _getGroupIconColor(String tipoAgrupamento) {
    switch (tipoAgrupamento.toLowerCase()) {
      case 'fabricante':
      case 'fabricantes':
        return const Color(0xFF2196F3); // Azul para fabricantes
      case 'modo_acao':
      case 'modoacao':
        return const Color(0xFF9C27B0); // Roxo para modo de ação
      case 'classe':
      case 'classe_agronomica':
        return const Color(0xFF4CAF50); // Verde para classe
      case 'categoria':
        return const Color(0xFFFF9800); // Laranja para categoria
      case 'toxico':
      case 'toxicidade':
        return const Color(0xFFF44336); // Vermelho para toxicidade
      default:
        return const Color(0xFF607D8B); // Cinza azulado padrão
    }
  }

  /// Constrói widget trailing com contador
  Widget _buildTrailing(BuildContext context, DefensivoGroupEntity grupo) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge com contador
        if (grupo.quantidadeItens > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getGroupIconColor(grupo.tipoAgrupamento).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              grupo.quantidadeItens.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getGroupIconColor(grupo.tipoAgrupamento),
              ),
            ),
          ),
        
        const SizedBox(width: 8),
        
        // Seta de navegação
        Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          size: 20,
        ),
      ],
    );
  }
}

/// Widget para estatísticas dos grupos
class DefensivosGroupStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const DefensivosGroupStatsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalGrupos = stats['totalGrupos'] ?? 0;
    final totalItens = stats['totalItens'] ?? 0;
    final mediaItens = stats['mediaItensPerGrupo'] ?? 0;

    if (totalGrupos == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            'Grupos',
            totalGrupos.toString(),
            FontAwesomeIcons.folderOpen,
          ),
          _buildStatItem(
            context,
            'Total',
            totalItens.toString(),
            FontAwesomeIcons.sprayCan,
          ),
          _buildStatItem(
            context,
            'Média',
            mediaItens.toString(),
            FontAwesomeIcons.chartLine,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
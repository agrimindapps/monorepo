import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget especializado para filtros de defensivos
/// Permite filtrar por múltiplos critérios simultaneamente
class FiltrosDefensivosWidget extends StatelessWidget {
  final String ordenacao;
  final String filtroToxicidade;
  final String filtroTipo;
  final bool apenasComercializados;
  final bool apenasElegiveis;
  final ValueChanged<String> onOrdenacaoChanged;
  final ValueChanged<String> onToxicidadeChanged;
  final ValueChanged<String> onTipoChanged;
  final ValueChanged<bool> onComercializadosChanged;
  final ValueChanged<bool> onElegiveisChanged;

  const FiltrosDefensivosWidget({
    super.key,
    required this.ordenacao,
    required this.filtroToxicidade,
    required this.filtroTipo,
    required this.apenasComercializados,
    required this.apenasElegiveis,
    required this.onOrdenacaoChanged,
    required this.onToxicidadeChanged,
    required this.onTipoChanged,
    required this.onComercializadosChanged,
    required this.onElegiveisChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.tune,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          'Filtros Avançados',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          _getDescricaoFiltros(),
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Primeira linha: Ordenação e Toxicidade
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownFiltro(
                        theme: theme,
                        label: 'Ordenar por',
                        valor: ordenacao,
                        opcoes: const {
                          'prioridade': 'Prioridade',
                          'nome': 'Nome',
                          'fabricante': 'Fabricante',
                          'usos': 'Quantidade de Usos',
                        },
                        icon: Icons.sort,
                        color: Colors.purple,
                        onChanged: onOrdenacaoChanged,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownFiltro(
                        theme: theme,
                        label: 'Toxicidade',
                        valor: filtroToxicidade,
                        opcoes: const {
                          'todos': 'Todas',
                          'baixa': 'Baixa (IV)',
                          'media': 'Média (III)',
                          'alta': 'Alta (II)',
                          'extrema': 'Extrema (I)',
                        },
                        icon: FontAwesomeIcons.skull,
                        color: Colors.red,
                        onChanged: onToxicidadeChanged,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Segunda linha: Tipo de defensivo
                _buildDropdownFiltro(
                  theme: theme,
                  label: 'Tipo de Defensivo',
                  valor: filtroTipo,
                  opcoes: const {
                    'todos': 'Todos os tipos',
                    'fungicida': 'Fungicidas',
                    'inseticida': 'Inseticidas',
                    'herbicida': 'Herbicidas',
                    'acaricida': 'Acaricidas',
                    'nematicida': 'Nematicidas',
                    'bactericida': 'Bactericidas',
                  },
                  icon: FontAwesomeIcons.vial,
                  color: Colors.blue,
                  onChanged: onTipoChanged,
                ),
                
                const SizedBox(height: 16),
                
                // Switches de filtros booleanos
                _buildFiltrosBooleanos(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFiltro({
    required ThemeData theme,
    required String label,
    required String valor,
    required Map<String, String> opcoes,
    required IconData icon,
    required Color color,
    required ValueChanged<String> onChanged,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: valor != opcoes.keys.first
              ? color.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: valor != opcoes.keys.first ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: valor != opcoes.keys.first
            ? color.withValues(alpha: 0.05)
            : theme.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do filtro
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: valor != opcoes.keys.first
                  ? color.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: valor != opcoes.keys.first
                        ? color
                        : theme.colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valor != opcoes.keys.first
                        ? color
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: valor,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              dropdownColor: theme.cardColor,
              items: opcoes.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) => onChanged(value!),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosBooleanos(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Filtros de Status',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildSwitchFiltro(
                  theme: theme,
                  label: 'Apenas Comercializados',
                  valor: apenasComercializados,
                  icon: Icons.store,
                  color: Colors.green,
                  onChanged: onComercializadosChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSwitchFiltro(
                  theme: theme,
                  label: 'Apenas Elegíveis',
                  valor: apenasElegiveis,
                  icon: Icons.verified,
                  color: Colors.blue,
                  onChanged: onElegiveisChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchFiltro({
    required ThemeData theme,
    required String label,
    required bool valor,
    required IconData icon,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: valor ? color.withValues(alpha: 0.1) : theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: valor
              ? color.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: valor ? color : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: valor ? color : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  String _getDescricaoFiltros() {
    final filtrosAtivos = <String>[];
    
    if (ordenacao != 'prioridade') {
      filtrosAtivos.add('ordenação customizada');
    }
    
    if (filtroToxicidade != 'todos') {
      filtrosAtivos.add('toxicidade específica');
    }
    
    if (filtroTipo != 'todos') {
      filtrosAtivos.add('tipo específico');
    }
    
    if (apenasComercializados) {
      filtrosAtivos.add('comercializados');
    }
    
    if (apenasElegiveis) {
      filtrosAtivos.add('elegíveis');
    }
    
    if (filtrosAtivos.isEmpty) {
      return 'Nenhum filtro ativo';
    }
    
    return '${filtrosAtivos.length} filtro(s) ativo(s)';
  }
}
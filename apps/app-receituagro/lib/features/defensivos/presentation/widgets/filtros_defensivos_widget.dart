import 'package:flutter/material.dart';

/// Widget especializado para filtros de defensivos
/// Permite filtrar por múltiplos critérios simultaneamente
/// Migrado e adaptado de defensivos_agrupados para nova arquitetura SOLID
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
        ),
        title: const Text(
          'Filtros Avançados',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          _buildSubtitleText(),
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildOrdenacaoSection(theme),
                const SizedBox(height: 16),
                _buildFiltrosSection(theme),
                const SizedBox(height: 16),
                _buildToggleSection(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitleText() {
    final filtros = <String>[];
    if (filtroToxicidade != 'todos')
      filtros.add('Toxicidade: $filtroToxicidade');
    if (filtroTipo != 'todos') filtros.add('Tipo: $filtroTipo');
    if (apenasComercializados) filtros.add('Comercializados');
    if (apenasElegiveis) filtros.add('Elegíveis');

    return filtros.isEmpty ? 'Sem filtros aplicados' : filtros.join(' • ');
  }

  Widget _buildOrdenacaoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenação',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: ordenacao,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: const [
            DropdownMenuItem(value: 'prioridade', child: Text('Prioridade')),
            DropdownMenuItem(value: 'nome', child: Text('Nome')),
            DropdownMenuItem(value: 'fabricante', child: Text('Fabricante')),
            DropdownMenuItem(value: 'usos', child: Text('Quantidade de usos')),
          ],
          onChanged: (value) {
            if (value != null) onOrdenacaoChanged(value);
          },
        ),
      ],
    );
  }

  Widget _buildFiltrosSection(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toxicidade',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: filtroToxicidade,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(
                        value: 'baixa',
                        child: Text('Baixa (IV)'),
                      ),
                      DropdownMenuItem(
                        value: 'media',
                        child: Text('Média (III)'),
                      ),
                      DropdownMenuItem(value: 'alta', child: Text('Alta (II)')),
                      DropdownMenuItem(
                        value: 'extrema',
                        child: Text('Extrema (I)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) onToxicidadeChanged(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: filtroTipo,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(
                        value: 'fungicida',
                        child: Text('Fungicida'),
                      ),
                      DropdownMenuItem(
                        value: 'inseticida',
                        child: Text('Inseticida'),
                      ),
                      DropdownMenuItem(
                        value: 'herbicida',
                        child: Text('Herbicida'),
                      ),
                      DropdownMenuItem(
                        value: 'acaricida',
                        child: Text('Acaricida'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) onTipoChanged(value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opções Adicionais',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text(
                  'Apenas Comercializados',
                  style: TextStyle(fontSize: 14),
                ),
                value: apenasComercializados,
                onChanged: (value) {
                  if (value != null) onComercializadosChanged(value);
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text(
                  'Apenas Elegíveis',
                  style: TextStyle(fontSize: 14),
                ),
                value: apenasElegiveis,
                onChanged: (value) {
                  if (value != null) onElegiveisChanged(value);
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../core/extensions/diagnostico_detalhado_extension.dart';
import '../../../core/services/diagnostico_integration_service.dart';

/// Widget que exibe estatísticas das pragas de uma cultura
/// Mostra métricas agrupadas e filtros da cultura selecionada
class EstatisticasCulturaWidget extends StatelessWidget {
  final String nomeCultura;
  final List<PragaPorCultura> pragasPorCultura;
  final String ordenacao;
  final String filtroTipo;
  final ValueChanged<String> onOrdenacaoChanged;
  final ValueChanged<String> onFiltroTipoChanged;

  const EstatisticasCulturaWidget({
    super.key,
    required this.nomeCultura,
    required this.pragasPorCultura,
    required this.ordenacao,
    required this.filtroTipo,
    required this.onOrdenacaoChanged,
    required this.onFiltroTipoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            _buildEstatisticasGrid(theme),
            const SizedBox(height: 16),
            _buildFiltrosOrdenacao(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final pragasCriticas = pragasPorCultura.where((p) => p.isCritica).length;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.analytics,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Análise de Pragas - $nomeCultura',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${pragasPorCultura.length} praga(s) • $pragasCriticas crítica(s)',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (pragasCriticas > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'ATENÇÃO',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEstatisticasGrid(ThemeData theme) {
    final totalDiagnosticos = pragasPorCultura
        .map((p) => p.quantidadeDiagnosticos)
        .fold(0, (a, b) => a + b);
    
    final totalDefensivos = pragasPorCultura
        .expand((p) => p.defensivosRelacionados)
        .toSet()
        .length;
    
    final pragasCriticas = pragasPorCultura.where((p) => p.isCritica).length;
    
    final pragasAltoRisco = pragasPorCultura.where((p) => p.nivelAmeaca == 'Alto').length;

    final metricas = [
      {
        'label': 'Total Pragas',
        'valor': '${pragasPorCultura.length}',
        'icon': FontAwesomeIcons.bug,
        'color': Colors.red,
      },
      {
        'label': 'Diagnósticos',
        'valor': '$totalDiagnosticos',
        'icon': Icons.medical_services,
        'color': Colors.blue,
      },
      {
        'label': 'Defensivos',
        'valor': '$totalDefensivos',
        'icon': FontAwesomeIcons.vial,
        'color': Colors.green,
      },
      {
        'label': 'Críticas',
        'valor': '$pragasCriticas',
        'icon': Icons.dangerous,
        'color': Colors.red,
      },
      {
        'label': 'Alto Risco',
        'valor': '$pragasAltoRisco',
        'icon': Icons.warning,
        'color': Colors.orange,
      },
      {
        'label': 'Cultura',
        'valor': 'ATIVA',
        'icon': FontAwesomeIcons.seedling,
        'color': Colors.green,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: metricas.length,
      itemBuilder: (context, index) {
        final metrica = metricas[index];
        return _buildMetricaCard(theme, metrica);
      },
    );
  }

  Widget _buildMetricaCard(ThemeData theme, Map<String, dynamic> metrica) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (metrica['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (metrica['color'] as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            metrica['icon'] as IconData,
            size: 16,
            color: metrica['color'] as Color,
          ),
          const SizedBox(height: 4),
          Text(
            metrica['valor'] as String,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: metrica['color'] as Color,
            ),
          ),
          Text(
            metrica['label'] as String,
            style: TextStyle(
              fontSize: 9,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosOrdenacao(ThemeData theme) {
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.tune,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Filtros e Ordenação',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildDropdownFiltro(
                theme: theme,
                label: 'Ordenar por',
                valor: ordenacao,
                opcoes: const {
                  'ameaca': 'Nível de Ameaça',
                  'nome': 'Nome da Praga',
                  'diagnosticos': 'Quantidade Diagnósticos',
                },
                icon: Icons.sort,
                color: Colors.purple,
                onChanged: onOrdenacaoChanged,
              ),
              const SizedBox(height: 12),
              _buildDropdownFiltro(
                theme: theme,
                label: 'Filtrar por',
                valor: filtroTipo,
                opcoes: const {
                  'todos': 'Todas as Pragas',
                  'criticas': 'Apenas Críticas',
                  'normais': 'Apenas Normais',
                },
                icon: Icons.filter_list,
                color: Colors.blue,
                onChanged: onFiltroTipoChanged,
              ),
            ],
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
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: valor != opcoes.keys.first
            ? color.withValues(alpha: 0.05)
            : theme.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: valor != opcoes.keys.first
                  ? color.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: valor != opcoes.keys.first
                        ? color
                        : theme.colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    icon,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: valor != opcoes.keys.first
                        ? color
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: DropdownButtonFormField<String>(
              value: valor,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              dropdownColor: theme.cardColor,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
              items: opcoes.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) => onChanged(value!),
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

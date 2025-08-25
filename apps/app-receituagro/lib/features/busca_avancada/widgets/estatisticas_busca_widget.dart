import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/extensions/diagnostico_detalhado_extension.dart';
import '../../../core/services/diagnostico_integration_service.dart';

/// Widget que exibe estatísticas dos resultados da busca
/// Mostra informações agrupadas e métricas importantes
class EstatisticasBuscaWidget extends StatelessWidget {
  final List<DiagnosticoDetalhado> resultados;
  final Map<String, String> filtros;

  const EstatisticasBuscaWidget({
    super.key,
    required this.resultados,
    required this.filtros,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estatisticas = resultados.estatisticas;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            _buildFiltrosAplicados(theme),
            const SizedBox(height: 16),
            _buildEstatisticasGrid(theme, estatisticas),
            const SizedBox(height: 16),
            _buildAgrupamentos(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
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
                'Estatísticas da Busca',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${resultados.length} resultado(s) encontrado(s)',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFiltrosAplicados(ThemeData theme) {
    if (filtros.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Filtros Aplicados',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: filtros.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEstatisticasGrid(ThemeData theme, Map<String, int> estatisticas) {
    final metricas = [
      {
        'label': 'Total',
        'valor': estatisticas['total']!,
        'icon': Icons.list,
        'color': Colors.blue,
      },
      {
        'label': 'Válidos',
        'valor': estatisticas['validos']!,
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'label': 'Críticos',
        'valor': estatisticas['criticos']!,
        'icon': Icons.warning,
        'color': Colors.red,
      },
      {
        'label': 'Culturas',
        'valor': estatisticas['culturas_unicas']!,
        'icon': FontAwesomeIcons.seedling,
        'color': Colors.green,
      },
      {
        'label': 'Pragas',
        'valor': estatisticas['pragas_unicas']!,
        'icon': FontAwesomeIcons.bug,
        'color': Colors.red,
      },
      {
        'label': 'Defensivos',
        'valor': estatisticas['defensivos_unicos']!,
        'icon': FontAwesomeIcons.vial,
        'color': Colors.blue,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                metrica['icon'] as IconData,
                size: 16,
                color: metrica['color'] as Color,
              ),
              const SizedBox(width: 6),
              Text(
                '${metrica['valor']}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: metrica['color'] as Color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            metrica['label'] as String,
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgrupamentos(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agrupamentos',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildAgrupamentoCard(theme, 'Por Cultura', resultados.agrupadosPorCultura)),
            const SizedBox(width: 8),
            Expanded(child: _buildAgrupamentoCard(theme, 'Por Praga', resultados.agrupadosPorPraga)),
            const SizedBox(width: 8),
            Expanded(child: _buildAgrupamentoCard(theme, 'Por Defensivo', resultados.agrupadosPorDefensivo)),
          ],
        ),
      ],
    );
  }

  Widget _buildAgrupamentoCard(
    ThemeData theme, 
    String titulo, 
    Map<String, List<DiagnosticoDetalhado>> agrupamento,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${agrupamento.length}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          if (agrupamento.isNotEmpty) ...[
            Text(
              'Maior grupo: ${agrupamento.values.map((e) => e.length).reduce((a, b) => a > b ? a : b)}',
              style: TextStyle(
                fontSize: 9,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
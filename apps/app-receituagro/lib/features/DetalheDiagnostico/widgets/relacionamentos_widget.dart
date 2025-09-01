import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/services/diagnostico_integration_service.dart';

/// Widget especializado para exibir relacionamentos entre entidades
/// Permite navegar para outras pragas da cultura, defensivos da praga, etc.
class RelacionamentosWidget extends StatelessWidget {
  final DiagnosticoDetalhado diagnosticoDetalhado;
  final VoidCallback? onCulturaPressed;
  final VoidCallback? onPragaPressed;
  final VoidCallback? onDefensivoPressed;

  const RelacionamentosWidget({
    super.key,
    required this.diagnosticoDetalhado,
    this.onCulturaPressed,
    this.onPragaPressed,
    this.onDefensivoPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme),
        const SizedBox(height: 16),
        _buildRelacionamentosCards(theme),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.device_hub,
            color: Colors.purple,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Relacionamentos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Explore dados relacionados',
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

  Widget _buildRelacionamentosCards(ThemeData theme) {
    return Column(
      children: [
        if (diagnosticoDetalhado.cultura != null)
          _buildRelacionamentoCard(
            theme: theme,
            titulo: 'Outras Pragas desta Cultura',
            subtitulo: 'Ver outras pragas que atacam ${diagnosticoDetalhado.nomeCultura}',
            icon: FontAwesomeIcons.seedling,
            color: Colors.green,
            onTap: onCulturaPressed,
          ),
        const SizedBox(height: 12),
        
        if (diagnosticoDetalhado.praga != null)
          _buildRelacionamentoCard(
            theme: theme,
            titulo: 'Outros Defensivos para esta Praga',
            subtitulo: 'Ver outros produtos para controle de ${diagnosticoDetalhado.nomePraga}',
            icon: FontAwesomeIcons.bug,
            color: Colors.red,
            onTap: onPragaPressed,
          ),
        const SizedBox(height: 12),
        
        if (diagnosticoDetalhado.defensivo != null)
          _buildRelacionamentoCard(
            theme: theme,
            titulo: 'Outros Usos deste Defensivo',
            subtitulo: 'Ver outras aplicações de ${diagnosticoDetalhado.nomeComercialDefensivo}',
            icon: FontAwesomeIcons.vial,
            color: Colors.blue,
            onTap: onDefensivoPressed,
          ),
        const SizedBox(height: 12),
        
        _buildEstatisticasCard(theme),
      ],
    );
  }

  Widget _buildRelacionamentoCard({
    required ThemeData theme,
    required String titulo,
    required String subtitulo,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.8),
                      color,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstatisticasCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Estatísticas do Diagnóstico',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEstatisticasGrid(theme),
        ],
      ),
    );
  }

  Widget _buildEstatisticasGrid(ThemeData theme) {
    final estatisticas = [
      {
        'label': 'Completude',
        'valor': diagnosticoDetalhado.hasInfoCompleta ? '100%' : 'Parcial',
        'icon': diagnosticoDetalhado.hasInfoCompleta ? Icons.check_circle : Icons.warning,
        'color': diagnosticoDetalhado.hasInfoCompleta ? Colors.green : Colors.orange,
      },
      {
        'label': 'Criticidade',
        'valor': diagnosticoDetalhado.isCritico ? 'Alta' : 'Normal',
        'icon': diagnosticoDetalhado.isCritico ? Icons.dangerous : Icons.check,
        'color': diagnosticoDetalhado.isCritico ? Colors.red : Colors.green,
      },
      {
        'label': 'Aplicação Terrestre',
        'valor': diagnosticoDetalhado.temAplicacaoTerrestre ? 'Sim' : 'Não',
        'icon': FontAwesomeIcons.tractor,
        'color': diagnosticoDetalhado.temAplicacaoTerrestre ? Colors.brown : Colors.grey,
      },
      {
        'label': 'Aplicação Aérea',
        'valor': diagnosticoDetalhado.temAplicacaoAerea ? 'Sim' : 'Não',
        'icon': FontAwesomeIcons.helicopter,
        'color': diagnosticoDetalhado.temAplicacaoAerea ? Colors.blue : Colors.grey,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: estatisticas.length,
      itemBuilder: (context, index) {
        final stat = estatisticas[index];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (stat['color'] as Color).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                stat['icon'] as IconData,
                size: 16,
                color: stat['color'] as Color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      stat['valor'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: stat['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
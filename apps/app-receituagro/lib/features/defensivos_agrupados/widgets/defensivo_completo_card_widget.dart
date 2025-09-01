import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/extensions/diagnostico_detalhado_extension.dart';
import '../../../core/services/diagnostico_integration_service.dart';

/// Widget especializado para exibir um defensivo completo
/// Mostra dados integrados de FitossanitarioHive + FitossanitarioInfoHive + DiagnosticoHive
class DefensivoCompletoCardWidget extends StatelessWidget {
  final DefensivoCompleto defensivoCompleto;
  final bool modoComparacao;
  final bool isSelecionado;
  final VoidCallback? onTap;
  final VoidCallback? onSelecaoChanged;

  const DefensivoCompletoCardWidget({
    super.key,
    required this.defensivoCompleto,
    this.modoComparacao = false,
    this.isSelecionado = false,
    this.onTap,
    this.onSelecaoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isSelecionado ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelecionado 
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: modoComparacao ? onSelecaoChanged : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 16),
              _buildInformacoesBasicas(theme),
              const SizedBox(height: 16),
              _buildEstatisticasUso(theme),
              if (defensivoCompleto.temAlertas) ...[
                const SizedBox(height: 12),
                _buildAlertas(theme),
              ],
              const SizedBox(height: 12),
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getGradientColors(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconePrioridade(),
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                defensivoCompleto.defensivo.nomeComum ?? 
                defensivoCompleto.defensivo.nomeTecnico,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                defensivoCompleto.defensivo.fabricante ?? 'Fabricante não informado',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildChip(theme, defensivoCompleto.categoria, _getCategoriaColor()),
                  const SizedBox(width: 8),
                  if (defensivoCompleto.isComercializado)
                    _buildChip(theme, 'Comercializado', Colors.green),
                  if (defensivoCompleto.isElegivel)
                    _buildChip(theme, 'Elegível', Colors.blue),
                ],
              ),
            ],
          ),
        ),
        if (modoComparacao)
          Checkbox(
            value: isSelecionado,
            onChanged: (_) => onSelecaoChanged?.call(),
            activeColor: theme.colorScheme.primary,
          )
        else
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }

  Widget _buildInformacoesBasicas(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            theme,
            'Ingrediente Ativo',
            defensivoCompleto.defensivo.ingredienteAtivo ?? 'N/A',
            FontAwesomeIcons.atom,
            Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            theme,
            'Classe Agronômica',
            defensivoCompleto.defensivo.classeAgronomica ?? 'N/A',
            Icons.category,
            Colors.blue,
          ),
          if (defensivoCompleto.defensivo.modoAcao != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              theme,
              'Modo de Ação',
              defensivoCompleto.defensivo.modoAcao!,
              FontAwesomeIcons.bolt,
              Colors.orange,
            ),
          ],
          if (defensivoCompleto.defensivo.formulacao != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              theme,
              'Formulação',
              defensivoCompleto.defensivo.formulacao!,
              FontAwesomeIcons.vial,
              Colors.green,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String valor,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstatisticasUso(ThemeData theme) {
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
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Estatísticas de Uso',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEstatisticaItem(
                  theme,
                  'Diagnósticos',
                  '${defensivoCompleto.quantidadeDiagnosticos}',
                  Icons.medical_services,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEstatisticaItem(
                  theme,
                  'Culturas',
                  '${defensivoCompleto.culturasRelacionadas.length}',
                  FontAwesomeIcons.seedling,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEstatisticaItem(
                  theme,
                  'Pragas',
                  '${defensivoCompleto.pragasRelacionadas.length}',
                  FontAwesomeIcons.bug,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstatisticaItem(
    ThemeData theme,
    String label,
    String valor,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertas(ThemeData theme) {
    final alertas = <Widget>[];
    
    if (defensivoCompleto.defensivo.toxico != null) {
      alertas.add(_buildAlerta(
        theme,
        'Toxicidade ${defensivoCompleto.defensivo.toxico}',
        Icons.warning,
        _getToxicidadeColor(defensivoCompleto.defensivo.toxico!),
      ));
    }
    
    if (defensivoCompleto.defensivo.corrosivo == 'Sim') {
      alertas.add(_buildAlerta(
        theme,
        'Corrosivo',
        FontAwesomeIcons.droplet,
        Colors.orange,
      ));
    }
    
    if (defensivoCompleto.defensivo.inflamavel == 'Sim') {
      alertas.add(_buildAlerta(
        theme,
        'Inflamável',
        FontAwesomeIcons.fire,
        Colors.red,
      ));
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: alertas,
    );
  }

  Widget _buildAlerta(ThemeData theme, String texto, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        // Principais culturas relacionadas
        if (defensivoCompleto.culturasRelacionadas.isNotEmpty) ...[
          const Icon(
            FontAwesomeIcons.seedling,
            size: 12,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              defensivoCompleto.culturasRelacionadas.take(3).join(', '),
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        
        const Spacer(),
        
        // Registro MAPA se disponível
        if (defensivoCompleto.defensivo.mapa != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'MAPA: ${defensivoCompleto.defensivo.mapa}',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChip(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (defensivoCompleto.categoria) {
      case 'Alta Prioridade':
        return [Colors.green.shade400, Colors.green.shade600];
      case 'Média Prioridade':
        return [Colors.orange.shade400, Colors.orange.shade600];
      default:
        return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  IconData _getIconePrioridade() {
    switch (defensivoCompleto.categoria) {
      case 'Alta Prioridade':
        return Icons.star;
      case 'Média Prioridade':
        return Icons.star_half;
      default:
        return Icons.star_border;
    }
  }

  Color _getCategoriaColor() {
    switch (defensivoCompleto.categoria) {
      case 'Alta Prioridade':
        return Colors.green;
      case 'Média Prioridade':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getToxicidadeColor(String toxicidade) {
    final lower = toxicidade.toLowerCase();
    if (lower.contains('i') && !lower.contains('ii') && !lower.contains('iii') && !lower.contains('iv')) {
      return Colors.red;
    } else if (lower.contains('ii')) {
      return Colors.orange;
    } else if (lower.contains('iii')) {
      return Colors.amber;
    } else if (lower.contains('iv')) {
      return Colors.green;
    }
    return Colors.grey;
  }
}
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/diagnostico_detalhado_extension.dart';
import '../../../core/services/diagnostico_integration_service.dart';
import '../../../core/widgets/praga_image_widget.dart';

/// Widget especializado para exibir uma praga por cultura
/// Mostra dados integrados de PragasHive + DiagnosticoHive relacionados
class PragaPorCulturaCardWidget extends StatelessWidget {
  final PragaPorCultura pragaPorCultura;
  final VoidCallback? onTap;
  final VoidCallback? onVerDefensivos;

  const PragaPorCulturaCardWidget({
    super.key,
    required this.pragaPorCultura,
    this.onTap,
    this.onVerDefensivos,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: pragaPorCultura.isCritica ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: pragaPorCultura.isCritica 
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 16),
              _buildInformacoesTaxonomicas(theme),
              const SizedBox(height: 16),
              _buildEstatisticasUso(theme),
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
        PragaImageWidget(
          nomeCientifico: pragaPorCultura.praga.nomeCientifico,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(12),
          errorWidget: Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: pragaPorCultura.isCritica 
                    ? [Colors.red.shade400, Colors.red.shade600]
                    : [Colors.orange.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              pragaPorCultura.isCritica ? Icons.dangerous : FontAwesomeIcons.bug,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pragaPorCultura.praga.nomeComum ?? pragaPorCultura.praga.nomeCientifico,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              ...[
              const SizedBox(height: 4),
              Text(
                pragaPorCultura.praga.nomeCientifico,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildChip(
                    theme, 
                    pragaPorCultura.nivelAmeaca, 
                    _getNivelAmeacaColor(),
                  ),
                  const SizedBox(width: 8),
                  if (pragaPorCultura.isCritica)
                    _buildChip(theme, 'Crítica', Colors.red),
                ],
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
    );
  }

  Widget _buildInformacoesTaxonomicas(ThemeData theme) {
    final info = pragaPorCultura.informacoesTaxonomicas;
    if (info.isEmpty) return const SizedBox.shrink();
    
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
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.science,
                  size: 14,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Taxonomia',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: info.entries.take(4).map((entry) {
              return _buildTaxonomiaItem(theme, entry.key, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxonomiaItem(ThemeData theme, String label, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            label,
            style: TextStyle(
              fontSize: 9,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstatisticasUso(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.errorContainer.withValues(alpha: 0.3),
            theme.colorScheme.errorContainer.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.2),
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
                  color: Colors.red,
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
                'Impacto na Cultura',
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
                  '${pragaPorCultura.quantidadeDiagnosticos}',
                  Icons.medical_services,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEstatisticaItem(
                  theme,
                  'Defensivos',
                  '${pragaPorCultura.defensivosRelacionados.length}',
                  FontAwesomeIcons.vial,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEstatisticaItem(
                  theme,
                  'Nível',
                  pragaPorCultura.nivelAmeaca,
                  Icons.warning,
                  _getNivelAmeacaColor(),
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

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        if (pragaPorCultura.defensivosRelacionados.isNotEmpty) ...[
          const Icon(
            FontAwesomeIcons.vial,
            size: 12,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${pragaPorCultura.defensivosRelacionados.length} defensivo(s) disponível(is)',
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
        if (onVerDefensivos != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: onVerDefensivos,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    FontAwesomeIcons.vial,
                    size: 12,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ver Defensivos',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
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

  Color _getNivelAmeacaColor() {
    switch (pragaPorCultura.nivelAmeaca) {
      case 'Alto':
        return Colors.red;
      case 'Médio':
        return Colors.orange;
      case 'Baixo':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

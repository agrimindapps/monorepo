import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/services/diagnostico_integration_service.dart';

/// Widget especializado para exibir um diagnóstico com dados relacionais
/// Mostra informações integradas de DiagnosticoHive, FitossanitarioHive, 
/// CulturaHive e PragasHive em um card visualmente organizado
class DiagnosticoRelacionalCardWidget extends StatelessWidget {
  final DiagnosticoDetalhado diagnosticoDetalhado;
  final VoidCallback? onTap;

  const DiagnosticoRelacionalCardWidget({
    super.key,
    required this.diagnosticoDetalhado,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
              _buildEntidadesRelacionais(theme),
              const SizedBox(height: 16),
              _buildDosagem(theme),
              if (diagnosticoDetalhado.isCritico) ...[
                const SizedBox(height: 12),
                _buildAlertaCritico(theme),
              ],
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
              colors: diagnosticoDetalhado.isCritico 
                  ? [Colors.red.shade400, Colors.red.shade600]
                  : [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            diagnosticoDetalhado.isCritico 
                ? Icons.warning
                : Icons.medical_services,
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
                diagnosticoDetalhado.descricaoResumida,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    diagnosticoDetalhado.hasInfoCompleta 
                        ? Icons.check_circle 
                        : Icons.warning,
                    size: 16,
                    color: diagnosticoDetalhado.hasInfoCompleta 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      diagnosticoDetalhado.hasInfoCompleta 
                          ? 'Informações completas'
                          : 'Informações parciais',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntidadesRelacionais(ThemeData theme) {
    return Column(
      children: [
        _buildEntidadeRow(
          theme: theme,
          icon: FontAwesomeIcons.seedling,
          label: 'Cultura',
          valor: diagnosticoDetalhado.nomeCultura,
          isValid: diagnosticoDetalhado.cultura != null,
          iconColor: Colors.green,
        ),
        const SizedBox(height: 8),
        _buildEntidadeRow(
          theme: theme,
          icon: FontAwesomeIcons.bug,
          label: 'Praga',
          valor: diagnosticoDetalhado.nomePraga,
          detalhes: diagnosticoDetalhado.nomeCientificoPraga != 'N/A' 
              ? diagnosticoDetalhado.nomeCientificoPraga 
              : null,
          isValid: diagnosticoDetalhado.praga != null,
          iconColor: Colors.red,
        ),
        const SizedBox(height: 8),
        _buildEntidadeRow(
          theme: theme,
          icon: FontAwesomeIcons.vial,
          label: 'Defensivo',
          valor: diagnosticoDetalhado.nomeComercialDefensivo,
          detalhes: diagnosticoDetalhado.fabricante != 'N/A' 
              ? diagnosticoDetalhado.fabricante 
              : null,
          isValid: diagnosticoDetalhado.defensivo != null,
          iconColor: Colors.blue,
        ),
        if (diagnosticoDetalhado.ingredienteAtivo != 'N/A') ...[
          const SizedBox(height: 8),
          _buildEntidadeRow(
            theme: theme,
            icon: FontAwesomeIcons.atom,
            label: 'Ingrediente Ativo',
            valor: diagnosticoDetalhado.ingredienteAtivo,
            isValid: true,
            iconColor: Colors.purple,
          ),
        ],
      ],
    );
  }

  Widget _buildEntidadeRow({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String valor,
    String? detalhes,
    required bool isValid,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid 
            ? theme.colorScheme.surfaceContainerLow
            : theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid 
              ? theme.colorScheme.outline.withValues(alpha: 0.2)
              : theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (!isValid) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.error_outline,
                        size: 12,
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isValid 
                        ? theme.colorScheme.onSurface 
                        : theme.colorScheme.error,
                  ),
                ),
                if (detalhes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detalhes,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDosagem(ThemeData theme) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.medication,
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
                  'Dosagem Recomendada',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  diagnosticoDetalhado.dosagem,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertaCritico(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diagnóstico Crítico',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Este diagnóstico requer atenção especial devido à criticidade da praga ou dosagem elevada',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

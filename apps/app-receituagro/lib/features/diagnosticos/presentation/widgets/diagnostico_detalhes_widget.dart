import 'package:flutter/material.dart';

class DiagnosticoDetalhesWidget extends StatelessWidget {
  final Map<String, String> diagnosticoData;

  const DiagnosticoDetalhesWidget({super.key, required this.diagnosticoData});

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 [DEBUG] DiagnosticoDetalhesWidget.build');
    debugPrint('📊 [DEBUG] diagnosticoData: $diagnosticoData');
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhes do Diagnóstico',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildDiagnosticoCards(context),
      ],
    );
  }

  Widget _buildDiagnosticoCards(BuildContext context) {
    final diagnosticoItems = [
      {
        'label': 'Formulação',
        'value': diagnosticoData['formulacao'] ?? 'N/A',
        'icon': Icons.science_outlined,
      },
      {
        'label': 'Modo de Ação',
        'value': diagnosticoData['modoAcao'] ?? 'N/A',
        'icon': Icons.bolt,
      },
      {
        'label': 'Registro MAPA',
        'value': diagnosticoData['mapa'] ?? 'N/A',
        'icon': Icons.verified,
      },
    ];

    debugPrint('🎨 [DEBUG] diagnosticoItems: $diagnosticoItems');

    return Column(
      children: diagnosticoItems
          .map(
            (item) => _buildInfoCard(
              context,
              item['label'] as String,
              item['value'] as String,
              item['icon'] as IconData,
            ),
          )
          .toList(),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
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

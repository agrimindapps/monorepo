import 'package:flutter/material.dart';

class AplicacaoInstrucoesWidget extends StatelessWidget {
  final Map<String, String> diagnosticoData;

  const AplicacaoInstrucoesWidget({
    super.key,
    required this.diagnosticoData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instruções de Aplicação',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildAplicacaoCards(context),
      ],
    );
  }

  Widget _buildAplicacaoCards(BuildContext context) {
    final aplicacaoItems = [
      {'label': 'Dosagem', 'value': diagnosticoData['dosagem'] ?? 'N/A', 'icon': Icons.medication},
      {'label': 'Vazão Terrestre', 'value': diagnosticoData['vazaoTerrestre'] ?? 'N/A', 'icon': Icons.agriculture},
      {'label': 'Vazão Aérea', 'value': diagnosticoData['vazaoAerea'] ?? 'N/A', 'icon': Icons.flight},
      {'label': 'Intervalo de Aplicação', 'value': diagnosticoData['intervaloAplicacao'] ?? 'N/A', 'icon': Icons.schedule},
      {'label': 'Intervalo de Segurança', 'value': diagnosticoData['intervaloSeguranca'] ?? 'N/A', 'icon': Icons.shield},
    ];

    return Column(
      children: [
        ...aplicacaoItems.map((item) => _buildInfoCard(
          context,
          item['label'] as String,
          item['value'] as String,
          item['icon'] as IconData,
        )),
        if (diagnosticoData['tecnologia']?.isNotEmpty ?? false) ...[
          const SizedBox(height: 16),
          _buildTecnologiaCard(context),
        ],
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon) {
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
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
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

  Widget _buildTecnologiaCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.psychology,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Tecnologia de Aplicação',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            diagnosticoData['tecnologia'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
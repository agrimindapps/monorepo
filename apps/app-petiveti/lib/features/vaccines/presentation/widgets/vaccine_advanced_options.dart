import 'package:flutter/material.dart';

/// Widget responsible for advanced vaccine options following SRP
/// 
/// Single responsibility: Handle advanced vaccine configuration and templates
class VaccineAdvancedOptions extends StatefulWidget {
  final void Function(Map<String, dynamic>) onTemplateSelected;

  const VaccineAdvancedOptions({
    super.key,
    required this.onTemplateSelected,
  });

  @override
  State<VaccineAdvancedOptions> createState() => _VaccineAdvancedOptionsState();
}

class _VaccineAdvancedOptionsState extends State<VaccineAdvancedOptions> {
  final List<Map<String, dynamic>> _commonVaccines = [
    {'name': 'V10 (Cães)', 'interval': 365, 'series': 3},
    {'name': 'Antirrábica', 'interval': 365, 'series': 1},
    {'name': 'FeLV (Gatos)', 'interval': 365, 'series': 2},
    {'name': 'Tríplice Viral', 'interval': 365, 'series': 2},
  ];

  bool _enableCalendarSync = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAdvancedConfigSection(theme),
          const SizedBox(height: 16),
          _buildCalendarIntegrationSection(theme),
        ],
      ),
    );
  }

  Widget _buildAdvancedConfigSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações Avançadas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildVaccineTemplateSelector(theme),
            const SizedBox(height: 16),
            _buildEffectivenessTracker(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineTemplateSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Templates de Vacinas Comuns',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonVaccines.map((vaccine) {
            return ActionChip(
              label: Text(vaccine['name'] as String),
              onPressed: () => widget.onTemplateSelected(vaccine),
              avatar: const Icon(Icons.vaccines, size: 18),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline, 
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Como usar os templates',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Toque em um template para preencher automaticamente os dados básicos da vacina.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEffectivenessTracker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rastreamento de Eficácia',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.science, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Monitoramento Científico',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'O sistema acompanhará:\n• Duração da proteção\n• Reações adversas\n• Necessidade de reforços\n• Eficácia comparativa entre lotes',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.amber[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarIntegrationSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Integração com Calendário',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              title: const Text('Sincronizar com Calendário do Sistema'),
              subtitle: const Text('Adiciona eventos automaticamente'),
              value: _enableCalendarSync,
              onChanged: (value) {
                setState(() => _enableCalendarSync = value);
                _handleCalendarSync(value);
              },
              activeThumbColor: theme.colorScheme.primary,
            ),
            if (_enableCalendarSync) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sincronização ativada! Os agendamentos de vacinas serão automaticamente adicionados ao seu calendário.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleCalendarSync(bool enabled) {
    if (enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sincronização com calendário ativada'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sincronização com calendário desativada'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

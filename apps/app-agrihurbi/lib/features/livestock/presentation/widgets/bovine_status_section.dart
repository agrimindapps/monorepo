import 'package:flutter/material.dart';

import '../../../../core/widgets/design_system_components.dart';

/// Seção de status do formulário de bovino
/// 
/// Responsabilidades:
/// - Controle de ativo/inativo
/// - Informações sobre o status atual
/// - Visualização clara do estado
/// - Integração com Design System
class BovineStatusSection extends StatelessWidget {
  const BovineStatusSection({
    super.key,
    required this.isActive,
    required this.onActiveChanged,
    this.enabled = true,
    this.showDetails = true,
  });

  final bool isActive;
  final ValueChanged<bool> onActiveChanged;
  final bool enabled;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.toggle_on,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusSwitch(context),
          
          if (showDetails) ...[
            const SizedBox(height: 16),
            _buildStatusDetails(context),
            
            const SizedBox(height: 12),
            _buildStatusImpact(context),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSwitch(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          'Ativo no Rebanho',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          isActive 
              ? 'O bovino está ativo e sendo gerenciado'
              : 'O bovino está inativo no sistema',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        value: isActive,
        onChanged: enabled ? onActiveChanged : null,
        secondary: DSStatusIndicator(
          status: isActive ? 'active' : 'inactive',
          text: isActive ? 'Ativo' : 'Inativo',
          isCompact: true,
        ),
        activeColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }

  Widget _buildStatusDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline)
              .withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.pause_circle,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? 'Status Ativo' : 'Status Inativo',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          if (isActive) ..._buildActiveStatusDetails(context)
          else ..._buildInactiveStatusDetails(context),
        ],
      ),
    );
  }

  List<Widget> _buildActiveStatusDetails(BuildContext context) {
    final benefits = [
      'Incluído em relatórios e estatísticas',
      'Visível nas listagens principais',
      'Participará de cálculos de rebanho',
      'Receberá notificações e lembretes',
      'Histórico sendo registrado',
    ];

    return [
      Text(
        'Benefícios do Status Ativo:',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      ...benefits.map((benefit) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                benefit,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      )),
    ];
  }

  List<Widget> _buildInactiveStatusDetails(BuildContext context) {
    final limitations = [
      'Excluído de relatórios principais',
      'Não aparece em listagens ativas',
      'Não participa de cálculos de rebanho',
      'Não recebe notificações',
      'Histórico preservado mas não ativo',
    ];

    return [
      Text(
        'Limitações do Status Inativo:',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      ...limitations.map((limitation) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(
              Icons.remove_circle_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                limitation,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      )),
    ];
  }

  Widget _buildStatusImpact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isActive
                  ? 'Desativar irá remover o bovino dos relatórios ativos, mas preservará todos os dados históricos.'
                  : 'Ativar irá incluir o bovino em todas as funcionalidades do sistema novamente.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget compacto de status para uso em outras telas
class BovineStatusBadge extends StatelessWidget {
  const BovineStatusBadge({
    super.key,
    required this.isActive,
    this.showLabel = true,
    this.size = BovineStatusBadgeSize.normal,
  });

  final bool isActive;
  final bool showLabel;
  final BovineStatusBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final isSmall = size == BovineStatusBadgeSize.small;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: (isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        border: Border.all(
          color: (isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline)
              .withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmall ? 6 : 8,
            height: isSmall ? 6 : 8,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          if (showLabel) ...[
            SizedBox(width: isSmall ? 4 : 6),
            Text(
              isActive ? 'Ativo' : 'Inativo',
              style: (isSmall
                      ? Theme.of(context).textTheme.labelSmall
                      : Theme.of(context).textTheme.labelMedium)
                  ?.copyWith(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum BovineStatusBadgeSize { small, normal }
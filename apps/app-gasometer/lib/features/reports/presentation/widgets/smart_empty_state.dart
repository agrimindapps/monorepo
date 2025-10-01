import 'package:flutter/material.dart';

import '../../../../core/widgets/semantic_widgets.dart';
import '../../../../core/theme/design_tokens.dart';

/// Smart empty state that provides different experiences based on context
class SmartEmptyState extends StatelessWidget {

  const SmartEmptyState({
    super.key,
    required this.type,
    this.customTitle,
    this.customMessage,
    this.actions,
    this.illustration,
    this.showRefresh = false,
    this.onRefresh,
  });
  final EmptyStateType type;
  final String? customTitle;
  final String? customMessage;
  final List<ActionButton>? actions;
  final Widget? illustration;
  final bool showRefresh;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final config = _getEmptyStateConfig(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: config.iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: illustration ?? Icon(
              config.icon,
              size: 64,
              color: config.iconColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          SemanticText.heading(
            customTitle ?? config.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Message
          SemanticText(
            customMessage ?? config.message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Actions
          if (actions?.isNotEmpty == true) ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: actions!.map((action) => _buildActionButton(context, action)).toList(),
            ),
          ] else if (config.defaultActions.isNotEmpty) ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: config.defaultActions.map((action) => _buildActionButton(context, action)).toList(),
            ),
          ],
          
          // Refresh option
          if (showRefresh && onRefresh != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tentar novamente'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ActionButton action) {
    switch (action.type) {
      case ActionButtonType.primary:
        return ElevatedButton.icon(
          onPressed: action.onPressed,
          icon: action.icon != null ? Icon(action.icon, size: 18) : const SizedBox.shrink(),
          label: Text(action.label),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: action.color ?? Theme.of(context).colorScheme.primary,
          ),
        );
      case ActionButtonType.secondary:
        return OutlinedButton.icon(
          onPressed: action.onPressed,
          icon: action.icon != null ? Icon(action.icon, size: 18) : const SizedBox.shrink(),
          label: Text(action.label),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            side: BorderSide(color: action.color ?? Theme.of(context).colorScheme.outline),
            foregroundColor: action.color ?? Theme.of(context).colorScheme.onSurface,
          ),
        );
      case ActionButtonType.text:
        return TextButton.icon(
          onPressed: action.onPressed,
          icon: action.icon != null ? Icon(action.icon, size: 18) : const SizedBox.shrink(),
          label: Text(action.label),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            foregroundColor: action.color ?? Theme.of(context).colorScheme.primary,
          ),
        );
    }
  }

  EmptyStateConfig _getEmptyStateConfig(BuildContext context) {
    switch (type) {
      case EmptyStateType.noData:
        return EmptyStateConfig(
          title: 'Sem dados disponíveis',
          message: 'Não há registros para exibir estatísticas ainda. Comece adicionando alguns abastecimentos.',
          icon: Icons.data_usage_outlined,
          iconColor: Theme.of(context).colorScheme.primary,
          defaultActions: [
            ActionButton(
              label: 'Adicionar Abastecimento',
              icon: Icons.local_gas_station,
              type: ActionButtonType.primary,
              onPressed: () => _handleAction('add_fuel'),
            ),
            ActionButton(
              label: 'Ver Tutorial',
              icon: Icons.help_outline,
              type: ActionButtonType.secondary,
              onPressed: () => _handleAction('show_tutorial'),
            ),
          ],
        );
        
      case EmptyStateType.firstTime:
        return EmptyStateConfig(
          title: 'Bem-vindo ao GasOMeter!',
          message: 'Comece a monitorar seus gastos com combustível. Adicione seu primeiro abastecimento para ver as estatísticas.',
          icon: Icons.rocket_launch_outlined,
          iconColor: GasometerDesignTokens.colorAnalyticsBlue,
          defaultActions: [
            ActionButton(
              label: 'Primeiro Abastecimento',
              icon: Icons.local_gas_station,
              type: ActionButtonType.primary,
              color: GasometerDesignTokens.colorAnalyticsBlue,
              onPressed: () => _handleAction('first_fuel'),
            ),
            ActionButton(
              label: 'Como funciona?',
              icon: Icons.info_outline,
              type: ActionButtonType.text,
              onPressed: () => _handleAction('how_it_works'),
            ),
          ],
        );
        
      case EmptyStateType.noVehicle:
        return EmptyStateConfig(
          title: 'Adicione um veículo',
          message: 'Para começar a usar o GasOMeter, você precisa cadastrar pelo menos um veículo.',
          icon: Icons.directions_car_outlined,
          iconColor: GasometerDesignTokens.colorAnalyticsGreen,
          defaultActions: [
            ActionButton(
              label: 'Adicionar Veículo',
              icon: Icons.add,
              type: ActionButtonType.primary,
              color: GasometerDesignTokens.colorAnalyticsGreen,
              onPressed: () => _handleAction('add_vehicle'),
            ),
          ],
        );
        
      case EmptyStateType.loading:
        return EmptyStateConfig(
          title: 'Carregando dados...',
          message: 'Aguarde enquanto calculamos suas estatísticas.',
          icon: Icons.analytics_outlined,
          iconColor: Theme.of(context).colorScheme.primary,
          defaultActions: [],
        );
        
      case EmptyStateType.error:
        return EmptyStateConfig(
          title: 'Ops! Algo deu errado',
          message: 'Não foi possível carregar as estatísticas. Verifique sua conexão e tente novamente.',
          icon: Icons.error_outline,
          iconColor: Theme.of(context).colorScheme.error,
          defaultActions: [
            ActionButton(
              label: 'Tentar Novamente',
              icon: Icons.refresh,
              type: ActionButtonType.primary,
              onPressed: () => _handleAction('retry'),
            ),
            ActionButton(
              label: 'Reportar Problema',
              icon: Icons.bug_report_outlined,
              type: ActionButtonType.text,
              onPressed: () => _handleAction('report_bug'),
            ),
          ],
        );
        
      case EmptyStateType.offline:
        return EmptyStateConfig(
          title: 'Você está offline',
          message: 'Conecte-se à internet para sincronizar e ver as estatísticas mais recentes.',
          icon: Icons.cloud_off_outlined,
          iconColor: Colors.orange,
          defaultActions: [
            ActionButton(
              label: 'Verificar Conexão',
              icon: Icons.wifi,
              type: ActionButtonType.primary,
              color: Colors.orange,
              onPressed: () => _handleAction('check_connection'),
            ),
          ],
        );
        
      case EmptyStateType.filtered:
        return EmptyStateConfig(
          title: 'Nenhum resultado encontrado',
          message: 'Não há dados que correspondam aos filtros selecionados. Tente ajustar os critérios de busca.',
          icon: Icons.filter_list_off_outlined,
          iconColor: Theme.of(context).colorScheme.primary,
          defaultActions: [
            ActionButton(
              label: 'Limpar Filtros',
              icon: Icons.clear,
              type: ActionButtonType.primary,
              onPressed: () => _handleAction('clear_filters'),
            ),
            ActionButton(
              label: 'Ajustar Filtros',
              icon: Icons.tune,
              type: ActionButtonType.secondary,
              onPressed: () => _handleAction('adjust_filters'),
            ),
          ],
        );
    }
  }

  void _handleAction(String action) {
    // This would typically be handled by a parent widget or callback
    debugPrint('SmartEmptyState action: $action');
  }
}

/// Configuration for different empty states
class EmptyStateConfig {

  const EmptyStateConfig({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.defaultActions,
  });
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final List<ActionButton> defaultActions;
}

/// Action button configuration
class ActionButton {

  const ActionButton({
    required this.label,
    this.icon,
    required this.type,
    this.color,
    this.onPressed,
  });
  final String label;
  final IconData? icon;
  final ActionButtonType type;
  final Color? color;
  final VoidCallback? onPressed;
}

/// Types of empty states
enum EmptyStateType {
  noData,
  firstTime,
  noVehicle,
  loading,
  error,
  offline,
  filtered,
}

/// Types of action buttons
enum ActionButtonType {
  primary,
  secondary,
  text,
}

/// Contextual empty state for reports
class ReportsEmptyState extends StatelessWidget {

  const ReportsEmptyState({
    super.key,
    required this.isFirstTime,
    required this.hasVehicles,
    this.isOnline = true,
    this.hasError = false,
    this.errorMessage,
    this.onAddVehicle,
    this.onAddFuel,
    this.onRefresh,
    this.onShowTutorial,
  });
  final bool isFirstTime;
  final bool hasVehicles;
  final bool isOnline;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onAddVehicle;
  final VoidCallback? onAddFuel;
  final VoidCallback? onRefresh;
  final VoidCallback? onShowTutorial;

  @override
  Widget build(BuildContext context) {
    // Determine the most appropriate empty state
    EmptyStateType type;
    List<ActionButton> actions = [];

    if (hasError) {
      type = EmptyStateType.error;
      actions = [
        ActionButton(
          label: 'Tentar Novamente',
          icon: Icons.refresh,
          type: ActionButtonType.primary,
          onPressed: onRefresh,
        ),
      ];
    } else if (!isOnline) {
      type = EmptyStateType.offline;
      actions = [
        ActionButton(
          label: 'Verificar Conexão',
          icon: Icons.wifi,
          type: ActionButtonType.primary,
          color: Colors.orange,
          onPressed: onRefresh,
        ),
      ];
    } else if (!hasVehicles) {
      type = EmptyStateType.noVehicle;
      actions = [
        ActionButton(
          label: 'Adicionar Veículo',
          icon: Icons.add,
          type: ActionButtonType.primary,
          color: GasometerDesignTokens.colorAnalyticsGreen,
          onPressed: onAddVehicle,
        ),
      ];
    } else if (isFirstTime) {
      type = EmptyStateType.firstTime;
      actions = [
        ActionButton(
          label: 'Primeiro Abastecimento',
          icon: Icons.local_gas_station,
          type: ActionButtonType.primary,
          color: GasometerDesignTokens.colorAnalyticsBlue,
          onPressed: onAddFuel,
        ),
        ActionButton(
          label: 'Como funciona?',
          icon: Icons.info_outline,
          type: ActionButtonType.text,
          onPressed: onShowTutorial,
        ),
      ];
    } else {
      type = EmptyStateType.noData;
      actions = [
        ActionButton(
          label: 'Adicionar Abastecimento',
          icon: Icons.local_gas_station,
          type: ActionButtonType.primary,
          onPressed: onAddFuel,
        ),
        ActionButton(
          label: 'Ver Tutorial',
          icon: Icons.help_outline,
          type: ActionButtonType.secondary,
          onPressed: onShowTutorial,
        ),
      ];
    }

    return SmartEmptyState(
      type: type,
      actions: actions,
      customMessage: hasError ? errorMessage : null,
      showRefresh: hasError || !isOnline,
      onRefresh: onRefresh,
    );
  }
}
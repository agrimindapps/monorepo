import 'package:flutter/material.dart';

import '../../../../core/widgets/design_system_components.dart';

/// Widget para estados vazios das calculadoras
/// 
/// Fornece feedback visual consistente quando não há conteúdo
/// Inclui diferentes tipos de estados vazios com ações
class CalculatorEmptyStateWidget extends StatelessWidget {
  final CalculatorEmptyStateType type;
  final String? customMessage;
  final String? customSubtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const CalculatorEmptyStateWidget({
    super.key,
    required this.type,
    this.customMessage,
    this.customSubtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStateConfig(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              config.icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              customMessage ?? config.message,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              customSubtitle ?? config.subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (onAction != null || config.hasDefaultAction) ...[
              const SizedBox(height: 24),
              DSSecondaryButton(
                text: actionLabel ?? config.defaultActionLabel,
                onPressed: onAction ?? () => _handleDefaultAction(context),
                icon: config.actionIcon,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }

  _EmptyStateConfig _getStateConfig(BuildContext context) {
    switch (type) {
      case CalculatorEmptyStateType.noCalculators:
        return _EmptyStateConfig(
          icon: Icons.calculate,
          message: 'Nenhuma calculadora disponível',
          subtitle: 'As calculadoras ainda não foram carregadas\nou não há calculadoras disponíveis',
          hasDefaultAction: false,
        );
        
      case CalculatorEmptyStateType.noSearchResults:
        return _EmptyStateConfig(
          icon: Icons.search_off,
          message: 'Nenhuma calculadora encontrada',
          subtitle: 'Tente ajustar os termos de busca\nou os filtros selecionados',
          hasDefaultAction: true,
          defaultActionLabel: 'Limpar Filtros',
          actionIcon: Icons.clear_all,
        );
        
      case CalculatorEmptyStateType.noFavorites:
        return _EmptyStateConfig(
          icon: Icons.favorite_border,
          message: 'Nenhuma calculadora favorita',
          subtitle: 'Adicione calculadoras aos favoritos\ntocando no ícone de coração',
          hasDefaultAction: false,
        );
        
      case CalculatorEmptyStateType.noHistory:
        return _EmptyStateConfig(
          icon: Icons.history,
          message: 'Nenhum cálculo no histórico',
          subtitle: 'Execute cálculos para vê-los\naparecendo nesta seção',
          hasDefaultAction: false,
        );
        
      case CalculatorEmptyStateType.error:
        return _EmptyStateConfig(
          icon: Icons.error_outline,
          message: 'Erro ao carregar calculadoras',
          subtitle: 'Ocorreu um problema ao carregar as calculadoras.\nTente novamente.',
          hasDefaultAction: true,
          defaultActionLabel: 'Tentar Novamente',
          actionIcon: Icons.refresh,
        );
    }
  }

  void _handleDefaultAction(BuildContext context) {
    switch (type) {
      case CalculatorEmptyStateType.noSearchResults:
        break;
      case CalculatorEmptyStateType.error:
        break;
      default:
        break;
    }
  }
}

/// Tipos de estados vazios para calculadoras
enum CalculatorEmptyStateType {
  noCalculators,
  noSearchResults,
  noFavorites,
  noHistory,
  error,
}

/// Configuração interna para cada tipo de estado vazio
class _EmptyStateConfig {
  final IconData icon;
  final String message;
  final String subtitle;
  final bool hasDefaultAction;
  final String defaultActionLabel;
  final IconData? actionIcon;

  _EmptyStateConfig({
    required this.icon,
    required this.message,
    required this.subtitle,
    this.hasDefaultAction = false,
    this.defaultActionLabel = '',
    this.actionIcon,
  });
}
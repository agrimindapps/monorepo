import 'package:flutter/material.dart';

import '../../../../core/widgets/design_system_components.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/services/calculator_ui_service.dart';

/// Widget de card para exibir uma calculadora na lista
/// 
/// Implementa design consistente com Material Design 3
/// Inclui ação de favorito e navegação para detalhes
class CalculatorCardWidget extends StatelessWidget {
  final CalculatorEntity calculator;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool showCategory;

  const CalculatorCardWidget({
    super.key,
    required calculator,
    required isFavorite,
    required onTap,
    required onFavoriteToggle,
    showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    return DSCard(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      onTap: onTap,
      semanticLabel: 'Calculadora ${calculator.name}',
      child: Row(
        children: [
          // Ícone da categoria
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CalculatorUIService.getCategoryColor(calculator.category),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CalculatorUIService.getCategoryIcon(calculator.category),
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Informações da calculadora
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome da calculadora
                Text(
                  calculator.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Descrição
                Text(
                  calculator.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Chips de informações
                Wrap(
                  spacing: 8,
                  children: [
                    // Categoria (somente se showCategory for true)
                    if (showCategory)
                      _buildInfoChip(
                        context,
                        calculator.category.displayName,
                        CalculatorUIService.getCategoryColor(calculator.category),
                      ),
                    
                    // Status da calculadora
                    DSStatusIndicator(
                      status: CalculatorUIService.canExecuteCalculator(calculator) 
                          ? 'active' 
                          : 'inactive',
                      text: CalculatorUIService.getCalculatorStatus(calculator),
                      isCompact: true,
                    ),
                    
                    // Número de parâmetros
                    _buildInfoChip(
                      context,
                      '${calculator.parameters.length} parâmetros',
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Botão de favorito
          IconButton(
            onPressed: onFavoriteToggle,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite 
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.outline,
            ),
            tooltip: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: _getTextColorForBackground(backgroundColor),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Método removido - funcionalidade movida para CalculatorUIService

  // Método removido - funcionalidade movida para CalculatorUIService

  Color _getTextColorForBackground(Color backgroundColor) {
    // Calcula a luminância para determinar se o texto deve ser claro ou escuro
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
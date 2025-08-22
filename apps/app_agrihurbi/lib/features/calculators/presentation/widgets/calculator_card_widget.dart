import 'package:flutter/material.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/entities/calculator_category.dart';

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
    required this.calculator,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ícone da categoria
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(context, calculator.category),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(calculator.category),
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
                            _getCategoryColor(context, calculator.category),
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
        ),
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

  Color _getCategoryColor(BuildContext context, CalculatorCategory category) {
    switch (category) {
      case CalculatorCategory.irrigation:
        return const Color(0xFF2196F3); // Azul para irrigação
      case CalculatorCategory.nutrition:
        return const Color(0xFF4CAF50); // Verde para nutrição
      case CalculatorCategory.livestock:
        return const Color(0xFF795548); // Marrom para pecuária
      case CalculatorCategory.yield:
        return const Color(0xFF03A9F4); // Azul claro para rendimento
      case CalculatorCategory.machinery:
        return const Color(0xFFFF9800); // Laranja para maquinário
      case CalculatorCategory.crops:
        return const Color(0xFF9C27B0); // Roxo para culturas
      case CalculatorCategory.management:
        return const Color(0xFF607D8B); // Azul acinzentado para manejo
    }
  }

  IconData _getCategoryIcon(CalculatorCategory category) {
    switch (category) {
      case CalculatorCategory.irrigation:
        return Icons.water_drop;
      case CalculatorCategory.nutrition:
        return Icons.eco;
      case CalculatorCategory.livestock:
        return Icons.pets;
      case CalculatorCategory.yield:
        return Icons.trending_up;
      case CalculatorCategory.machinery:
        return Icons.precision_manufacturing;
      case CalculatorCategory.crops:
        return Icons.agriculture;
      case CalculatorCategory.management:
        return Icons.manage_accounts;
    }
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    // Calcula a luminância para determinar se o texto deve ser claro ou escuro
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
import 'package:flutter/material.dart';
import '../../domain/entities/calculator_category.dart';

/// Widget de filtro por categoria de calculadoras
/// 
/// Implementa chips de seleção de categoria
/// Permite filtrar calculadoras por tipo/área de aplicação
class CalculatorCategoryFilter extends StatelessWidget {
  final CalculatorCategory? selectedCategory;
  final Function(CalculatorCategory?) onCategoryChanged;
  final VoidCallback onClearFilters;

  const CalculatorCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Categorias',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (selectedCategory != null)
              TextButton(
                onPressed: onClearFilters,
                child: const Text('Limpar'),
              ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CalculatorCategory.values.map((category) {
            final isSelected = selectedCategory == category;
            
            return FilterChip(
              label: Text(category.displayName),
              selected: isSelected,
              onSelected: (selected) {
                onCategoryChanged(selected ? category : null);
              },
              avatar: Icon(
                _getCategoryIcon(category),
                size: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : _getCategoryColor(context, category),
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: _getCategoryColor(context, category),
              checkmarkColor: Theme.of(context).colorScheme.onPrimary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getCategoryColor(BuildContext context, CalculatorCategory category) {
    switch (category) {
      case CalculatorCategory.irrigation:
        return const Color(0xFF2196F3);
      case CalculatorCategory.nutrition:
        return const Color(0xFF4CAF50);
      case CalculatorCategory.livestock:
        return const Color(0xFF795548);
      case CalculatorCategory.yield:
        return const Color(0xFF03A9F4);
      case CalculatorCategory.machinery:
        return const Color(0xFFFF9800);
      case CalculatorCategory.crops:
        return const Color(0xFF9C27B0);
      case CalculatorCategory.management:
        return const Color(0xFF607D8B);
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
}
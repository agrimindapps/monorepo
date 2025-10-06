import 'package:flutter/material.dart';

import '../providers/expenses_provider.dart';
import 'expenses_constants.dart';

/// **Expense Categories Tab**
/// 
/// Grid view of expense categories with amount displays and navigation.
class ExpenseCategoriesTab extends StatelessWidget {
  final ExpensesState state;
  final void Function(String) onCategoryTap;

  const ExpenseCategoriesTab({
    super.key,
    required this.state,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ExpensesConstants.pagePadding,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ExpensesConstants.gridCrossAxisCount,
          crossAxisSpacing: ExpensesConstants.gridSpacing,
          mainAxisSpacing: ExpensesConstants.gridSpacing,
          childAspectRatio: ExpensesConstants.gridAspectRatio,
        ),
        itemCount: ExpensesConstants.expenseCategories.length,
        itemBuilder: (context, index) {
          final category = ExpensesConstants.expenseCategories[index];
          return ExpenseCategoryCard(
            categoryName: category['name'] as String,
            icon: category['icon'] as IconData,
            color: category['color'] as Color,
            amount: _getCategoryAmount(state, category['name'] as String),
            onTap: () => onCategoryTap(category['name'] as String),
          );
        },
      ),
    );
  }

  double _getCategoryAmount(ExpensesState state, String categoryName) {
    final category = ExpensesConstants.getCategoryFromName(categoryName);
    if (category == null) return 0.0;
    return state.categoryAmounts[category] ?? 0.0;
  }
}

/// **Expense Category Card**
/// 
/// Individual category card with icon, name, and amount display.
class ExpenseCategoryCard extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final Color color;
  final double amount;
  final VoidCallback onTap;

  const ExpenseCategoryCard({
    super.key,
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ExpensesConstants.iconSize,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                categoryName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'R\$${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

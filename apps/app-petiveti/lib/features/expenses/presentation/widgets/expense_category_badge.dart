import 'package:flutter/material.dart';

import '../../domain/entities/expense.dart';

/// Badge component for expense category
///
/// **SRP**: Única responsabilidade de mostrar categoria com ícone e cor
class ExpenseCategoryBadge extends StatelessWidget {
  final ExpenseCategory category;
  final double size;

  const ExpenseCategoryBadge({
    super.key,
    required this.category,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getCategoryIcon(category),
        color: _getCategoryColor(category),
        size: size * 0.5,
      ),
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    const categoryColors = {
      ExpenseCategory.consultation: Colors.blue,
      ExpenseCategory.medication: Colors.green,
      ExpenseCategory.vaccine: Colors.purple,
      ExpenseCategory.surgery: Colors.red,
      ExpenseCategory.exam: Colors.orange,
      ExpenseCategory.food: Colors.brown,
      ExpenseCategory.accessory: Colors.pink,
      ExpenseCategory.grooming: Colors.cyan,
      ExpenseCategory.insurance: Colors.indigo,
      ExpenseCategory.emergency: Colors.deepOrange,
      ExpenseCategory.other: Colors.grey,
    };
    return categoryColors[category] ?? Colors.grey;
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    const categoryIcons = {
      ExpenseCategory.consultation: Icons.medical_services,
      ExpenseCategory.medication: Icons.medication,
      ExpenseCategory.vaccine: Icons.vaccines,
      ExpenseCategory.surgery: Icons.healing,
      ExpenseCategory.exam: Icons.biotech,
      ExpenseCategory.food: Icons.pets,
      ExpenseCategory.accessory: Icons.shopping_bag,
      ExpenseCategory.grooming: Icons.content_cut,
      ExpenseCategory.insurance: Icons.shield,
      ExpenseCategory.emergency: Icons.emergency,
      ExpenseCategory.other: Icons.more_horiz,
    };
    return categoryIcons[category] ?? Icons.more_horiz;
  }
}

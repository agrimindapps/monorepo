import 'package:flutter/material.dart';
import '../providers/expenses_provider.dart';
import '../../domain/entities/expense.dart';
import 'expenses_constants.dart';

/// **Expense List Tab**
/// 
/// Reusable component for displaying expense lists in different tabs.
/// Supports both all expenses and monthly expenses views.
class ExpenseListTab extends StatelessWidget {
  final ExpensesState state;
  final List<Expense> expenses;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;

  const ExpenseListTab({
    super.key,
    required this.state,
    required this.expenses,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (expenses.isEmpty) {
      return _EmptyState(
        title: emptyTitle,
        subtitle: emptySubtitle,
        icon: emptyIcon,
      );
    }

    return ListView.builder(
      padding: ExpensesConstants.pagePadding,
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        return ExpenseListTile(expense: expenses[index]);
      },
    );
  }
}

/// **Expense List Tile**
/// 
/// Individual list item for expense display with category styling.
class ExpenseListTile extends StatelessWidget {
  final Expense expense;

  const ExpenseListTile({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final color = ExpensesConstants.getCategoryColor(expense.category);
    final icon = ExpensesConstants.getCategoryIcon(expense.category);
    final categoryName = ExpensesConstants.getCategoryName(expense.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: ExpensesConstants.avatarRadius,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          expense.description,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '$categoryName • ${_formatDate(expense.expenseDate)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          'R\${expense.amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// **Empty State Widget**
/// 
/// Displays empty state with customizable icon, title, and subtitle.
class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
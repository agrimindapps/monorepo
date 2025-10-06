import 'package:flutter/material.dart';

import '../providers/expenses_provider.dart';
import 'expenses_constants.dart';

/// **Expense Summary Tab**
/// 
/// Displays financial summaries and analytics overview.
class ExpenseSummaryTab extends StatelessWidget {
  final ExpensesState state;

  const ExpenseSummaryTab({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ExpensesConstants.pagePadding,
      child: Column(
        children: [
          SummaryCard(
            title: 'Total Geral',
            value: 'R\$${state.totalAmount.toStringAsFixed(2)}',
            icon: Icons.account_balance_wallet,
            color: Colors.blue,
          ),
          const SizedBox(height: ExpensesConstants.cardSpacing),
          SummaryCard(
            title: 'Este Mês',
            value: 'R\$${state.monthlyAmount.toStringAsFixed(2)}',
            icon: Icons.calendar_month,
            color: Colors.green,
          ),
          const SizedBox(height: ExpensesConstants.cardSpacing),
          SummaryCard(
            title: 'Este Ano',
            value: 'R\$${state.yearlyAmount.toStringAsFixed(2)}',
            icon: Icons.calendar_today,
            color: Colors.orange,
          ),
          const SizedBox(height: ExpensesConstants.cardSpacing),
          SummaryCard(
            title: 'Média Mensal',
            value: 'R\$${state.averageExpense.toStringAsFixed(2)}',
            icon: Icons.trending_up,
            color: Colors.purple,
          ),
          const SizedBox(height: ExpensesConstants.cardSpacing * 2),
          const Expanded(
            child: AnalyticsPlaceholder(),
          ),
        ],
      ),
    );
  }
}

/// **Summary Card**
/// 
/// Individual summary card with icon, title, and value display.
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: ExpensesConstants.pagePadding,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(width: ExpensesConstants.cardSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// **Analytics Placeholder**
/// 
/// Placeholder for future analytics and charts implementation.
class AnalyticsPlaceholder extends StatelessWidget {
  const AnalyticsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: ExpensesConstants.cardSpacing),
          Text(
            'Gráficos e Análises',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Gráficos detalhados serão implementados em breve.',
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

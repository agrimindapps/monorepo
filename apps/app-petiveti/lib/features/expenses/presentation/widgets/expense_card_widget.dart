import 'package:flutter/material.dart';

import '../../domain/entities/expense.dart';

/// Widget responsible for displaying individual expense card following SRP
/// 
/// Single responsibility: Display expense information in a card format
class ExpenseCardWidget extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final bool showAnimation;

  const ExpenseCardWidget({
    super.key,
    required this.expense,
    this.onTap,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 8),
              _buildDescription(theme),
              const SizedBox(height: 12),
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(),
            color: _getCategoryColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _getCategoryName(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getCategoryColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'R\$ ${expense.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: expense.amount > 200 
                    ? Colors.red[600] 
                    : theme.colorScheme.primary,
              ),
            ),
            Text(
              _formatDate(expense.expenseDate),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    if (expense.description.isEmpty) return const SizedBox.shrink();
    
    return Text(
      expense.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        _buildInfoChip(
          _getPaymentMethodName(), 
          theme.colorScheme.secondary,
          Icons.payment,
        ),
        const SizedBox(width: 8),
        if (expense.veterinaryClinic?.isNotEmpty == true)
          _buildInfoChip(
            expense.veterinaryClinic!, 
            Colors.blue,
            Icons.local_hospital,
          ),
        const Spacer(),
        if (!expense.isPaid)
          _buildInfoChip(
            'Pendente', 
            Colors.orange,
            Icons.schedule,
          ),
      ],
    );
  }

  Widget _buildInfoChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (expense.category) {
      case ExpenseCategory.consultation:
        return Colors.blue;
      case ExpenseCategory.medication:
        return Colors.green;
      case ExpenseCategory.vaccine:
        return Colors.purple;
      case ExpenseCategory.surgery:
        return Colors.red;
      case ExpenseCategory.exam:
        return Colors.orange;
      case ExpenseCategory.food:
        return Colors.brown;
      case ExpenseCategory.accessory:
        return Colors.indigo;
      case ExpenseCategory.grooming:
        return Colors.pink;
      case ExpenseCategory.insurance:
        return Colors.teal;
      case ExpenseCategory.emergency:
        return Colors.red[800]!;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (expense.category) {
      case ExpenseCategory.consultation:
        return Icons.medical_services;
      case ExpenseCategory.medication:
        return Icons.medication;
      case ExpenseCategory.vaccine:
        return Icons.vaccines;
      case ExpenseCategory.surgery:
        return Icons.healing;
      case ExpenseCategory.exam:
        return Icons.science;
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.accessory:
        return Icons.pets;
      case ExpenseCategory.grooming:
        return Icons.content_cut;
      case ExpenseCategory.insurance:
        return Icons.security;
      case ExpenseCategory.emergency:
        return Icons.emergency;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getCategoryName() {
    switch (expense.category) {
      case ExpenseCategory.consultation:
        return 'Consulta';
      case ExpenseCategory.medication:
        return 'Medicamentos';
      case ExpenseCategory.vaccine:
        return 'Vacina';
      case ExpenseCategory.surgery:
        return 'Cirurgia';
      case ExpenseCategory.exam:
        return 'Exame';
      case ExpenseCategory.food:
        return 'Alimentação';
      case ExpenseCategory.accessory:
        return 'Acessórios';
      case ExpenseCategory.grooming:
        return 'Higiene';
      case ExpenseCategory.insurance:
        return 'Seguro';
      case ExpenseCategory.emergency:
        return 'Emergência';
      case ExpenseCategory.other:
        return 'Outros';
    }
  }

  String _getPaymentMethodName() {
    switch (expense.paymentMethod) {
      case PaymentMethod.cash:
        return 'Dinheiro';
      case PaymentMethod.creditCard:
        return 'Cartão de Crédito';
      case PaymentMethod.debitCard:
        return 'Cartão de Débito';
      case PaymentMethod.pix:
        return 'PIX';
      case PaymentMethod.bankTransfer:
        return 'Transferência';
      case PaymentMethod.insurance:
        return 'Seguro';
      case PaymentMethod.other:
        return 'Outros';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
import '../../domain/entities/expense.dart';

/// Helper class for expense category utilities
///
/// **SRP**: Centraliza lógica de categoria (nomes, ícones, cores)
class ExpenseCategoryHelper {
  const ExpenseCategoryHelper._();

  static String getCategoryName(ExpenseCategory category) {
    const categoryNames = {
      ExpenseCategory.consultation: 'Consultas',
      ExpenseCategory.medication: 'Medicamentos',
      ExpenseCategory.vaccine: 'Vacinas',
      ExpenseCategory.surgery: 'Cirurgias',
      ExpenseCategory.exam: 'Exames',
      ExpenseCategory.food: 'Ração',
      ExpenseCategory.accessory: 'Acessórios',
      ExpenseCategory.grooming: 'Banho/Tosa',
      ExpenseCategory.insurance: 'Seguro',
      ExpenseCategory.emergency: 'Emergência',
      ExpenseCategory.other: 'Outros',
    };
    return categoryNames[category] ?? 'Outros';
  }

  static String getPaymentMethodName(PaymentMethod method) {
    const methodNames = {
      PaymentMethod.cash: 'Dinheiro',
      PaymentMethod.creditCard: 'Cartão de Crédito',
      PaymentMethod.debitCard: 'Cartão de Débito',
      PaymentMethod.pix: 'PIX',
      PaymentMethod.bankTransfer: 'Transferência Bancária',
      PaymentMethod.insurance: 'Plano de Saúde',
      PaymentMethod.other: 'Outros',
    };
    return methodNames[method] ?? 'Outros';
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatDateRange(DateTime start, DateTime end) {
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  static String formatCurrency(double amount) {
    return 'R\$ ${amount.toStringAsFixed(2)}';
  }
}

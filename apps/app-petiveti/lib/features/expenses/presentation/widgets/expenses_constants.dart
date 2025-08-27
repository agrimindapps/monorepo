import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';

/// **Expenses Constants**
/// 
/// Centralized constants for expense categories, colors, and configurations.
abstract final class ExpensesConstants {
  // Category configurations
  static const List<Map<String, dynamic>> expenseCategories = [
    {'name': 'Consultas', 'icon': Icons.medical_services, 'color': Colors.blue, 'category': ExpenseCategory.consultation},
    {'name': 'Medicamentos', 'icon': Icons.medication, 'color': Colors.green, 'category': ExpenseCategory.medication},
    {'name': 'Vacinas', 'icon': Icons.vaccines, 'color': Colors.purple, 'category': ExpenseCategory.vaccine},
    {'name': 'Cirurgias', 'icon': Icons.healing, 'color': Colors.red, 'category': ExpenseCategory.surgery},
    {'name': 'Exames', 'icon': Icons.biotech, 'color': Colors.orange, 'category': ExpenseCategory.exam},
    {'name': 'Ração', 'icon': Icons.pets, 'color': Colors.brown, 'category': ExpenseCategory.food},
    {'name': 'Acessórios', 'icon': Icons.shopping_bag, 'color': Colors.pink, 'category': ExpenseCategory.accessory},
    {'name': 'Banho/Tosa', 'icon': Icons.content_cut, 'color': Colors.cyan, 'category': ExpenseCategory.grooming},
    {'name': 'Seguro', 'icon': Icons.shield, 'color': Colors.indigo, 'category': ExpenseCategory.insurance},
    {'name': 'Emergência', 'icon': Icons.emergency, 'color': Colors.deepOrange, 'category': ExpenseCategory.emergency},
    {'name': 'Outros', 'icon': Icons.more_horiz, 'color': Colors.grey, 'category': ExpenseCategory.other},
  ];

  // Category mappings for easy lookup
  static const Map<ExpenseCategory, Color> categoryColors = {
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

  static const Map<ExpenseCategory, IconData> categoryIcons = {
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

  static const Map<ExpenseCategory, String> categoryNames = {
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

  static const Map<String, ExpenseCategory> nameToCategory = {
    'Consultas': ExpenseCategory.consultation,
    'Medicamentos': ExpenseCategory.medication,
    'Vacinas': ExpenseCategory.vaccine,
    'Cirurgias': ExpenseCategory.surgery,
    'Exames': ExpenseCategory.exam,
    'Ração': ExpenseCategory.food,
    'Acessórios': ExpenseCategory.accessory,
    'Banho/Tosa': ExpenseCategory.grooming,
    'Seguro': ExpenseCategory.insurance,
    'Emergência': ExpenseCategory.emergency,
    'Outros': ExpenseCategory.other,
  };

  // Helper methods
  static Color getCategoryColor(ExpenseCategory category) {
    return categoryColors[category] ?? Colors.grey;
  }

  static IconData getCategoryIcon(ExpenseCategory category) {
    return categoryIcons[category] ?? Icons.more_horiz;
  }

  static String getCategoryName(ExpenseCategory category) {
    return categoryNames[category] ?? 'Outros';
  }

  static ExpenseCategory? getCategoryFromName(String name) {
    return nameToCategory[name];
  }

  // UI Constants
  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const double cardSpacing = 16.0;
  static const double iconSize = 32.0;
  static const double avatarRadius = 20.0;
  
  // Grid layout
  static const int gridCrossAxisCount = 2;
  static const double gridSpacing = 16.0;
  static const double gridAspectRatio = 1.2;
}
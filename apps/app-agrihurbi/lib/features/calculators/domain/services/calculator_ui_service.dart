import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../entities/calculation_history.dart';
import '../entities/calculator_category.dart';
import '../entities/calculator_entity.dart';

/// Serviço para helpers de UI das calculadoras
///
/// Centraliza lógica comum de formatação, navegação e utilitários
/// Reduz duplicação de código entre as páginas
class CalculatorUIService {
  CalculatorUIService._();

  // =====================================================================
  // NAVIGATION HELPERS
  // =====================================================================
  
  /// Navega para página de detalhes da calculadora
  static void navigateToCalculator(BuildContext context, String calculatorId) {
    context.push('/home/calculators/detail/$calculatorId');
  }
  
  /// Navega para calculadora aplicando dados do histórico
  static void navigateToCalculatorWithHistory(
    BuildContext context,
    CalculationHistory historyItem,
  ) {
    // Implementar aplicação dos dados do histórico via provider
    context.push('/home/calculators/detail/${historyItem.calculatorId}');
  }
  
  /// Navega para página de busca
  static void navigateToSearch(BuildContext context) {
    context.push('/home/calculators/search');
  }
  
  /// Navega para categoria específica
  static void navigateToCategory(BuildContext context, String category) {
    context.push('/home/calculators/category/$category');
  }

  // =====================================================================
  // FORMATTING HELPERS
  // =====================================================================
  
  /// Formata data relativa para exibição no histórico
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min atrás';
      } else {
        return '${difference.inHours}h atrás';
      }
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
  
  /// Formata resultado de cálculo para exibição resumida
  static String formatCalculationSummary(CalculationHistory historyItem) {
    final result = historyItem.result;
    if (result.values.isEmpty) return 'Resultado calculado';
    
    // Buscar valor primário ou usar o primeiro
    final primaryValue = result.values.firstWhere(
      (v) => v.isPrimary,
      orElse: () => result.values.first,
    );
    
    return '${primaryValue.label}: ${_formatNumber(primaryValue.value)} ${primaryValue.unit}';
  }
  
  /// Formata números para exibição
  static String _formatNumber(dynamic value) {
    if (value is double) {
      // Remove casas decimais desnecessárias
      if (value == value.roundToDouble()) {
        return value.round().toString();
      } else {
        return value.toStringAsFixed(2);
      }
    }
    return value.toString();
  }
  
  /// Gera título da página baseado na categoria
  static String getPageTitle(String? category) {
    if (category == null) {
      return 'Calculadoras Agrícolas';
    }

    switch (category.toLowerCase()) {
      case 'nutrition':
        return 'Calculadoras de Nutrição';
      case 'livestock':
        return 'Calculadoras de Pecuária';
      case 'crops':
        return 'Calculadoras de Cultivos';
      case 'soil':
        return 'Calculadoras de Solo';
      case 'irrigation':
        return 'Calculadoras de Irrigação';
      case 'machinery':
        return 'Calculadoras de Maquinário';
      case 'management':
        return 'Calculadoras de Manejo';
      default:
        return 'Calculadoras Agrícolas';
    }
  }
  
  // =====================================================================
  // CATEGORY HELPERS
  // =====================================================================
  
  /// Mapeia string para enum de categoria
  static CalculatorCategory? mapStringToCategory(String categoryString) {
    switch (categoryString.toLowerCase()) {
      case 'nutrition':
        return CalculatorCategory.nutrition;
      case 'livestock':
        return CalculatorCategory.livestock;
      case 'crops':
        return CalculatorCategory.crops;
      case 'irrigation':
        return CalculatorCategory.irrigation;
      case 'machinery':
        return CalculatorCategory.machinery;
      case 'management':
        return CalculatorCategory.management;
      case 'yield':
        return CalculatorCategory.yield;
      default:
        return null;
    }
  }
  
  /// Obtém cor da categoria
  static Color getCategoryColor(CalculatorCategory category) {
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
  
  /// Obtém ícone da categoria
  static IconData getCategoryIcon(CalculatorCategory category) {
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

  // =====================================================================
  // VALIDATION HELPERS
  // =====================================================================
  
  /// Valida se calculadora pode ser executada
  static bool canExecuteCalculator(CalculatorEntity calculator) {
    return calculator.isActive && calculator.parameters.isNotEmpty;
  }
  
  /// Obtém mensagem de status da calculadora
  static String getCalculatorStatus(CalculatorEntity calculator) {
    if (!calculator.isActive) {
      return 'Indisponível';
    }
    if (calculator.parameters.isEmpty) {
      return 'Em desenvolvimento';
    }
    return 'Disponível';
  }
  
  // =====================================================================
  // SEARCH HELPERS
  // =====================================================================
  
  /// Extrai tags únicas de uma lista de calculadoras
  static List<String> extractAvailableTags(List<CalculatorEntity> calculators) {
    final allTags = <String>{};
    for (final calculator in calculators) {
      allTags.addAll(calculator.tags);
    }
    return allTags.toList()..sort();
  }
  
  /// Verifica se calculadora corresponde ao filtro de busca
  static bool matchesSearchQuery(CalculatorEntity calculator, String query) {
    if (query.isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    return calculator.name.toLowerCase().contains(lowerQuery) ||
           calculator.description.toLowerCase().contains(lowerQuery) ||
           calculator.category.displayName.toLowerCase().contains(lowerQuery) ||
           calculator.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }
  
  // =====================================================================
  // FEEDBACK HELPERS
  // =====================================================================
  
  /// Mostra snackbar de sucesso
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Mostra snackbar de erro
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Mostra dialog de confirmação
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                  )
                : null,
            child: Text(
              confirmText,
              style: isDestructive 
                  ? const TextStyle(color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/calculator_registry.dart';

part 'category_providers.g.dart';

/// Category data for UI display (used by CategoryMenu and filters)
class CategoryData {
  final String label;
  final String routeParam;
  final int count;
  final CalculatorCategoryType? type;
  final IconData icon;
  final Color? color;

  const CategoryData({
    required this.label,
    required this.routeParam,
    required this.count,
    required this.icon,
    this.type,
    this.color,
  });

  /// Special "All" category
  static CategoryData all(int totalCount) => CategoryData(
        label: 'Todos',
        routeParam: 'todos',
        count: totalCount,
        icon: Icons.apps,
        type: null,
        color: null,
      );

  /// Create from category type
  factory CategoryData.fromType(CalculatorCategoryType type, int count) {
    return CategoryData(
      label: type.label,
      routeParam: type.routeParam,
      count: count,
      icon: type.icon,
      color: type.color,
      type: type,
    );
  }
}

/// Provider for category counts (automatically calculated from registry)
@riverpod
Map<CalculatorCategoryType, int> categoryCounts(Ref ref) {
  return CalculatorRegistry.getAllCounts();
}

/// Provider for total calculator count
@riverpod
int totalCalculatorCount(Ref ref) {
  return CalculatorRegistry.totalCount;
}

/// Provider for all category data (for UI display)
@riverpod
List<CategoryData> allCategories(Ref ref) {
  final counts = ref.watch(categoryCountsProvider);
  final total = ref.watch(totalCalculatorCountProvider);

  return [
    CategoryData.all(total),
    ...CalculatorCategoryType.values.map(
      (type) => CategoryData.fromType(type, counts[type] ?? 0),
    ),
  ];
}

/// Provider for calculators filtered by category
@riverpod
List<CalculatorItem> calculatorsByCategory(
  Ref ref,
  CalculatorCategoryType? category,
) {
  if (category == null) {
    return CalculatorRegistry.all;
  }
  return CalculatorRegistry.byCategory(category);
}

/// Provider for calculators filtered by route param (string)
@riverpod
List<CalculatorItem> calculatorsByRouteParam(
  Ref ref,
  String? routeParam,
) {
  if (routeParam == null || routeParam == 'todos') {
    return CalculatorRegistry.all;
  }

  // Find matching category type
  final categoryType = CalculatorCategoryType.values.cast<CalculatorCategoryType?>().firstWhere(
        (type) => type?.routeParam == routeParam,
        orElse: () => null,
      );

  if (categoryType == null) {
    return CalculatorRegistry.all;
  }

  return CalculatorRegistry.byCategory(categoryType);
}

/// Provider for popular calculators
@riverpod
List<CalculatorItem> popularCalculators(Ref ref) {
  return CalculatorRegistry.popular;
}

/// Provider for searching calculators
@riverpod
List<CalculatorItem> searchCalculators(Ref ref, String query) {
  return CalculatorRegistry.search(query);
}

/// Provider for financial calculators
@riverpod
List<CalculatorItem> financialCalculators(Ref ref) {
  return CalculatorRegistry.financial;
}

/// Provider for construction calculators
@riverpod
List<CalculatorItem> constructionCalculators(Ref ref) {
  return CalculatorRegistry.construction;
}

/// Provider for health calculators
@riverpod
List<CalculatorItem> healthCalculators(Ref ref) {
  return CalculatorRegistry.health;
}

/// Provider for pet calculators
@riverpod
List<CalculatorItem> petCalculators(Ref ref) {
  return CalculatorRegistry.pet;
}

/// Provider for agriculture calculators
@riverpod
List<CalculatorItem> agricultureCalculators(Ref ref) {
  return CalculatorRegistry.agriculture;
}

/// Provider for livestock calculators
@riverpod
List<CalculatorItem> livestockCalculators(Ref ref) {
  return CalculatorRegistry.livestock;
}

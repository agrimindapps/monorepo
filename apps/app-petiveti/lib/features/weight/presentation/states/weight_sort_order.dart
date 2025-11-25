import 'package:flutter/material.dart';

/// **OCP Pattern**: Segregated sort enum
/// Open for extension: features can extend with additional sort criteria
/// Closed for modification: base design remains stable
enum WeightSortOrder { dateAsc, dateDesc, weightAsc, weightDesc }

extension WeightSortOrderExtension on WeightSortOrder {
  String get displayName {
    switch (this) {
      case WeightSortOrder.dateAsc:
        return 'Data (Antiga → Recente)';
      case WeightSortOrder.dateDesc:
        return 'Data (Recente → Antiga)';
      case WeightSortOrder.weightAsc:
        return 'Peso (Menor → Maior)';
      case WeightSortOrder.weightDesc:
        return 'Peso (Maior → Menor)';
    }
  }

  IconData get icon {
    switch (this) {
      case WeightSortOrder.dateAsc:
        return Icons.arrow_upward;
      case WeightSortOrder.dateDesc:
        return Icons.arrow_downward;
      case WeightSortOrder.weightAsc:
        return Icons.arrow_upward;
      case WeightSortOrder.weightDesc:
        return Icons.arrow_downward;
    }
  }
}

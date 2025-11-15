import '../entities/weight.dart';

/// Service specialized in weight calculation operations
/// Handles all weight-related calculations and analysis
/// Single Responsibility: Weight calculations and computations
class WeightCalculationService {
  /// Calculates average weight from a list of weights
  double calculateAverageWeight(List<Weight> weights) {
    if (weights.isEmpty) return 0.0;

    final total = weights.fold<double>(
      0,
      (sum, weight) => sum + weight.weight,
    );
    return total / weights.length;
  }

  /// Calculates weight progress between two measurements
  WeightDifference? calculateWeightProgress(
    Weight currentWeight,
    Weight previousWeight,
  ) {
    return currentWeight.calculateDifference(previousWeight);
  }

  /// Determines the overall weight trend from a list of weights
  WeightTrend? calculateOverallTrend(List<Weight> weights) {
    if (weights.length < 2) return null;

    final sortedByDate = List<Weight>.from(weights)
      ..sort((a, b) => a.date.compareTo(b.date));

    final first = sortedByDate.first;
    final last = sortedByDate.last;

    return last.calculateDifference(first)?.trend;
  }

  /// Gets the latest weight from a list
  Weight? getLatestWeight(List<Weight> weights) {
    if (weights.isEmpty) return null;

    return weights.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  /// Gets recent weights within a specified number of days
  List<Weight> getRecentWeights(List<Weight> weights, {int days = 30}) {
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: days));
    return weights.where((w) => w.date.isAfter(thirtyDaysAgo)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Checks if weight change is significant above a threshold
  bool hasSignificantChange(
    Weight currentWeight,
    Weight previousWeight, {
    double threshold = 0.1,
  }) {
    final diff = currentWeight.calculateDifference(previousWeight);
    if (diff == null) return false;
    return (diff.percentageChange.abs() / 100) > threshold;
  }
}

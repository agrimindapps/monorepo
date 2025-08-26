/// Represents statistical data for report display widgets
/// 
/// This class contains data for showing statistical information
/// with comparison values and trend indicators
class StatData {
  /// The label/title of the statistic
  final String label;
  
  /// The main value to display
  final String value;
  
  /// The comparison label (e.g., "vs mês anterior")
  final String comparison;
  
  /// The comparison value
  final String comparisonValue;
  
  /// The percentage change (optional, e.g., "+10%", "-5%")
  final String? percentage;
  
  /// Whether the percentage change is positive (true) or negative (false)
  final bool? isPositive;

  const StatData({
    required this.label,
    required this.value,
    required this.comparison,
    required this.comparisonValue,
    this.percentage,
    this.isPositive,
  });
}
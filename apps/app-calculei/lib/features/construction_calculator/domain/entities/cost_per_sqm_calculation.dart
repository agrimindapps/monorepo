import 'package:equatable/equatable.dart';

/// Cost per square meter calculation result
///
/// Follows Clean Architecture principles:
/// - Pure data entity
/// - Immutable
/// - Independent of frameworks
class CostPerSquareMeterCalculation extends Equatable {
  final double area; // m²
  final double costPerSquareMeter; // R$/m²
  final double totalCost; // R$
  final DateTime createdAt;

  const CostPerSquareMeterCalculation({
    required this.area,
    required this.costPerSquareMeter,
    required this.totalCost,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        area,
        costPerSquareMeter,
        totalCost,
        createdAt,
      ];
}

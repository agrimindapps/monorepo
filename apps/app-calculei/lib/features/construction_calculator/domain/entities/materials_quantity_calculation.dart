import 'package:equatable/equatable.dart';

/// Material quantity calculation result
///
/// Follows Clean Architecture principles:
/// - Pure data entity
/// - Immutable
/// - Independent of frameworks
class MaterialsQuantityCalculation extends Equatable {
  final double area; // m²
  final double? sandQuantity; // m³
  final double? cementQuantity; // sacos
  final double? brickQuantity; // unidades
  final double? mortarQuantity; // m³
  final DateTime createdAt;

  const MaterialsQuantityCalculation({
    required this.area,
    this.sandQuantity,
    this.cementQuantity,
    this.brickQuantity,
    this.mortarQuantity,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        area,
        sandQuantity,
        cementQuantity,
        brickQuantity,
        mortarQuantity,
        createdAt,
      ];
}

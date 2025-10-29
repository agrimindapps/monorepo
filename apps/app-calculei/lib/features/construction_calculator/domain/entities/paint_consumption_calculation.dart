import 'package:equatable/equatable.dart';

/// Paint consumption calculation result
///
/// Follows Clean Architecture principles:
/// - Pure data entity
/// - Immutable
/// - Independent of frameworks
class PaintConsumptionCalculation extends Equatable {
  final double area; // m²
  final double surfacePreparation; // 0-3 (roughness factor)
  final double coats; // número de demãos
  final double paintQuantity; // litros
  final double buckets; // quantidade de baldes (18L)
  final DateTime createdAt;

  const PaintConsumptionCalculation({
    required this.area,
    required this.surfacePreparation,
    required this.coats,
    required this.paintQuantity,
    required this.buckets,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        area,
        surfacePreparation,
        coats,
        paintQuantity,
        buckets,
        createdAt,
      ];
}

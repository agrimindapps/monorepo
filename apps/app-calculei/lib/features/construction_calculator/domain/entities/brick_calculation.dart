import 'package:equatable/equatable.dart';

/// Pure domain entity - Brick/block calculation result
///
/// Represents the calculation of bricks or blocks needed for wall construction
class BrickCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Wall length in meters
  final double wallLength;

  /// Wall height in meters
  final double wallHeight;

  /// Total wall area in square meters
  final double wallArea;

  /// Door/window openings area in square meters
  final double openingsArea;

  /// Net area to build in square meters
  final double netArea;

  /// Brick/block type
  final BrickType brickType;

  /// Number of bricks/blocks needed (without waste)
  final int bricksNeeded;

  /// Waste percentage (default 5%)
  final double wastePercentage;

  /// Number of bricks/blocks needed (with waste)
  final int bricksWithWaste;

  /// Mortar/grout bags needed (50kg bags)
  final int mortarBags;

  /// Sand in cubic meters for mortar
  final double sandCubicMeters;

  /// Cement bags (50kg) for mortar
  final int cementBags;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const BrickCalculation({
    required this.id,
    required this.wallLength,
    required this.wallHeight,
    required this.wallArea,
    required this.openingsArea,
    required this.netArea,
    required this.brickType,
    required this.bricksNeeded,
    required this.wastePercentage,
    required this.bricksWithWaste,
    required this.mortarBags,
    required this.sandCubicMeters,
    required this.cementBags,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory BrickCalculation.empty() {
    return BrickCalculation(
      id: '',
      wallLength: 0,
      wallHeight: 0,
      wallArea: 0,
      openingsArea: 0,
      netArea: 0,
      brickType: BrickType.ceramic6Holes,
      bricksNeeded: 0,
      wastePercentage: 5,
      bricksWithWaste: 0,
      mortarBags: 0,
      sandCubicMeters: 0,
      cementBags: 0,
      calculatedAt: DateTime.now(),
    );
  }

  BrickCalculation copyWith({
    String? id,
    double? wallLength,
    double? wallHeight,
    double? wallArea,
    double? openingsArea,
    double? netArea,
    BrickType? brickType,
    int? bricksNeeded,
    double? wastePercentage,
    int? bricksWithWaste,
    int? mortarBags,
    double? sandCubicMeters,
    int? cementBags,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return BrickCalculation(
      id: id ?? this.id,
      wallLength: wallLength ?? this.wallLength,
      wallHeight: wallHeight ?? this.wallHeight,
      wallArea: wallArea ?? this.wallArea,
      openingsArea: openingsArea ?? this.openingsArea,
      netArea: netArea ?? this.netArea,
      brickType: brickType ?? this.brickType,
      bricksNeeded: bricksNeeded ?? this.bricksNeeded,
      wastePercentage: wastePercentage ?? this.wastePercentage,
      bricksWithWaste: bricksWithWaste ?? this.bricksWithWaste,
      mortarBags: mortarBags ?? this.mortarBags,
      sandCubicMeters: sandCubicMeters ?? this.sandCubicMeters,
      cementBags: cementBags ?? this.cementBags,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        wallLength,
        wallHeight,
        wallArea,
        openingsArea,
        netArea,
        brickType,
        bricksNeeded,
        wastePercentage,
        bricksWithWaste,
        mortarBags,
        sandCubicMeters,
        cementBags,
        estimatedCost,
        calculatedAt,
      ];
}

/// Brick/block types with their specifications
enum BrickType {
  /// Tijolo cerâmico 6 furos (9x14x19 cm) - ~22 un/m²
  ceramic6Holes,

  /// Tijolo cerâmico 8 furos (9x19x19 cm) - ~20 un/m²
  ceramic8Holes,

  /// Bloco de concreto 14x19x39 cm - ~13 un/m²
  concreteBlock14,

  /// Bloco de concreto 19x19x39 cm - ~13 un/m²
  concreteBlock19,

  /// Tijolo maciço (5x10x20 cm) - ~72 un/m²
  solidBrick,

  /// Bloco cerâmico estrutural (14x19x29 cm) - ~17 un/m²
  structuralCeramic,
}

/// Extension to get brick type display name and specs
extension BrickTypeExtension on BrickType {
  String get displayName {
    switch (this) {
      case BrickType.ceramic6Holes:
        return 'Tijolo Cerâmico 6 Furos';
      case BrickType.ceramic8Holes:
        return 'Tijolo Cerâmico 8 Furos';
      case BrickType.concreteBlock14:
        return 'Bloco de Concreto 14cm';
      case BrickType.concreteBlock19:
        return 'Bloco de Concreto 19cm';
      case BrickType.solidBrick:
        return 'Tijolo Maciço';
      case BrickType.structuralCeramic:
        return 'Bloco Cerâmico Estrutural';
    }
  }

  String get dimensions {
    switch (this) {
      case BrickType.ceramic6Holes:
        return '9x14x19 cm';
      case BrickType.ceramic8Holes:
        return '9x19x19 cm';
      case BrickType.concreteBlock14:
        return '14x19x39 cm';
      case BrickType.concreteBlock19:
        return '19x19x39 cm';
      case BrickType.solidBrick:
        return '5x10x20 cm';
      case BrickType.structuralCeramic:
        return '14x19x29 cm';
    }
  }

  /// Units per square meter
  int get unitsPerSquareMeter {
    switch (this) {
      case BrickType.ceramic6Holes:
        return 22;
      case BrickType.ceramic8Holes:
        return 20;
      case BrickType.concreteBlock14:
        return 13;
      case BrickType.concreteBlock19:
        return 13;
      case BrickType.solidBrick:
        return 72;
      case BrickType.structuralCeramic:
        return 17;
    }
  }
}

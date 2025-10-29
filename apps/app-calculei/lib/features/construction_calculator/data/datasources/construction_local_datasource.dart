import '../../domain/entities/index.dart';

/// Abstract datasource for construction calculations
abstract class ConstructionLocalDataSource {
  /// Calculate material quantities
  Future<MaterialsQuantityCalculation> calculateMaterialsQuantity({
    required double area,
    required String buildingType,
  });

  /// Calculate cost per square meter
  Future<CostPerSquareMeterCalculation> calculateCostPerSqm({
    required double area,
    required double costPerSquareMeter,
  });

  /// Calculate paint consumption
  Future<PaintConsumptionCalculation> calculatePaintConsumption({
    required double area,
    required double surfacePreparation,
    required double coats,
  });

  /// Calculate flooring materials
  Future<FlooringCalculation> calculateFlooring({
    required double area,
    required double tileWidth,
    required double tileLength,
    double? pricePerTile,
    double wastePercentage = 10.0,
  });

  /// Calculate concrete materials
  Future<ConcreteCalculation> calculateConcrete({
    required double length,
    required double width,
    required double height,
    required String concreteType,
    double? cementPricePerBag,
    double? sandPricePerCubicMeter,
    double? gravelPricePerCubicMeter,
  });
}

/// Implementation of ConstructionLocalDataSource
///
/// Follows Dependency Inversion Principle (DIP):
/// - Uses local calculations (no external dependencies)
/// - Can be easily replaced with network-based implementation
class ConstructionLocalDataSourceImpl implements ConstructionLocalDataSource {
  @override
  Future<MaterialsQuantityCalculation> calculateMaterialsQuantity({
    required double area,
    required String buildingType,
  }) async {
    // Standard consumption rates for construction materials
    // Based on Brazilian construction standards (NBR)

    double sandQuantity = 0;
    double cementQuantity = 0;
    double brickQuantity = 0;
    double mortarQuantity = 0;

    if (buildingType == 'alvenaria') {
      // Alvenaria (brick masonry) with 14cm blocks
      brickQuantity = area * 80; // 80 bricks per m²
      sandQuantity = area * 0.04; // 0.04 m³ per m²
      cementQuantity = (sandQuantity * 1.4) / 50; // sacos de 50kg
      mortarQuantity = sandQuantity;
    } else if (buildingType == 'concreto') {
      // Concrete foundation/structure
      sandQuantity = area * 0.03;
      cementQuantity = (sandQuantity * 2) / 50; // sacos de 50kg
    }

    return MaterialsQuantityCalculation(
      area: area,
      sandQuantity: sandQuantity,
      cementQuantity: cementQuantity,
      brickQuantity: brickQuantity,
      mortarQuantity: mortarQuantity,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<CostPerSquareMeterCalculation> calculateCostPerSqm({
    required double area,
    required double costPerSquareMeter,
  }) async {
    final totalCost = area * costPerSquareMeter;

    return CostPerSquareMeterCalculation(
      area: area,
      costPerSquareMeter: costPerSquareMeter,
      totalCost: totalCost,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PaintConsumptionCalculation> calculatePaintConsumption({
    required double area,
    required double surfacePreparation,
    required double coats,
  }) async {
    // Standard paint consumption
    // Base: 1 liter per ~10-12 m² (depending on surface)
    // Roughness factor: 0 (smooth) to 3 (very rough)

    const double baseConsumption = 0.1; // 1L per 10m²
    final double adjustedConsumption =
        baseConsumption + (surfacePreparation * 0.02);
    final double paintQuantity = area * adjustedConsumption * coats;
    final double buckets = (paintQuantity / 18).ceilToDouble(); // 18L buckets

    return PaintConsumptionCalculation(
      area: area,
      surfacePreparation: surfacePreparation,
      coats: coats,
      paintQuantity: paintQuantity,
      buckets: buckets,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<FlooringCalculation> calculateFlooring({
    required double area,
    required double tileWidth,
    required double tileLength,
    double? pricePerTile,
    double wastePercentage = 10.0,
  }) async {
    // Calculate area per tile in square meters
    final double areaPerTile = (tileWidth * tileLength) / 10000;

    // Calculate tiles needed without waste
    final int tilesNeeded = (area / areaPerTile).ceil();

    // Add waste percentage
    final int tilesWithWaste =
        (tilesNeeded * (1 + wastePercentage / 100)).ceil();

    // Calculate total cost if price is provided
    final double? totalCost =
        pricePerTile != null ? tilesWithWaste * pricePerTile : null;

    return FlooringCalculation(
      area: area,
      tileWidth: tileWidth,
      tileLength: tileLength,
      tilesNeeded: tilesNeeded,
      totalCost: totalCost,
      wastePercentage: wastePercentage,
      tilesWithWaste: tilesWithWaste,
    );
  }

  @override
  Future<ConcreteCalculation> calculateConcrete({
    required double length,
    required double width,
    required double height,
    required String concreteType,
    double? cementPricePerBag,
    double? sandPricePerCubicMeter,
    double? gravelPricePerCubicMeter,
  }) async {
    // Calculate volume
    final double volume = length * width * height;

    // Concrete mix ratios based on concrete type (Brazilian standards)
    // These are typical ratios for different concrete strengths
    final Map<String, Map<String, double>> concreteRatios = {
      'fck 10': {'cement': 6.0, 'sand': 0.54, 'gravel': 0.82, 'water': 180.0},
      'fck 15': {'cement': 7.0, 'sand': 0.50, 'gravel': 0.75, 'water': 190.0},
      'fck 20': {'cement': 8.0, 'sand': 0.48, 'gravel': 0.72, 'water': 200.0},
      'fck 25': {'cement': 9.0, 'sand': 0.45, 'gravel': 0.68, 'water': 210.0},
      'fck 30': {'cement': 10.0, 'sand': 0.42, 'gravel': 0.63, 'water': 220.0},
    };

    final ratios = concreteRatios[concreteType] ??
        concreteRatios['fck 20']!; // Default to fck 20

    // Calculate materials per cubic meter
    final double cementBags = volume * ratios['cement']!; // 50kg bags
    final double sandVolume = volume * ratios['sand']!;
    final double gravelVolume = volume * ratios['gravel']!;
    final double waterVolume = volume * ratios['water']!; // liters

    // Calculate total cost if prices are provided
    double? totalCost;
    if (cementPricePerBag != null &&
        sandPricePerCubicMeter != null &&
        gravelPricePerCubicMeter != null) {
      final cementCost = cementBags * cementPricePerBag;
      final sandCost = sandVolume * sandPricePerCubicMeter;
      final gravelCost = gravelVolume * gravelPricePerCubicMeter;
      totalCost = cementCost + sandCost + gravelCost;
    }

    return ConcreteCalculation(
      length: length,
      width: width,
      height: height,
      volume: volume,
      cementBags: cementBags,
      sandVolume: sandVolume,
      gravelVolume: gravelVolume,
      waterVolume: waterVolume,
      totalCost: totalCost,
      concreteType: concreteType,
    );
  }
}

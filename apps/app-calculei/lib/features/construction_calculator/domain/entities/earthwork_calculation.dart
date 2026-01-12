import 'package:equatable/equatable.dart';

/// Pure domain entity - Earthwork calculation result
///
/// Represents the complete calculation of earthwork volume and logistics
/// needed for excavation, fill, or cut-and-fill operations
class EarthworkCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Length in meters
  final double length;

  /// Width in meters
  final double width;

  /// Depth in meters
  final double depth;

  /// Operation type (Escavação/Aterro/Corte e Aterro)
  final String operationType;

  /// Soil type (Areia/Argila/Saibro/Pedregoso)
  final String soilType;

  /// Total volume in cubic meters (m³) - raw volume
  final double totalVolume;

  /// Compacted volume in cubic meters (m³) - after compaction factor
  final double compactedVolume;

  /// Number of truck loads needed (8m³ per truck)
  final int truckLoads;

  /// Estimated hours for the operation
  final double estimatedHours;

  /// Expansion factor applied (for excavation)
  final double expansionFactor;

  /// Compaction factor applied (for fill)
  final double compactionFactor;

  /// Estimated cost (optional)
  final double? estimatedCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const EarthworkCalculation({
    required this.id,
    required this.length,
    required this.width,
    required this.depth,
    required this.operationType,
    required this.soilType,
    required this.totalVolume,
    required this.compactedVolume,
    required this.truckLoads,
    required this.estimatedHours,
    required this.expansionFactor,
    required this.compactionFactor,
    this.estimatedCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory EarthworkCalculation.empty() {
    return EarthworkCalculation(
      id: '',
      length: 0,
      width: 0,
      depth: 0,
      operationType: 'Escavação',
      soilType: 'Areia',
      totalVolume: 0,
      compactedVolume: 0,
      truckLoads: 0,
      estimatedHours: 0,
      expansionFactor: 1.0,
      compactionFactor: 1.0,
      calculatedAt: DateTime.now(),
    );
  }

  EarthworkCalculation copyWith({
    String? id,
    double? length,
    double? width,
    double? depth,
    String? operationType,
    String? soilType,
    double? totalVolume,
    double? compactedVolume,
    int? truckLoads,
    double? estimatedHours,
    double? expansionFactor,
    double? compactionFactor,
    double? estimatedCost,
    DateTime? calculatedAt,
  }) {
    return EarthworkCalculation(
      id: id ?? this.id,
      length: length ?? this.length,
      width: width ?? this.width,
      depth: depth ?? this.depth,
      operationType: operationType ?? this.operationType,
      soilType: soilType ?? this.soilType,
      totalVolume: totalVolume ?? this.totalVolume,
      compactedVolume: compactedVolume ?? this.compactedVolume,
      truckLoads: truckLoads ?? this.truckLoads,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      expansionFactor: expansionFactor ?? this.expansionFactor,
      compactionFactor: compactionFactor ?? this.compactionFactor,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        length,
        width,
        depth,
        operationType,
        soilType,
        totalVolume,
        compactedVolume,
        truckLoads,
        estimatedHours,
        expansionFactor,
        compactionFactor,
        estimatedCost,
        calculatedAt,
      ];
}

import 'package:core/core.dart';

/// Represents anonymous data specific to the Gasometer app
/// 
/// This class encapsulates all anonymous data from the gasometer app
/// including vehicles, fuel records, maintenance records, and other
/// app-specific data that might conflict with existing account data.
class GasometerAnonymousData extends AnonymousData {
  const GasometerAnonymousData({
    required super.userId,
    required super.userInfo,
    required super.recordCount,
    required super.lastModified,
    super.additionalInfo = const {},
    this.vehicleCount = 0,
    this.fuelRecordCount = 0,
    this.maintenanceRecordCount = 0,
    this.totalDistance = 0.0,
    this.totalFuelCost = 0.0,
  }) : super(dataType: 'gasometer');

  /// Create from JSON
  factory GasometerAnonymousData.fromJson(Map<String, dynamic> json) {
    return GasometerAnonymousData(
      userId: json['user_id'] as String,
      userInfo: UserEntity.fromJson(json['user_info'] as Map<String, dynamic>),
      recordCount: json['record_count'] as int,
      lastModified: DateTime.parse(json['last_modified'] as String),
      additionalInfo: json['additional_info'] as Map<String, dynamic>? ?? const {},
      vehicleCount: json['vehicle_count'] as int? ?? 0,
      fuelRecordCount: json['fuel_record_count'] as int? ?? 0,
      maintenanceRecordCount: json['maintenance_record_count'] as int? ?? 0,
      totalDistance: (json['total_distance'] as num?)?.toDouble() ?? 0.0,
      totalFuelCost: (json['total_fuel_cost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Create empty instance (no data)
  factory GasometerAnonymousData.empty({
    required String userId,
    required UserEntity userInfo,
  }) {
    return GasometerAnonymousData(
      userId: userId,
      userInfo: userInfo,
      recordCount: 0,
      lastModified: DateTime.now(),
    );
  }

  /// Number of vehicles in anonymous data
  final int vehicleCount;
  
  /// Number of fuel records in anonymous data
  final int fuelRecordCount;
  
  /// Number of maintenance records in anonymous data
  final int maintenanceRecordCount;
  
  /// Total distance traveled (odometer readings)
  final double totalDistance;
  
  /// Total amount spent on fuel
  final double totalFuelCost;

  @override
  String get summary {
    final parts = <String>[];
    
    if (vehicleCount > 0) {
      parts.add('$vehicleCount veículo${vehicleCount > 1 ? 's' : ''}');
    }
    
    if (fuelRecordCount > 0) {
      parts.add('$fuelRecordCount abastecimento${fuelRecordCount > 1 ? 's' : ''}');
    }
    
    if (maintenanceRecordCount > 0) {
      parts.add('$maintenanceRecordCount manutenç${maintenanceRecordCount > 1 ? 'ões' : 'ão'}');
    }
    
    if (parts.isEmpty) {
      return 'Nenhum dado encontrado';
    }
    
    return parts.join(', ');
  }

  @override
  Map<String, dynamic> get breakdown {
    return {
      'vehicles': vehicleCount,
      'fuel_records': fuelRecordCount,
      'maintenance_records': maintenanceRecordCount,
      'total_records': recordCount,
      'total_distance_km': totalDistance,
      'total_fuel_cost': totalFuelCost,
      'last_modified': lastModified.toIso8601String(),
      'data_value_score': _calculateDataValueScore(),
    };
  }

  /// Calculate a score representing the value/importance of this data
  /// Higher scores indicate more valuable data that user might want to keep
  int _calculateDataValueScore() {
    int score = 0;
    
    // Vehicles are highly valuable
    score += vehicleCount * 20;
    
    // Fuel records add value, especially if there are many
    score += fuelRecordCount * 2;
    
    // Maintenance records are also valuable
    score += maintenanceRecordCount * 3;
    
    // Recent data is more valuable
    final daysSinceLastModified = DateTime.now().difference(lastModified).inDays;
    if (daysSinceLastModified < 7) {
      score += 10; // Very recent
    } else if (daysSinceLastModified < 30) {
      score += 5; // Recent
    }
    
    // More distance tracked indicates more usage
    if (totalDistance > 1000) {
      score += 5;
    }
    
    return score;
  }

  /// Whether this data is considered valuable enough to recommend keeping
  bool get isValuableData => _calculateDataValueScore() > 20;

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_info': userInfo.toJson(),
      'record_count': recordCount,
      'last_modified': lastModified.toIso8601String(),
      'data_type': dataType,
      'additional_info': additionalInfo,
      'vehicle_count': vehicleCount,
      'fuel_record_count': fuelRecordCount,
      'maintenance_record_count': maintenanceRecordCount,
      'total_distance': totalDistance,
      'total_fuel_cost': totalFuelCost,
    };
  }

  @override
  GasometerAnonymousData copyWith({
    String? userId,
    UserEntity? userInfo,
    int? recordCount,
    DateTime? lastModified,
    String? dataType,
    Map<String, dynamic>? additionalInfo,
    int? vehicleCount,
    int? fuelRecordCount,
    int? maintenanceRecordCount,
    double? totalDistance,
    double? totalFuelCost,
  }) {
    return GasometerAnonymousData(
      userId: userId ?? this.userId,
      userInfo: userInfo ?? this.userInfo,
      recordCount: recordCount ?? this.recordCount,
      lastModified: lastModified ?? this.lastModified,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      vehicleCount: vehicleCount ?? this.vehicleCount,
      fuelRecordCount: fuelRecordCount ?? this.fuelRecordCount,
      maintenanceRecordCount: maintenanceRecordCount ?? this.maintenanceRecordCount,
      totalDistance: totalDistance ?? this.totalDistance,
      totalFuelCost: totalFuelCost ?? this.totalFuelCost,
    );
  }
}
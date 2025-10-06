import 'package:core/core.dart';

/// Represents account data specific to the Gasometer app
/// 
/// This class encapsulates all existing account data from the gasometer app
/// that might conflict with anonymous data during migration.
class GasometerAccountData extends AccountData {
  const GasometerAccountData({
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
    this.accountAge,
  }) : super(dataType: 'gasometer');

  /// Create from JSON
  factory GasometerAccountData.fromJson(Map<String, dynamic> json) {
    return GasometerAccountData(
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
      accountAge: json['account_age_days'] != null 
          ? Duration(days: json['account_age_days'] as int)
          : null,
    );
  }

  /// Create empty instance (no data)
  factory GasometerAccountData.empty({
    required String userId,
    required UserEntity userInfo,
  }) {
    return GasometerAccountData(
      userId: userId,
      userInfo: userInfo,
      recordCount: 0,
      lastModified: DateTime.now(),
    );
  }

  /// Number of vehicles in account data
  final int vehicleCount;
  
  /// Number of fuel records in account data
  final int fuelRecordCount;
  
  /// Number of maintenance records in account data
  final int maintenanceRecordCount;
  
  /// Total distance traveled (odometer readings)
  final double totalDistance;
  
  /// Total amount spent on fuel
  final double totalFuelCost;
  
  /// How long this account has existed
  final Duration? accountAge;

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
    
    String result = parts.join(', ');
    
    if (accountAge != null) {
      result += ' (conta com ${_formatAccountAge(accountAge!)})';
    }
    
    return result;
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
      'account_age_days': accountAge?.inDays,
      'data_maturity_score': _calculateDataMaturityScore(),
    };
  }

  /// Calculate a score representing the maturity/establishment of this data
  /// Higher scores indicate more established data that user might prefer to keep
  int _calculateDataMaturityScore() {
    int score = 0;
    if (accountAge != null) {
      final days = accountAge!.inDays;
      if (days > 365) {
        score += 30; // Very old account
      } else if (days > 180) {
        score += 20; // Established account
      } else if (days > 30) {
        score += 10; // Moderately old account
      }
    }
    score += vehicleCount * 15;
    if (fuelRecordCount > 50) {
      score += 25;
    } else if (fuelRecordCount > 20) {
      score += 15;
    } else if (fuelRecordCount > 5) {
      score += 5;
    }
    score += maintenanceRecordCount * 5;
    if (totalDistance > 10000) {
      score += 20;
    } else if (totalDistance > 5000) {
      score += 10;
    }
    
    return score;
  }

  /// Whether this account data is considered well-established
  bool get isEstablishedData => _calculateDataMaturityScore() > 40;

  String _formatAccountAge(Duration age) {
    if (age.inDays > 365) {
      final years = (age.inDays / 365).floor();
      return '$years ano${years > 1 ? 's' : ''}';
    } else if (age.inDays > 30) {
      final months = (age.inDays / 30).floor();
      return '$months mês${months > 1 ? 'es' : ''}';
    } else {
      return '${age.inDays} dias';
    }
  }

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
      'account_age_days': accountAge?.inDays,
    };
  }

  @override
  GasometerAccountData copyWith({
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
    Duration? accountAge,
  }) {
    return GasometerAccountData(
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
      accountAge: accountAge ?? this.accountAge,
    );
  }
}
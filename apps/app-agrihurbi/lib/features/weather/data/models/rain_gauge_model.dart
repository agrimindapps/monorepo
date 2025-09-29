import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/rain_gauge_entity.dart';

part 'rain_gauge_model.g.dart';

/// Rain gauge model with Hive serialization
/// Converts between domain entity and data model for persistence
@HiveType(typeId: 51) // Unique typeId for rain gauges
class RainGaugeModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String locationId;

  @HiveField(2)
  final String locationName;

  @HiveField(3)
  final String deviceId;

  @HiveField(4)
  final String deviceModel;

  @HiveField(5)
  final DateTime installationDate;

  @HiveField(6)
  final double currentRainfall;

  @HiveField(7)
  final double dailyAccumulation;

  @HiveField(8)
  final double weeklyAccumulation;

  @HiveField(9)
  final double monthlyAccumulation;

  @HiveField(10)
  final double yearlyAccumulation;

  @HiveField(11)
  final double maxRainfallRate;

  @HiveField(12)
  final double avgRainfallRate;

  @HiveField(13)
  final DateTime lastMeasurement;

  @HiveField(14)
  final DateTime nextMeasurement;

  @HiveField(15)
  final int measurementInterval;

  @HiveField(16)
  final double latitude;

  @HiveField(17)
  final double longitude;

  @HiveField(18)
  final double heightAboveGround;

  @HiveField(19)
  final double calibrationFactor;

  @HiveField(20)
  final String status;

  @HiveField(21)
  final double? batteryLevel;

  @HiveField(22)
  final double? signalStrength;

  @HiveField(23)
  final double? temperature;

  @HiveField(24)
  final double dataQuality;

  @HiveField(25)
  final bool needsMaintenance;

  @HiveField(26)
  final DateTime? lastMaintenance;

  @HiveField(27)
  final DateTime? nextMaintenance;

  @HiveField(28)
  final String? maintenanceNotes;

  @HiveField(29)
  final String sourceType;

  @HiveField(30)
  final bool isActive;

  @HiveField(31)
  final DateTime createdAt;

  @HiveField(32)
  final DateTime updatedAt;

  const RainGaugeModel({
    required id,
    required locationId,
    required locationName,
    required deviceId,
    required deviceModel,
    required installationDate,
    required currentRainfall,
    required dailyAccumulation,
    required weeklyAccumulation,
    required monthlyAccumulation,
    required yearlyAccumulation,
    required maxRainfallRate,
    required avgRainfallRate,
    required lastMeasurement,
    required nextMeasurement,
    required measurementInterval,
    required latitude,
    required longitude,
    required heightAboveGround,
    required calibrationFactor,
    required status,
    batteryLevel,
    signalStrength,
    temperature,
    required dataQuality,
    required needsMaintenance,
    lastMaintenance,
    nextMaintenance,
    maintenanceNotes,
    required sourceType,
    required isActive,
    required createdAt,
    required updatedAt,
  });

  /// Create model from domain entity
  factory RainGaugeModel.fromEntity(RainGaugeEntity entity) {
    return RainGaugeModel(
      id: entity.id,
      locationId: entity.locationId,
      locationName: entity.locationName,
      deviceId: entity.deviceId,
      deviceModel: entity.deviceModel,
      installationDate: entity.installationDate,
      currentRainfall: entity.currentRainfall,
      dailyAccumulation: entity.dailyAccumulation,
      weeklyAccumulation: entity.weeklyAccumulation,
      monthlyAccumulation: entity.monthlyAccumulation,
      yearlyAccumulation: entity.yearlyAccumulation,
      maxRainfallRate: entity.maxRainfallRate,
      avgRainfallRate: entity.avgRainfallRate,
      lastMeasurement: entity.lastMeasurement,
      nextMeasurement: entity.nextMeasurement,
      measurementInterval: entity.measurementInterval,
      latitude: entity.latitude,
      longitude: entity.longitude,
      heightAboveGround: entity.heightAboveGround,
      calibrationFactor: entity.calibrationFactor,
      status: entity.status,
      batteryLevel: entity.batteryLevel,
      signalStrength: entity.signalStrength,
      temperature: entity.temperature,
      dataQuality: entity.dataQuality,
      needsMaintenance: entity.needsMaintenance,
      lastMaintenance: entity.lastMaintenance,
      nextMaintenance: entity.nextMaintenance,
      maintenanceNotes: entity.maintenanceNotes,
      sourceType: entity.sourceType,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to domain entity
  RainGaugeEntity toEntity() {
    return RainGaugeEntity(
      id: id,
      locationId: locationId,
      locationName: locationName,
      deviceId: deviceId,
      deviceModel: deviceModel,
      installationDate: installationDate,
      currentRainfall: currentRainfall,
      dailyAccumulation: dailyAccumulation,
      weeklyAccumulation: weeklyAccumulation,
      monthlyAccumulation: monthlyAccumulation,
      yearlyAccumulation: yearlyAccumulation,
      maxRainfallRate: maxRainfallRate,
      avgRainfallRate: avgRainfallRate,
      lastMeasurement: lastMeasurement,
      nextMeasurement: nextMeasurement,
      measurementInterval: measurementInterval,
      latitude: latitude,
      longitude: longitude,
      heightAboveGround: heightAboveGround,
      calibrationFactor: calibrationFactor,
      status: status,
      batteryLevel: batteryLevel,
      signalStrength: signalStrength,
      temperature: temperature,
      dataQuality: dataQuality,
      needsMaintenance: needsMaintenance,
      lastMaintenance: lastMaintenance,
      nextMaintenance: nextMaintenance,
      maintenanceNotes: maintenanceNotes,
      sourceType: sourceType,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from JSON (for API integration)
  factory RainGaugeModel.fromJson(Map<String, dynamic> json) {
    return RainGaugeModel(
      id: json['id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? '',
      deviceModel: json['device_model']?.toString() ?? '',
      installationDate: DateTime.tryParse(json['installation_date']?.toString() ?? '') ?? DateTime.now(),
      currentRainfall: (json['current_rainfall'] as num?)?.toDouble() ?? 0.0,
      dailyAccumulation: (json['daily_accumulation'] as num?)?.toDouble() ?? 0.0,
      weeklyAccumulation: (json['weekly_accumulation'] as num?)?.toDouble() ?? 0.0,
      monthlyAccumulation: (json['monthly_accumulation'] as num?)?.toDouble() ?? 0.0,
      yearlyAccumulation: (json['yearly_accumulation'] as num?)?.toDouble() ?? 0.0,
      maxRainfallRate: (json['max_rainfall_rate'] as num?)?.toDouble() ?? 0.0,
      avgRainfallRate: (json['avg_rainfall_rate'] as num?)?.toDouble() ?? 0.0,
      lastMeasurement: DateTime.tryParse(json['last_measurement']?.toString() ?? '') ?? DateTime.now(),
      nextMeasurement: DateTime.tryParse(json['next_measurement']?.toString() ?? '') ?? DateTime.now(),
      measurementInterval: (json['measurement_interval'] as num?)?.toInt() ?? 60,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      heightAboveGround: (json['height_above_ground'] as num?)?.toDouble() ?? 0.0,
      calibrationFactor: (json['calibration_factor'] as num?)?.toDouble() ?? 1.0,
      status: json['status']?.toString() ?? 'inactive',
      batteryLevel: (json['battery_level'] as num?)?.toDouble(),
      signalStrength: (json['signal_strength'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      dataQuality: (json['data_quality'] as num?)?.toDouble() ?? 0.0,
      needsMaintenance: json['needs_maintenance'] == true,
      lastMaintenance: json['last_maintenance'] != null
          ? DateTime.tryParse(json['last_maintenance'].toString())
          : null,
      nextMaintenance: json['next_maintenance'] != null
          ? DateTime.tryParse(json['next_maintenance'].toString())
          : null,
      maintenanceNotes: json['maintenance_notes']?.toString(),
      sourceType: json['source_type']?.toString() ?? 'automatic',
      isActive: json['is_active'] == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  /// Convert to JSON (for API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_id': locationId,
      'location_name': locationName,
      'device_id': deviceId,
      'device_model': deviceModel,
      'installation_date': installationDate.toIso8601String(),
      'current_rainfall': currentRainfall,
      'daily_accumulation': dailyAccumulation,
      'weekly_accumulation': weeklyAccumulation,
      'monthly_accumulation': monthlyAccumulation,
      'yearly_accumulation': yearlyAccumulation,
      'max_rainfall_rate': maxRainfallRate,
      'avg_rainfall_rate': avgRainfallRate,
      'last_measurement': lastMeasurement.toIso8601String(),
      'next_measurement': nextMeasurement.toIso8601String(),
      'measurement_interval': measurementInterval,
      'latitude': latitude,
      'longitude': longitude,
      'height_above_ground': heightAboveGround,
      'calibration_factor': calibrationFactor,
      'status': status,
      'battery_level': batteryLevel,
      'signal_strength': signalStrength,
      'temperature': temperature,
      'data_quality': dataQuality,
      'needs_maintenance': needsMaintenance,
      'last_maintenance': lastMaintenance?.toIso8601String(),
      'next_maintenance': nextMaintenance?.toIso8601String(),
      'maintenance_notes': maintenanceNotes,
      'source_type': sourceType,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create model from IoT device data
  factory RainGaugeModel.fromIoTData(
    Map<String, dynamic> deviceData,
    String locationId,
    String locationName,
  ) {
    final deviceInfo = deviceData['device_info'] ?? <String, dynamic>{};
    final measurements = deviceData['measurements'] ?? <String, dynamic>{};
    final status = deviceData['status'] ?? <String, dynamic>{};

    return RainGaugeModel(
      id: deviceData['gauge_id']?.toString() ?? '',
      locationId: locationId,
      locationName: locationName,
      deviceId: deviceInfo['device_id']?.toString() ?? '',
      deviceModel: deviceInfo['model']?.toString() ?? 'Unknown',
      installationDate: DateTime.tryParse(deviceInfo['installed_at']?.toString() ?? '') ?? DateTime.now(),
      currentRainfall: (measurements['current_rainfall'] as num?)?.toDouble() ?? 0.0,
      dailyAccumulation: (measurements['daily_total'] as num?)?.toDouble() ?? 0.0,
      weeklyAccumulation: (measurements['weekly_total'] as num?)?.toDouble() ?? 0.0,
      monthlyAccumulation: (measurements['monthly_total'] as num?)?.toDouble() ?? 0.0,
      yearlyAccumulation: (measurements['yearly_total'] as num?)?.toDouble() ?? 0.0,
      maxRainfallRate: (measurements['max_rate'] as num?)?.toDouble() ?? 0.0,
      avgRainfallRate: (measurements['avg_rate'] as num?)?.toDouble() ?? 0.0,
      lastMeasurement: DateTime.tryParse(measurements['last_reading_at']?.toString() ?? '') ?? DateTime.now(),
      nextMeasurement: DateTime.tryParse(measurements['next_reading_at']?.toString() ?? '') ?? DateTime.now(),
      measurementInterval: (measurements['interval_minutes'] as num?)?.toInt() ?? 60,
      latitude: (deviceData['location']?['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (deviceData['location']?['longitude'] as num?)?.toDouble() ?? 0.0,
      heightAboveGround: (deviceInfo['height_m'] as num?)?.toDouble() ?? 1.5,
      calibrationFactor: (deviceInfo['calibration'] as num?)?.toDouble() ?? 1.0,
      status: status['status']?.toString() ?? 'unknown',
      batteryLevel: (status['battery_percent'] as num?)?.toDouble(),
      signalStrength: (status['signal_strength'] as num?)?.toDouble(),
      temperature: (measurements['ambient_temp'] as num?)?.toDouble(),
      dataQuality: (status['data_quality'] as num?)?.toDouble() ?? 1.0,
      needsMaintenance: status['maintenance_required'] == true,
      lastMaintenance: status['last_maintenance'] != null
          ? DateTime.tryParse(status['last_maintenance'].toString())
          : null,
      nextMaintenance: status['next_maintenance'] != null
          ? DateTime.tryParse(status['next_maintenance'].toString())
          : null,
      maintenanceNotes: status['maintenance_notes']?.toString(),
      sourceType: deviceInfo['type']?.toString() ?? 'automatic',
      isActive: status['is_online'] == true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create model for manual rain gauge
  factory RainGaugeModel.manual({
    required String locationId,
    required String locationName,
    required double latitude,
    required double longitude,
    String? notes,
  }) {
    final now = DateTime.now();
    final id = 'manual_${now.millisecondsSinceEpoch}';

    return RainGaugeModel(
      id: id,
      locationId: locationId,
      locationName: locationName,
      deviceId: 'manual_$id',
      deviceModel: 'Manual Rain Gauge',
      installationDate: now,
      currentRainfall: 0.0,
      dailyAccumulation: 0.0,
      weeklyAccumulation: 0.0,
      monthlyAccumulation: 0.0,
      yearlyAccumulation: 0.0,
      maxRainfallRate: 0.0,
      avgRainfallRate: 0.0,
      lastMeasurement: now,
      nextMeasurement: now.add(const Duration(hours: 24)), // Daily manual reading
      measurementInterval: 1440, // 24 hours
      latitude: latitude,
      longitude: longitude,
      heightAboveGround: 1.5, // Standard height
      calibrationFactor: 1.0,
      status: 'active',
      batteryLevel: null, // Not applicable for manual gauge
      signalStrength: null, // Not applicable for manual gauge
      temperature: null,
      dataQuality: 0.8, // Manual readings typically have good quality
      needsMaintenance: false,
      lastMaintenance: now,
      nextMaintenance: now.add(const Duration(days: 90)), // Quarterly maintenance
      maintenanceNotes: notes,
      sourceType: 'manual',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Update measurements with new rainfall data
  RainGaugeModel updateMeasurements({
    required double newRainfall,
    required DateTime measurementTime,
  }) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final monthStart = DateTime(now.year, now.month, 1);
    final yearStart = DateTime(now.year, 1, 1);

    // Calculate time since last measurement for rate calculation
    final timeDiff = measurementTime.difference(lastMeasurement).inHours;
    final rate = timeDiff > 0 ? newRainfall / timeDiff : 0.0;

    // Update accumulations based on measurement time
    double newDaily = dailyAccumulation;
    double newWeekly = weeklyAccumulation;
    double newMonthly = monthlyAccumulation;
    double newYearly = yearlyAccumulation;

    if (measurementTime.isAfter(todayStart)) {
      newDaily += newRainfall;
    }
    if (measurementTime.isAfter(weekStartDay)) {
      newWeekly += newRainfall;
    }
    if (measurementTime.isAfter(monthStart)) {
      newMonthly += newRainfall;
    }
    if (measurementTime.isAfter(yearStart)) {
      newYearly += newRainfall;
    }

    return copyWith(
      currentRainfall: newRainfall,
      dailyAccumulation: newDaily,
      weeklyAccumulation: newWeekly,
      monthlyAccumulation: newMonthly,
      yearlyAccumulation: newYearly,
      maxRainfallRate: rate > maxRainfallRate ? rate : maxRainfallRate,
      avgRainfallRate: (avgRainfallRate + rate) / 2, // Simplified average
      lastMeasurement: measurementTime,
      nextMeasurement: measurementTime.add(Duration(minutes: measurementInterval)),
      updatedAt: now,
    );
  }

  /// Reset accumulations
  RainGaugeModel resetAccumulations({
    bool resetDaily = false,
    bool resetWeekly = false,
    bool resetMonthly = false,
    bool resetYearly = false,
  }) {
    return copyWith(
      dailyAccumulation: resetDaily ? 0.0 : dailyAccumulation,
      weeklyAccumulation: resetWeekly ? 0.0 : weeklyAccumulation,
      monthlyAccumulation: resetMonthly ? 0.0 : monthlyAccumulation,
      yearlyAccumulation: resetYearly ? 0.0 : yearlyAccumulation,
      updatedAt: DateTime.now(),
    );
  }

  /// Update device status
  RainGaugeModel updateStatus({
    String? status,
    double? batteryLevel,
    double? signalStrength,
    double? temperature,
    double? dataQuality,
    bool? needsMaintenance,
    String? maintenanceNotes,
    bool? isActive,
  }) {
    return copyWith(
      status: status ?? status,
      batteryLevel: batteryLevel ?? batteryLevel,
      signalStrength: signalStrength ?? signalStrength,
      temperature: temperature ?? temperature,
      dataQuality: dataQuality ?? dataQuality,
      needsMaintenance: needsMaintenance ?? needsMaintenance,
      maintenanceNotes: maintenanceNotes ?? maintenanceNotes,
      isActive: isActive ?? isActive,
      updatedAt: DateTime.now(),
    );
  }

  /// Create copy with updated properties
  RainGaugeModel copyWith({
    String? id,
    String? locationId,
    String? locationName,
    String? deviceId,
    String? deviceModel,
    DateTime? installationDate,
    double? currentRainfall,
    double? dailyAccumulation,
    double? weeklyAccumulation,
    double? monthlyAccumulation,
    double? yearlyAccumulation,
    double? maxRainfallRate,
    double? avgRainfallRate,
    DateTime? lastMeasurement,
    DateTime? nextMeasurement,
    int? measurementInterval,
    double? latitude,
    double? longitude,
    double? heightAboveGround,
    double? calibrationFactor,
    String? status,
    double? batteryLevel,
    double? signalStrength,
    double? temperature,
    double? dataQuality,
    bool? needsMaintenance,
    DateTime? lastMaintenance,
    DateTime? nextMaintenance,
    String? maintenanceNotes,
    String? sourceType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RainGaugeModel(
      id: id ?? id,
      locationId: locationId ?? locationId,
      locationName: locationName ?? locationName,
      deviceId: deviceId ?? deviceId,
      deviceModel: deviceModel ?? deviceModel,
      installationDate: installationDate ?? installationDate,
      currentRainfall: currentRainfall ?? currentRainfall,
      dailyAccumulation: dailyAccumulation ?? dailyAccumulation,
      weeklyAccumulation: weeklyAccumulation ?? weeklyAccumulation,
      monthlyAccumulation: monthlyAccumulation ?? monthlyAccumulation,
      yearlyAccumulation: yearlyAccumulation ?? yearlyAccumulation,
      maxRainfallRate: maxRainfallRate ?? maxRainfallRate,
      avgRainfallRate: avgRainfallRate ?? avgRainfallRate,
      lastMeasurement: lastMeasurement ?? lastMeasurement,
      nextMeasurement: nextMeasurement ?? nextMeasurement,
      measurementInterval: measurementInterval ?? measurementInterval,
      latitude: latitude ?? latitude,
      longitude: longitude ?? longitude,
      heightAboveGround: heightAboveGround ?? heightAboveGround,
      calibrationFactor: calibrationFactor ?? calibrationFactor,
      status: status ?? status,
      batteryLevel: batteryLevel ?? batteryLevel,
      signalStrength: signalStrength ?? signalStrength,
      temperature: temperature ?? temperature,
      dataQuality: dataQuality ?? dataQuality,
      needsMaintenance: needsMaintenance ?? needsMaintenance,
      lastMaintenance: lastMaintenance ?? lastMaintenance,
      nextMaintenance: nextMaintenance ?? nextMaintenance,
      maintenanceNotes: maintenanceNotes ?? maintenanceNotes,
      sourceType: sourceType ?? sourceType,
      isActive: isActive ?? isActive,
      createdAt: createdAt ?? createdAt,
      updatedAt: updatedAt ?? updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        locationId,
        locationName,
        deviceId,
        deviceModel,
        installationDate,
        currentRainfall,
        dailyAccumulation,
        weeklyAccumulation,
        monthlyAccumulation,
        yearlyAccumulation,
        maxRainfallRate,
        avgRainfallRate,
        lastMeasurement,
        nextMeasurement,
        measurementInterval,
        latitude,
        longitude,
        heightAboveGround,
        calibrationFactor,
        status,
        batteryLevel,
        signalStrength,
        temperature,
        dataQuality,
        needsMaintenance,
        lastMaintenance,
        nextMaintenance,
        maintenanceNotes,
        sourceType,
        isActive,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'RainGaugeModel('
        'id: $id, '
        'location: $locationName, '
        'device: $deviceId, '
        'daily: ${dailyAccumulation}mm, '
        'status: $status'
        ')';
  }
}
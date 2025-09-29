import 'package:equatable/equatable.dart';

/// Rain gauge entity for tracking rainfall measurements
/// Specialized entity for precipitation monitoring systems
class RainGaugeEntity extends Equatable {
  /// Unique identifier for the rain gauge
  final String id;
  
  /// Location identifier where gauge is installed
  final String locationId;
  
  /// Human-readable location name
  final String locationName;
  
  /// Rain gauge device/station identifier
  final String deviceId;
  
  /// Device manufacturer and model
  final String deviceModel;
  
  /// Installation date
  final DateTime installationDate;
  
  /// Current rainfall measurement in mm
  final double currentRainfall;
  
  /// Daily accumulated rainfall in mm
  final double dailyAccumulation;
  
  /// Weekly accumulated rainfall in mm
  final double weeklyAccumulation;
  
  /// Monthly accumulated rainfall in mm
  final double monthlyAccumulation;
  
  /// Yearly accumulated rainfall in mm
  final double yearlyAccumulation;
  
  /// Maximum rainfall rate recorded (mm/hour)
  final double maxRainfallRate;
  
  /// Average rainfall rate for current period
  final double avgRainfallRate;
  
  /// Last measurement timestamp
  final DateTime lastMeasurement;
  
  /// Next scheduled measurement
  final DateTime nextMeasurement;
  
  /// Measurement interval in minutes
  final int measurementInterval;
  
  /// Geographic coordinates
  final double latitude;
  final double longitude;
  
  /// Installation height above ground (meters)
  final double heightAboveGround;
  
  /// Gauge calibration factor
  final double calibrationFactor;
  
  /// Device status (active, maintenance, offline, etc.)
  final String status;
  
  /// Battery level percentage (0-100) for wireless devices
  final double? batteryLevel;
  
  /// Signal strength for wireless devices
  final double? signalStrength;
  
  /// Temperature at gauge location
  final double? temperature;
  
  /// Quality assessment of recent measurements
  final double dataQuality;
  
  /// Whether gauge requires maintenance
  final bool needsMaintenance;
  
  /// Last maintenance date
  final DateTime? lastMaintenance;
  
  /// Next scheduled maintenance
  final DateTime? nextMaintenance;
  
  /// Maintenance notes or issues
  final String? maintenanceNotes;
  
  /// Data source type (automatic, manual, hybrid)
  final String sourceType;
  
  /// Whether gauge is currently active and collecting data
  final bool isActive;
  
  /// Record creation timestamp
  final DateTime createdAt;
  
  /// Last update timestamp
  final DateTime updatedAt;

  const RainGaugeEntity({
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

  /// Creates empty rain gauge for initialization
  RainGaugeEntity.empty()
      : id = '',
        locationId = '',
        locationName = '',
        deviceId = '',
        deviceModel = '',
        installationDate = DateTime.fromMillisecondsSinceEpoch(0),
        currentRainfall = 0.0,
        dailyAccumulation = 0.0,
        weeklyAccumulation = 0.0,
        monthlyAccumulation = 0.0,
        yearlyAccumulation = 0.0,
        maxRainfallRate = 0.0,
        avgRainfallRate = 0.0,
        lastMeasurement = DateTime.fromMillisecondsSinceEpoch(0),
        nextMeasurement = DateTime.fromMillisecondsSinceEpoch(0),
        measurementInterval = 60,
        latitude = 0.0,
        longitude = 0.0,
        heightAboveGround = 0.0,
        calibrationFactor = 1.0,
        status = 'inactive',
        batteryLevel = null,
        signalStrength = null,
        temperature = null,
        dataQuality = 0.0,
        needsMaintenance = false,
        lastMaintenance = null,
        nextMaintenance = null,
        maintenanceNotes = null,
        sourceType = 'automatic',
        isActive = false,
        createdAt = DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Get status color for UI display
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
      case 'operational':
        return 'green';
      case 'warning':
      case 'low_battery':
        return 'yellow';
      case 'error':
      case 'offline':
      case 'maintenance':
        return 'red';
      case 'inactive':
      case 'standby':
        return 'gray';
      default:
        return 'gray';
    }
  }

  /// Check if gauge is operational
  bool get isOperational {
    return status.toLowerCase() == 'active' && 
           isActive && 
           !needsMaintenance &&
           dataQuality > 0.7 &&
           DateTime.now().difference(lastMeasurement).inHours < 24;
  }

  /// Check if battery is low (if applicable)
  bool get isLowBattery {
    return batteryLevel != null && batteryLevel! < 20;
  }

  /// Check if signal is weak (if applicable)
  bool get isWeakSignal {
    return signalStrength != null && signalStrength! < 30;
  }

  /// Get days since last maintenance
  int get daysSinceLastMaintenance {
    if (lastMaintenance == null) return 9999;
    return DateTime.now().difference(lastMaintenance!).inDays;
  }

  /// Check if maintenance is overdue
  bool get isMaintenanceOverdue {
    if (nextMaintenance == null) return false;
    return DateTime.now().isAfter(nextMaintenance!);
  }

  /// Get rainfall intensity classification
  String get rainfallIntensity {
    final rate = maxRainfallRate;
    if (rate == 0) return 'no_rain';
    if (rate <= 2.5) return 'light';
    if (rate <= 10) return 'moderate';
    if (rate <= 50) return 'heavy';
    return 'very_heavy';
  }

  /// Calculate average daily rainfall for current month
  double get averageDailyRainfall {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return monthlyAccumulation / daysInMonth;
  }

  /// Calculate rainfall deficit/surplus compared to historical average
  double calculateRainfallAnomaly(double historicalAverage) {
    return monthlyAccumulation - historicalAverage;
  }

  /// Get measurement frequency description
  String get measurementFrequency {
    if (measurementInterval < 60) {
      return '$measurementInterval minutes';
    } else if (measurementInterval < 1440) {
      final hours = (measurementInterval / 60).round();
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      final days = (measurementInterval / 1440).round();
      return '$days day${days > 1 ? 's' : ''}';
    }
  }

  /// Check if readings are within acceptable range
  bool get hasValidReadings {
    return currentRainfall >= 0 && 
           currentRainfall <= 500 && // Max reasonable daily rainfall
           dailyAccumulation >= currentRainfall &&
           weeklyAccumulation >= dailyAccumulation &&
           monthlyAccumulation >= weeklyAccumulation &&
           yearlyAccumulation >= monthlyAccumulation;
  }

  /// Get maintenance priority level
  String get maintenancePriority {
    if (!isActive || status == 'error') return 'critical';
    if (needsMaintenance || isMaintenanceOverdue) return 'high';
    if (isLowBattery || isWeakSignal || dataQuality < 0.8) return 'medium';
    if (daysSinceLastMaintenance > 180) return 'low';
    return 'none';
  }

  /// Create copy with modified properties
  RainGaugeEntity copyWith({
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
    return RainGaugeEntity(
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
    return 'RainGaugeEntity('
        'id: $id, '
        'location: $locationName, '
        'device: $deviceId, '
        'current: ${currentRainfall}mm, '
        'daily: ${dailyAccumulation}mm, '
        'status: $status'
        ')';
  }
}
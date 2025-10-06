import 'package:core/core.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';

class FuelRecordEntity extends BaseSyncEntity { // km/l
  
  const FuelRecordEntity({
    required super.id,
    required this.vehicleId,
    required this.fuelType,
    required this.liters,
    required this.pricePerLiter,
    required this.totalPrice,
    required this.odometer,
    required this.date,
    this.gasStationName,
    this.gasStationBrand,
    this.latitude,
    this.longitude,
    this.fullTank = true,
    this.notes,
    this.previousOdometer,
    this.distanceTraveled,
    this.consumption,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty,
    super.isDeleted,
    super.version,
    super.userId,
    super.moduleName,
  });
  final String vehicleId;
  final FuelType fuelType;
  final double liters;
  final double pricePerLiter;
  final double totalPrice;
  final double odometer;
  final DateTime date;
  final String? gasStationName;
  final String? gasStationBrand;
  final double? latitude;
  final double? longitude;
  final bool fullTank;
  final String? notes;
  final double? previousOdometer;
  final double? distanceTraveled;
  final double? consumption;
  
  @override
  List<Object?> get props => [
    ...super.props,
    vehicleId,
    fuelType,
    liters,
    pricePerLiter,
    totalPrice,
    odometer,
    date,
    gasStationName,
    gasStationBrand,
    latitude,
    longitude,
    fullTank,
    notes,
    previousOdometer,
    distanceTraveled,
    consumption,
  ];
  String? get address => null; // Not available in current entity
  List<String>? get photos => null; // Not available in current entity
  Map<String, dynamic>? get metadata => null; // Not available in current entity
  String get formattedPricePerLiter => 'R\$ ${pricePerLiter.toStringAsFixed(3)}';
  
  @override
  FuelRecordEntity copyWith({
    String? id,
    String? vehicleId,
    FuelType? fuelType,
    double? liters,
    double? pricePerLiter,
    double? totalPrice,
    double? odometer,
    DateTime? date,
    String? gasStationName,
    String? gasStationBrand,
    double? latitude,
    double? longitude,
    bool? fullTank,
    String? notes,
    double? previousOdometer,
    double? distanceTraveled,
    double? consumption,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) {
    return FuelRecordEntity(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      fuelType: fuelType ?? this.fuelType,
      liters: liters ?? this.liters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalPrice: totalPrice ?? this.totalPrice,
      odometer: odometer ?? this.odometer,
      date: date ?? this.date,
      gasStationName: gasStationName ?? this.gasStationName,
      gasStationBrand: gasStationBrand ?? this.gasStationBrand,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fullTank: fullTank ?? this.fullTank,
      notes: notes ?? this.notes,
      previousOdometer: previousOdometer ?? this.previousOdometer,
      distanceTraveled: distanceTraveled ?? this.distanceTraveled,
      consumption: consumption ?? this.consumption,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
    );
  }
  
  bool get temLocalizacao => latitude != null && longitude != null;
  
  bool get temObservacoes => notes != null && notes!.isNotEmpty;
  
  bool get podeCalcularConsumo => 
      previousOdometer != null && distanceTraveled != null && distanceTraveled! > 0;
  
  double get consumoCalculado {
    if (!podeCalcularConsumo) return 0.0;
    return distanceTraveled! / liters;
  }
  
  double get precoPorKm {
    if (!podeCalcularConsumo) return 0.0;
    return totalPrice / distanceTraveled!;
  }
  
  String get dataFormatada {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'} atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'} atrás';
    }
  }
  
  String get valorTotalFormatado => 'R\$ ${totalPrice.toStringAsFixed(2)}';
  
  String get precoPorLitroFormatado => 'R\$ ${pricePerLiter.toStringAsFixed(3)}';
  
  String get litrosFormatados => '${liters.toStringAsFixed(2)} L';
  
  String get odometroFormatado => '${odometer.toStringAsFixed(0)} km';
  
  String get consumoFormatado {
    if (consumption != null && consumption! > 0) {
      return '${consumption!.toStringAsFixed(1)} km/l';
    }
    return 'N/A';
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'vehicle_id': vehicleId,
      'fuel_type': fuelType.index,
      'liters': liters,
      'price_per_liter': pricePerLiter,
      'total_price': totalPrice,
      'odometer': odometer,
      'date': date.toIso8601String(),
      'gas_station_name': gasStationName,
      'gas_station_brand': gasStationBrand,
      'latitude': latitude,
      'longitude': longitude,
      'full_tank': fullTank,
      'notes': notes,
      'previous_odometer': previousOdometer,
      'distance_traveled': distanceTraveled,
      'consumption': consumption,
    };
  }

  static FuelRecordEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return FuelRecordEntity(
      id: baseFields['id'] as String,
      vehicleId: map['vehicle_id'] as String,
      fuelType: FuelType.values[map['fuel_type'] as int? ?? 0],
      liters: (map['liters'] as num).toDouble(),
      pricePerLiter: (map['price_per_liter'] as num).toDouble(),
      totalPrice: (map['total_price'] as num).toDouble(),
      odometer: (map['odometer'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      gasStationName: map['gas_station_name'] as String?,
      gasStationBrand: map['gas_station_brand'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      fullTank: map['full_tank'] as bool? ?? true,
      notes: map['notes'] as String?,
      previousOdometer: map['previous_odometer'] as double?,
      distanceTraveled: map['distance_traveled'] as double?,
      consumption: map['consumption'] as double?,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
    );
  }

  @override
  FuelRecordEntity markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  FuelRecordEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  FuelRecordEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  FuelRecordEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  FuelRecordEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  FuelRecordEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }
}

import 'package:core/core.dart';

enum FuelType {
  gasoline,
  ethanol,
  diesel,
  gas,
  hybrid,
  electric,
  flex;

  String get displayName {
    switch (this) {
      case FuelType.gasoline:
        return 'Gasolina';
      case FuelType.ethanol:
        return 'Etanol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.gas:
        return 'Gás';
      case FuelType.hybrid:
        return 'Híbrido';
      case FuelType.electric:
        return 'Elétrico';
      case FuelType.flex:
        return 'Flex';
    }
  }

  static FuelType fromString(String value) {
    return FuelType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FuelType.gasoline,
    );
  }
}

enum VehicleType {
  car,
  motorcycle,
  truck,
  van,
  bus;

  String get displayName {
    switch (this) {
      case VehicleType.car:
        return 'Carro';
      case VehicleType.motorcycle:
        return 'Moto';
      case VehicleType.truck:
        return 'Caminhão';
      case VehicleType.van:
        return 'Van';
      case VehicleType.bus:
        return 'Ônibus';
    }
  }

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VehicleType.car,
    );
  }
}

class VehicleEntity extends BaseSyncEntity {
  const VehicleEntity({
    required super.id,
    this.firebaseId,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.type,
    required this.supportedFuels,
    this.tankCapacity,
    this.engineSize,
    this.photoUrl,
    required this.currentOdometer,
    this.averageConsumption,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty,
    super.isDeleted,
    super.version,
    super.userId,
    super.moduleName,
    this.isActive = true,
    this.metadata = const {},
  });

  /// ID do documento no Firebase Firestore (UUID)
  /// Null = registro ainda não foi sincronizado
  final String? firebaseId;

  final String name;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final VehicleType type;
  final List<FuelType> supportedFuels;
  final double? tankCapacity;
  final double? engineSize;
  final String? photoUrl;
  final double currentOdometer;
  final double? averageConsumption;
  final bool isActive;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [
    ...super.props,
    firebaseId,
    name,
    brand,
    model,
    year,
    color,
    licensePlate,
    type,
    supportedFuels,
    tankCapacity,
    engineSize,
    photoUrl,
    currentOdometer,
    averageConsumption,
    isActive,
    metadata,
  ];

  @override
  VehicleEntity copyWith({
    String? id,
    String? firebaseId,
    String? name,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    VehicleType? type,
    List<FuelType>? supportedFuels,
    double? tankCapacity,
    double? engineSize,
    String? photoUrl,
    double? currentOdometer,
    double? averageConsumption,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      type: type ?? this.type,
      supportedFuels: supportedFuels ?? this.supportedFuels,
      tankCapacity: tankCapacity ?? this.tankCapacity,
      engineSize: engineSize ?? this.engineSize,
      photoUrl: photoUrl ?? this.photoUrl,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      averageConsumption: averageConsumption ?? this.averageConsumption,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  String get displayName => '$brand $model ($year)';

  bool get isEmpty => name.isEmpty || brand.isEmpty || model.isEmpty;

  bool get supportsMultipleFuels => supportedFuels.length > 1;

  String get primaryFuelType => supportedFuels.isNotEmpty
      ? supportedFuels.first.displayName
      : 'Não definido';

  bool supportsFuelType(FuelType fuelType) => supportedFuels.contains(fuelType);

  @override
  Map<String, dynamic> toFirebaseMap() {
    final map = <String, dynamic>{
      ...baseFirebaseFields,
      'name': name,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'license_plate': licensePlate,
      'type': type.name,
      'supported_fuels': supportedFuels.map((e) => e.name).toList(),
      'current_odometer': currentOdometer,
      'is_active': isActive,
      'metadata': metadata,
    };

    // Adicionar campos opcionais apenas se não forem null
    if (tankCapacity != null) {
      map['tank_capacity'] = tankCapacity;
    }
    if (engineSize != null) {
      map['engine_size'] = engineSize;
    }
    if (photoUrl != null) {
      map['photo_url'] = photoUrl;
    }
    if (averageConsumption != null) {
      map['average_consumption'] = averageConsumption;
    }

    return map;
  }

  static VehicleEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    final id = baseFields['id'] as String;
    return VehicleEntity(
      id: id,
      firebaseId: id,
      name: map['name'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      model: map['model'] as String? ?? '',
      year: map['year'] as int? ?? 0,
      color: map['color'] as String? ?? '',
      licensePlate: map['license_plate'] as String? ?? '',
      type: map['type'] != null
          ? VehicleType.fromString(map['type'] as String)
          : VehicleType.car,
      supportedFuels: map['supported_fuels'] != null
          ? (map['supported_fuels'] as List<dynamic>)
                .map((e) => FuelType.fromString(e as String))
                .toList()
          : [FuelType.gasoline],
      tankCapacity: map['tank_capacity'] as double?,
      engineSize: map['engine_size'] as double?,
      photoUrl: map['photo_url'] as String?,
      currentOdometer: (map['current_odometer'] as num?)?.toDouble() ?? 0.0,
      averageConsumption: map['average_consumption'] as double?,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool? ?? false,
      isDeleted: baseFields['isDeleted'] as bool? ?? false,
      version: baseFields['version'] as int? ?? 1,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String? ?? 'gasometer',
      isActive: map['is_active'] as bool? ?? true,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : {},
    );
  }

  @override
  VehicleEntity markAsDirty() {
    return copyWith(isDirty: true, updatedAt: DateTime.now());
  }

  @override
  VehicleEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(isDirty: false, lastSyncAt: syncTime ?? DateTime.now());
  }

  @override
  VehicleEntity markAsDeleted() {
    return copyWith(isDeleted: true, isDirty: true, updatedAt: DateTime.now());
  }

  @override
  VehicleEntity incrementVersion() {
    return copyWith(version: version + 1, updatedAt: DateTime.now());
  }

  @override
  VehicleEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  VehicleEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }
}

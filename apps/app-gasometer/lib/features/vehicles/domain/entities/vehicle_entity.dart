import 'package:equatable/equatable.dart';

enum FuelType {
  gasoline,
  ethanol,
  diesel,
  gas,
  hybrid,
  electric;
  
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

class VehicleEntity extends Equatable {
  final String id;
  final String userId;
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic> metadata;
  
  const VehicleEntity({
    required this.id,
    required this.userId,
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
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.metadata = const {},
  });
  
  @override
  List<Object?> get props => [
    id,
    userId,
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
    createdAt,
    updatedAt,
    isActive,
    metadata,
  ];
  
  VehicleEntity copyWith({
    String? id,
    String? userId,
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
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
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
}
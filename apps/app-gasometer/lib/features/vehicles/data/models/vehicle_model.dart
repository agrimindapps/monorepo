import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/vehicle_entity.dart';

part 'vehicle_model.g.dart';

@HiveType(typeId: 0)
class VehicleModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final String brand;
  
  @HiveField(4)
  final String model;
  
  @HiveField(5)
  final int year;
  
  @HiveField(6)
  final String color;
  
  @HiveField(7)
  final String licensePlate;
  
  @HiveField(8)
  final String type; // VehicleType as string
  
  @HiveField(9)
  final List<String> supportedFuels; // FuelType list as strings
  
  @HiveField(10)
  final double? tankCapacity;
  
  @HiveField(11)
  final double? engineSize;
  
  @HiveField(12)
  final String? photoUrl;
  
  @HiveField(13)
  final double currentOdometer;
  
  @HiveField(14)
  final double? averageConsumption;
  
  @HiveField(15)
  final DateTime createdAt;
  
  @HiveField(16)
  final DateTime updatedAt;
  
  @HiveField(17)
  final bool isActive;
  
  @HiveField(18)
  final Map<String, dynamic> metadata;
  
  VehicleModel({
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
  
  factory VehicleModel.fromEntity(VehicleEntity entity) {
    return VehicleModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      brand: entity.brand,
      model: entity.model,
      year: entity.year,
      color: entity.color,
      licensePlate: entity.licensePlate,
      type: entity.type.name,
      supportedFuels: entity.supportedFuels.map((f) => f.name).toList(),
      tankCapacity: entity.tankCapacity,
      engineSize: entity.engineSize,
      photoUrl: entity.photoUrl,
      currentOdometer: entity.currentOdometer,
      averageConsumption: entity.averageConsumption,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      metadata: entity.metadata,
    );
  }
  
  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return VehicleModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 0,
      color: data['color'] ?? '',
      licensePlate: data['licensePlate'] ?? '',
      type: data['type'] ?? 'car',
      supportedFuels: List<String>.from(data['supportedFuels'] ?? ['gasoline']),
      tankCapacity: data['tankCapacity']?.toDouble(),
      engineSize: data['engineSize']?.toDouble(),
      photoUrl: data['photoUrl'],
      currentOdometer: data['currentOdometer']?.toDouble() ?? 0.0,
      averageConsumption: data['averageConsumption']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }
  
  VehicleEntity toEntity() {
    return VehicleEntity(
      id: id,
      userId: userId,
      name: name,
      brand: brand,
      model: model,
      year: year,
      color: color,
      licensePlate: licensePlate,
      type: VehicleType.fromString(type),
      supportedFuels: supportedFuels.map((f) => FuelType.fromString(f)).toList(),
      tankCapacity: tankCapacity,
      engineSize: engineSize,
      photoUrl: photoUrl,
      currentOdometer: currentOdometer,
      averageConsumption: averageConsumption,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      metadata: metadata,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'licensePlate': licensePlate,
      'type': type,
      'supportedFuels': supportedFuels,
      'tankCapacity': tankCapacity,
      'engineSize': engineSize,
      'photoUrl': photoUrl,
      'currentOdometer': currentOdometer,
      'averageConsumption': averageConsumption,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'metadata': metadata,
    };
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'licensePlate': licensePlate,
      'type': type,
      'supportedFuels': supportedFuels,
      'tankCapacity': tankCapacity,
      'engineSize': engineSize,
      'photoUrl': photoUrl,
      'currentOdometer': currentOdometer,
      'averageConsumption': averageConsumption,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }
  
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      color: json['color'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      type: json['type'] ?? 'car',
      supportedFuels: List<String>.from(json['supportedFuels'] ?? ['gasoline']),
      tankCapacity: json['tankCapacity']?.toDouble(),
      engineSize: json['engineSize']?.toDouble(),
      photoUrl: json['photoUrl'],
      currentOdometer: json['currentOdometer']?.toDouble() ?? 0.0,
      averageConsumption: json['averageConsumption']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}